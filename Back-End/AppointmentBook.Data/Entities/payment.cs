using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class payment
{
    public long id { get; set; }

    public long appointment_id { get; set; }

    public long user_id { get; set; }

    public decimal amount { get; set; }

    public string currency { get; set; } = null!;

    public string status { get; set; } = null!;

    public string? provider { get; set; }

    public string? provider_transaction_id { get; set; }

    public DateTime? paid_at { get; set; }

    public DateTime? refunded_at { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual appointment appointment { get; set; } = null!;

    public virtual user user { get; set; } = null!;
}
