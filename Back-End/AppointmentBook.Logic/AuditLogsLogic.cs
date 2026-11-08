using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class AuditLogsLogic
    {
        // =========================
        // PROPERTIES
        // =========================

        public long id { get; set; }

        public long? user_id { get; set; }

        public string action { get; set; } = null!;

        public string log_type { get; set; } = null!;

        public string? ip_address { get; set; }

        public DateTime created_at { get; set; }

        public AuditLogsDTO ADTO
        {
            get
            {
                return new AuditLogsDTO
                (
                    this.id,
                    this.user_id,
                    this.action,
                    this.log_type,
                    this.ip_address,
                    this.created_at
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public AuditLogsLogic(AuditLogsDTO auditLogDTO)
        {

            this.id = auditLogDTO.id;
            this.user_id = auditLogDTO.user_id;
            this.action = auditLogDTO.action;
            this.log_type = auditLogDTO.log_type;
            this.ip_address = auditLogDTO.ip_address;
            this.created_at = auditLogDTO.created_at;
        }


        public static async Task<AuditLogsLogic?> FindAsync(
            IAuditLogsService auditLogsData,
            long auditLogId)
        {
            AuditLogsDTO? auditLogDTO =
                await auditLogsData.GetAuditLogByIdAsync(auditLogId);

            if (auditLogDTO == null)
            {
                return null;
            }

            return new AuditLogsLogic(auditLogDTO);
        }


        private async Task<bool> InsertAsync(IAuditLogsService auditLogsData)
        {
            long newAuditLogId =
                await auditLogsData.CreateAuditLogAsync(ADTO);

            if (newAuditLogId == 0)
            {
                return false;
            }

            return true;
        }


        public async Task<bool> SaveAsync(IAuditLogsService auditLogsData)
        {
            return await InsertAsync(auditLogsData);
        }
    }
}


