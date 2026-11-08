namespace AppointmentBook.Data.Dto.Auth
{
    public class SignUpRequest
    {
        public string first_name { get; set; } = null!;

        public string last_name { get; set; } = null!;

        public string email { get; set; } = null!;

        public string? phone { get; set; }

        public string password { get; set; } = null!;

        public string? profile_image_url { get; set; }
    }
}
