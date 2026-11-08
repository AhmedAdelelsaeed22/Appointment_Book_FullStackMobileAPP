namespace AppointmentBook.Data.Dto.Auth
{
    public class RefreshRequest
    {
        public string RefreshToken { get; set; }
        public string Email { get; set; }
    }
}
