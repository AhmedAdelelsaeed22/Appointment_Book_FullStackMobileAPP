using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IEmailVerificationOtp
    {
        Task<long> CreateEmailOTPAsync(EmailVerificationOtpDTO emailVerificationOtpDto);


        Task<bool> OTPVerification(long userId, string Otp);
    }
}
