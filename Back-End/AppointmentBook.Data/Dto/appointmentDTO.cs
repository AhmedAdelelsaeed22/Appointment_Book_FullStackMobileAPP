namespace AppointmentBook.Data.Dto
{
    public class appointmentDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public long customer_id { get; set; }

        public long service_id { get; set; }

        public DateTime start_datetime { get; set; }

        public DateTime end_datetime { get; set; }

        public string? customer_notes { get; set; }

        public long staff_id { get; set; }


        public appointmentDTO(
            long id,
            long business_id,
            long customer_id,
            long service_id,
            DateTime start_datetime,
            DateTime end_datetime,
            string? customer_notes,
            long staff_id)
        {
            this.id = id;
            this.business_id = business_id;
            this.customer_id = customer_id;
            this.service_id = service_id;
            this.start_datetime = start_datetime;
            this.end_datetime = end_datetime;
            this.customer_notes = customer_notes;
            this.staff_id = staff_id;
        }
    }
}