using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class email_verification_otp
{
    public long id { get; set; }

    public long user_id { get; set; }

    public string otp_hash { get; set; } = null!;

    public DateTime expires_at { get; set; }

    public int attempts { get; set; }

    public bool is_used { get; set; }

    public DateTime created_at { get; set; }

    public virtual user user { get; set; } = null!;
}
