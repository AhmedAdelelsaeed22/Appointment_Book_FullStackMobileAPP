using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class location
{
    public long id { get; set; }

    public long business_id { get; set; }

    public string name { get; set; } = null!;

    public string address_line1 { get; set; } = null!;

    public string? address_line2 { get; set; }

    public string city { get; set; } = null!;

    public string? state { get; set; }

    public string country { get; set; } = null!;

    public string? postal_code { get; set; }

    public decimal? latitude { get; set; }

    public decimal? longitude { get; set; }

    public string? phone { get; set; }

    public string? timezone { get; set; }

    public bool is_active { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual business business { get; set; } = null!;
}
