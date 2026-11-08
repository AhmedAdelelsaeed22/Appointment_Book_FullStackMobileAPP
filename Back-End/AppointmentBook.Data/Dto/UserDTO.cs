namespace AppointmentBook.Data.Dto
{
    public class UserDTO
    {
        public long id { get; set; }

        public string first_name { get; set; } = null!;

        public string last_name { get; set; } = null!;

        public string email { get; set; } = null!;

        public string? phone { get; set; }

        public string password_hash { get; set; } = null!;

        public string? profile_image_url { get; set; }

        public bool is_active { get; set; }

        public DateTime created_at { get; set; }

        public string user_role { get; set; } = null!;

        public UserDTO(
       long id,
       string first_name,
       string last_name,
       string email,
       string? phone,
       string password_hash,
       string? profile_image_url,
       bool is_active,
       DateTime created_at,
       string user_role)
        {
            this.id = id;
            this.first_name = first_name;
            this.last_name = last_name;
            this.email = email;
            this.password_hash = password_hash;
            this.phone = phone;
            this.profile_image_url = profile_image_url;
            this.is_active = is_active;
            this.created_at = created_at;
            this.user_role = user_role;
        }
    }
}
