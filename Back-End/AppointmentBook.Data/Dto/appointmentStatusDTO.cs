namespace AppointmentBook.Data.Dto
{
    public class appointmentStatusDTO
    {
        public long id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }


        public appointmentStatusDTO(
            long id,
            string name,
            string? description)
        {
            this.id = id;
            this.name = name;
            this.description = description;
        }
    }
}