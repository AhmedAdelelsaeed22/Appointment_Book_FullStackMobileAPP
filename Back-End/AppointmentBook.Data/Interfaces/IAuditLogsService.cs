using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IAuditLogsService
    {
        Task<AuditLogsDTO?> GetAuditLogByIdAsync(long auditLogId);

        Task<long> CreateAuditLogAsync(AuditLogsDTO auditLog);

    }
}
