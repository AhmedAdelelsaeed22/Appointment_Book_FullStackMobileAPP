namespace AppointmentBook.Data.Dto
{
    public class AvailableTimeDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public TimeOnly available_time { get; set; }


        public AvailableTimeDTO(
            long id,
            long business_id,
            TimeOnly available_time)
        {
            this.id = id;
            this.business_id = business_id;
            this.available_time = available_time;
        }
    }
}