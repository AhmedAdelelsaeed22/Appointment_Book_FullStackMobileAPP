namespace AppointmentBook.Data.Dto
{
    public class FavoriteBusinessDTO
    {
        public long id { get; set; }

        public long user_id { get; set; }

        public long business_id { get; set; }

        public DateTime created_at { get; set; }


        public FavoriteBusinessDTO(
            long id,
            long user_id,
            long business_id,
            DateTime created_at)
        {
            this.id = id;
            this.user_id = user_id;
            this.business_id = business_id;
            this.created_at = created_at;
        }
    }
}
