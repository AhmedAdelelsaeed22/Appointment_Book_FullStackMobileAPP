namespace AppointmentBook.Data.Dto
{
    public class EmailVerificationOtpDTO
    {
        public long id { get; set; }

        public long user_id { get; set; }

        public string otp_hash { get; set; } = null!;

        public DateTime expires_at { get; set; }

        public int attempts { get; set; }

        public bool is_used { get; set; }

        public DateTime created_at { get; set; }

        public EmailVerificationOtpDTO(long id, long user_id, string otp_hash, DateTime expires_at, int attempts, bool is_used, DateTime created_at)
        {
            this.id = id;
            this.user_id = user_id;
            this.otp_hash = otp_hash;
            this.expires_at = expires_at;
            this.attempts = attempts;
            this.is_used = is_used;
            this.created_at = created_at;
        }
    }
}
