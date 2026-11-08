using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using Microsoft.Extensions.Options;
using Resend;


namespace AppointmentBook.Data.Services
{
    public class EmailService : IEmailService
    {
        private readonly IResend _resend;
        private readonly EmailSettings _emailSettings;

        public EmailService(
            IResend resend,
            IOptions<EmailSettings> emailSettings)
        {
            _resend = resend;
            _emailSettings = emailSettings.Value;
        }

        public async Task SendEmailAsync(
            string to,
            string subject,
            string body)
        {

            var message = new EmailMessage();

            message.From =
                $"{_emailSettings.FromName} <{_emailSettings.FromEmail}>";

            message.To.Add(to);

            message.Subject = subject;

            message.TextBody = body;



            await _resend.EmailSendAsync(message);
        }
    }
}