namespace AppointmentBook.Data.Dto
{
    public class serviceDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public long? category_id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }

        public int duration_minutes { get; set; }

        public decimal price { get; set; }

        public string currency { get; set; } = null!;

        public bool is_available { get; set; }

        public DateTime created_at { get; set; }

        public DateTime updated_at { get; set; }


        public serviceDTO(
            long id,
            long business_id,
            long? category_id,
            string name,
            string? description,
            int duration_minutes,
            decimal price,
            string currency,
            bool is_available,
            DateTime created_at,
            DateTime updated_at)
        {
            this.id = id;
            this.business_id = business_id;
            this.category_id = category_id;
            this.name = name;
            this.description = description;
            this.duration_minutes = duration_minutes;
            this.price = price;
            this.currency = currency;
            this.is_available = is_available;
            this.created_at = created_at;
            this.updated_at = updated_at;
        }
    }
}