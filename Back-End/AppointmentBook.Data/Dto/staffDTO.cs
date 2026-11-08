namespace AppointmentBook.Data.Dto
{
    public class staffDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public string? job_title { get; set; }

        public bool is_avilable { get; set; }


        public staffDTO(
            long id,
            long business_id,
            string? job_title,
            bool is_avilable)
        {
            this.id = id;
            this.business_id = business_id;
            this.job_title = job_title;
            this.is_avilable = is_avilable;
        }
    }
}