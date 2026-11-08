namespace AppointmentBook.Data.Dto
{
    public class AppointmentDetailsDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public string business_name { get; set; } = null!;

        public long customer_id { get; set; }

        public string customer_name { get; set; } = null!;

        public long service_id { get; set; }

        public string service_name { get; set; } = null!;

        public long status_id { get; set; }

        public string status_name { get; set; } = null!;

        public DateTime start_datetime { get; set; }

        public DateTime end_datetime { get; set; }

        public string? customer_notes { get; set; }

        public DateTime created_at { get; set; }

        public DateTime updated_at { get; set; }

        public DateTime? cancelled_at { get; set; }

        public DateTime? completed_at { get; set; }

        public long staff_id { get; set; }

        public string? staff_name { get; set; }


        public AppointmentDetailsDTO(
            long id,
            long business_id,
            string business_name,
            long customer_id,
            string customer_name,
            long service_id,
            string service_name,
            long status_id,
            string status_name,
            DateTime start_datetime,
            DateTime end_datetime,
            string? customer_notes,
            DateTime created_at,
            DateTime updated_at,
            DateTime? cancelled_at,
            DateTime? completed_at,
            long staff_id,
            string? staff_name)
        {
            this.id = id;
            this.business_id = business_id;
            this.business_name = business_name;
            this.customer_id = customer_id;
            this.customer_name = customer_name;
            this.service_id = service_id;
            this.service_name = service_name;
            this.status_id = status_id;
            this.status_name = status_name;
            this.start_datetime = start_datetime;
            this.end_datetime = end_datetime;
            this.customer_notes = customer_notes;
            this.created_at = created_at;
            this.updated_at = updated_at;
            this.cancelled_at = cancelled_at;
            this.completed_at = completed_at;
            this.staff_id = staff_id;
            this.staff_name = staff_name;
        }
    }
}