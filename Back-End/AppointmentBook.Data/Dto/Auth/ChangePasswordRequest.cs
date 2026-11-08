namespace AppointmentBook.Data.Dto.Auth
{
    public class ChangePasswordRequest
    {
        public string email { get; set; }
        public string NewPassword { get; set; }
    }
}
