using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Logic;
using System.Security.Cryptography;

namespace AppointmentBookAPI.Helper
{
    public class Utilities
    {
        public static async Task SaveLogs(long? userId, string message, string logType, string? email, string ip, IAuditLogsService auditLogger)
        {
            AuditLogsDTO auditLogsDTO = new AuditLogsDTO
                (
                    0,
                    userId,
                    $"{message} Email={email}, IP={ip}",
                    logType,
                    ip,
                    DateTime.UtcNow
                );


            AuditLogsLogic auditLogsLogic = new AuditLogsLogic(auditLogsDTO);
            await auditLogsLogic.SaveAsync(auditLogger);
        }


        public static string GenerateRefreshToken()
        {
            var bytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(bytes);
            return Convert.ToBase64String(bytes);
        }

        public static string GenerateOtp()
        {
            return RandomNumberGenerator
                .GetInt32(100000, 1000000)
                .ToString();
        }
    }
}
