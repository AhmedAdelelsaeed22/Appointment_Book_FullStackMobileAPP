namespace AppointmentBook.Data.Dto.Auth
{
    public class OTPVerifyRequest
    {
        public string email { get; set; }
        public string OTP { get; set; }
    }
}
