using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AutoMapper;

namespace AppointmentBook.Data.Helper
{
    public class MappingProfiles : Profile
    {
        public MappingProfiles()
        {
            CreateMap<user, UserDTO>();
            CreateMap<user, UserDTO>().ReverseMap();

            CreateMap<refresh_token, RefreshTokensDTO>();
            CreateMap<refresh_token, RefreshTokensDTO>().ReverseMap();

            CreateMap<audit_log, AuditLogsDTO>();
            CreateMap<audit_log, AuditLogsDTO>().ReverseMap();

            CreateMap<email_verification_otp, EmailVerificationOtpDTO>();
            CreateMap<email_verification_otp, EmailVerificationOtpDTO>().ReverseMap();

            CreateMap<business, businessDTO>();
            CreateMap<business, businessDTO>().ReverseMap();

            CreateMap<category, categoriesDTO>();
            CreateMap<category, categoriesDTO>().ReverseMap();

            CreateMap<appointment_status, appointmentStatusDTO>();
            CreateMap<appointmentStatusDTO, appointment_status>();


            CreateMap<service, serviceDTO>();
            CreateMap<service, serviceDTO>().ReverseMap();

            CreateMap<staff, staffDTO>();
            CreateMap<staff, staffDTO>().ReverseMap();

            CreateMap<business_availability, AvailableTimeDTO>();
            CreateMap<AvailableTimeDTO, business_availability>();

            CreateMap<appointment, appointmentDTO>();
            CreateMap<appointmentDTO, appointment>();
        }
    }
}
