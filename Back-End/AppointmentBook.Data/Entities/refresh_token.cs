using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class refresh_token
{
    public long id { get; set; }

    public long user_id { get; set; }

    public string token_hash { get; set; } = null!;

    public DateTime? expires_at { get; set; }

    public DateTime? revoked_at { get; set; }

    public virtual user user { get; set; } = null!;
}
