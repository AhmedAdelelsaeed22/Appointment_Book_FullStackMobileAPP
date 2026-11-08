using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class EmailVerificationOtpLogic
    {

        public EmailVerificationOtpLogic(EmailVerificationOtpDTO emailVerificationOtpDto)
        {
            id = emailVerificationOtpDto.id;
            user_id = emailVerificationOtpDto.user_id;
            otp_hash = emailVerificationOtpDto.otp_hash;
            expires_at = emailVerificationOtpDto.expires_at;
            attempts = emailVerificationOtpDto.attempts;
            is_used = emailVerificationOtpDto.is_used;
            created_at = emailVerificationOtpDto.created_at;
        }


        public long id { get; set; }

        public long user_id { get; set; }

        public string otp_hash { get; set; } = null!;

        public DateTime expires_at { get; set; }

        public int attempts { get; set; }

        public bool is_used { get; set; }

        public DateTime created_at { get; set; }

        public EmailVerificationOtpDTO EDTO
        {
            get
            {
                return new EmailVerificationOtpDTO(
                    id,
                    user_id,
                    otp_hash,
                    expires_at,
                    attempts,
                    is_used,
                    created_at
                );
            }
        }


        private async Task<bool> InsertEmailOTPAsync(IEmailVerificationOtp emailVerificationOtpService)
        {
            long newEmailOTPId =
                await emailVerificationOtpService.CreateEmailOTPAsync(EDTO);

            if (newEmailOTPId == 0)
            {
                return false;
            }

            return true;
        }


        public async Task<bool> SaveAsync(IEmailVerificationOtp emailVerificationOtpService)
        {
            return await InsertEmailOTPAsync(emailVerificationOtpService);
        }


        public static async Task<bool> OTPVerification(IEmailVerificationOtp emailVerificationOtpService, long userId, string Otp)
        {
            return await emailVerificationOtpService.OTPVerification(userId, Otp);
        }
    }
}
