namespace AppointmentBook.Data.Dto
{
    public class FavoriteBusinessWithDetailsDTO
    {
        public long id { get; set; }

        public long business_id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }

        public string email { get; set; } = null!;

        public string phone { get; set; } = null!;

        public string? logo_url { get; set; }

        public string timezone { get; set; } = null!;

        public bool is_open { get; set; }

        public decimal rating { get; set; }

        public string location { get; set; } = null!;

        public DateTime created_at { get; set; }
    }
}
