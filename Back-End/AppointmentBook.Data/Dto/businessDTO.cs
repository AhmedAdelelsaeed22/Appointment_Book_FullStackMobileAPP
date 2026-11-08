namespace AppointmentBook.Data.Dto
{
    public class businessDTO
    {
        public long id { get; set; }

        public long owner_id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }

        public string email { get; set; } = null!;

        public string phone { get; set; } = null!;

        public string? logo_url { get; set; }

        public string timezone { get; set; } = null!;

        public bool is_open { get; set; }

        public long service_category_id { get; set; }

        public decimal rating { get; set; }

        public string location { get; set; } = null!;




        public businessDTO(
    long id,
    long owner_id,
    string name,
    string? description,
    string email,
    string phone,
    string? logo_url,
    string timezone,
    bool is_open,
    long service_category_id,
    decimal rating,
    string location)
        {
            this.id = id;
            this.owner_id = owner_id;
            this.name = name;
            this.description = description;
            this.email = email;
            this.phone = phone;
            this.logo_url = logo_url;
            this.timezone = timezone;
            this.is_open = is_open;
            this.service_category_id = service_category_id;
            this.rating = rating;
            this.location = location;

        }
    }
}
