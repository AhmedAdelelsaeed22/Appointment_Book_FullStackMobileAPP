using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class audit_log
{
    public long id { get; set; }

    public long? user_id { get; set; }

    public string action { get; set; } = null!;

    public string log_type { get; set; } = null!;

    public string? ip_address { get; set; }

    public DateTime created_at { get; set; }

    public virtual user? user { get; set; }
}
