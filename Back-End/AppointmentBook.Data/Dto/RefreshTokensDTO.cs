namespace AppointmentBook.Data.Dto
{
    public class RefreshTokensDTO
    {
        public long id { get; set; }

        public long user_id { get; set; }

        public string token_hash { get; set; } = null!;

        public DateTime? expires_at { get; set; }

        public DateTime? revoked_at { get; set; }

        public RefreshTokensDTO(long id, long user_id, string token_hash, DateTime? expires_at, DateTime? revoked_at)
        {
            this.id = id;
            this.user_id = user_id;
            this.token_hash = token_hash;
            this.expires_at = expires_at;
            this.revoked_at = revoked_at;
        }
    }
}
