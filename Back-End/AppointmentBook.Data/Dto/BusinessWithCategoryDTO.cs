namespace AppointmentBook.Data.Dto
{
    public class BusinessWithCategoryDTO
    {
        public long? id { get; set; }

        public long? owner_id { get; set; }

        public string? name { get; set; }

        public string? description { get; set; }

        public string? email { get; set; }

        public string? phone { get; set; }

        public string? logo_url { get; set; }

        public string? timezone { get; set; }

        public bool? is_open { get; set; }

        public string? category_name { get; set; }

        public decimal? rating { get; set; }

        public string? location { get; set; }
    }
}
