using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class user
{
    public long id { get; set; }

    public string first_name { get; set; } = null!;

    public string last_name { get; set; } = null!;

    public string email { get; set; } = null!;

    public string? phone { get; set; }

    public string password_hash { get; set; } = null!;

    public string? profile_image_url { get; set; }

    public bool is_active { get; set; }

    public DateTime created_at { get; set; }

    public string user_role { get; set; } = null!;

    public virtual ICollection<appointment_history> appointment_histories { get; set; } = new List<appointment_history>();

    public virtual ICollection<appointment> appointments { get; set; } = new List<appointment>();

    public virtual ICollection<audit_log> audit_logs { get; set; } = new List<audit_log>();

    public virtual ICollection<business> businesses { get; set; } = new List<business>();

    public virtual ICollection<email_verification_otp> email_verification_otps { get; set; } = new List<email_verification_otp>();

    public virtual ICollection<notification> notifications { get; set; } = new List<notification>();

    public virtual ICollection<payment_method> payment_methods { get; set; } = new List<payment_method>();

    public virtual ICollection<payment> payments { get; set; } = new List<payment>();

    public virtual ICollection<refresh_token> refresh_tokens { get; set; } = new List<refresh_token>();

    public virtual ICollection<user_favorite_business> user_favorite_businesses { get; set; } = new List<user_favorite_business>();
}
