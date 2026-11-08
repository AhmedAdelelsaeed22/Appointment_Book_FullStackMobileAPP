namespace AppointmentBook.Data.Dto
{
    public class AuditLogsDTO
    {
        public long id { get; set; }

        public long? user_id { get; set; }

        public string action { get; set; } = null!;

        public string log_type { get; set; } = null!;

        public string? ip_address { get; set; }

        public DateTime created_at { get; set; }


        public AuditLogsDTO(long id, long? user_id, string action, string log_type, string? ip_address, DateTime created_at)
        {
            this.id = id;
            this.user_id = user_id;
            this.action = action;
            this.log_type = log_type;
            this.ip_address = ip_address;
            this.created_at = created_at;
        }
    }
}
