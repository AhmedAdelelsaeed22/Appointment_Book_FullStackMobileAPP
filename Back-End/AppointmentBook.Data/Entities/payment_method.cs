using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class payment_method
{
    public long id { get; set; }

    public long user_id { get; set; }

    public string provider { get; set; } = null!;

    public string provider_payment_method_id { get; set; } = null!;

    public string type { get; set; } = null!;

    public bool is_default { get; set; }

    public DateTime created_at { get; set; }

    public virtual user user { get; set; } = null!;
}
