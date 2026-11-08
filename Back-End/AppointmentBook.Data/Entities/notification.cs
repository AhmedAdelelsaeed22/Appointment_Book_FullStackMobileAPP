using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class notification
{
    public long id { get; set; }

    public long user_id { get; set; }

    public long? appointment_id { get; set; }

    public string type { get; set; } = null!;

    public string title { get; set; } = null!;

    public string message { get; set; } = null!;

    public bool is_read { get; set; }

    public DateTime? read_at { get; set; }

    public DateTime created_at { get; set; }

    public virtual appointment? appointment { get; set; }

    public virtual ICollection<notification_delivery> notification_deliveries { get; set; } = new List<notification_delivery>();

    public virtual user user { get; set; } = null!;
}
