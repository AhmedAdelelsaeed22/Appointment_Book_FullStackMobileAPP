using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class EmailVerificationOtpData : IEmailVerificationOtp
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public EmailVerificationOtpData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        public async Task<long> CreateEmailOTPAsync(
            EmailVerificationOtpDTO emailVerificationOtpDto)
        {

            // DTO -> Entity
            var emailVerificationOtp = _mapper.Map<email_verification_otp>(emailVerificationOtpDto);


            emailVerificationOtp.otp_hash = Hasher.HashPassword(emailVerificationOtpDto.otp_hash);


            // Add to database
            await _context.email_verification_otps.AddAsync(emailVerificationOtp);

            await _context.SaveChangesAsync();


            return emailVerificationOtp.id;
        }


        public async Task<bool> OTPVerification(long userId, string otp)
        {
            var emailOTPInfo = await _context.email_verification_otps
                .FirstOrDefaultAsync(x => x.user_id == userId && x.expires_at > DateTime.UtcNow);

            if (emailOTPInfo == null || emailOTPInfo.is_used)
                return false;

            emailOTPInfo.attempts++;
            if (!Hasher.VerifyPassword(otp, emailOTPInfo.otp_hash))
            {
                await _context.SaveChangesAsync();
                return false;
            }

            emailOTPInfo.is_used = true;

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
