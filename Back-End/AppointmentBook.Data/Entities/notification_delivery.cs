using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class notification_delivery
{
    public long id { get; set; }

    public long notification_id { get; set; }

    public string channel { get; set; } = null!;

    public string status { get; set; } = null!;

    public DateTime? sent_at { get; set; }

    public DateTime? failed_at { get; set; }

    public string? error_message { get; set; }

    public DateTime created_at { get; set; }

    public virtual notification notification { get; set; } = null!;
}
