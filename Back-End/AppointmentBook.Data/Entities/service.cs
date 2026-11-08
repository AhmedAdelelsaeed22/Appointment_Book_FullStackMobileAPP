using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class service
{
    public long id { get; set; }

    public long business_id { get; set; }

    public long? category_id { get; set; }

    public string name { get; set; } = null!;

    public string? description { get; set; }

    public int duration_minutes { get; set; }

    public decimal price { get; set; }

    public string currency { get; set; } = null!;

    public bool is_available { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual ICollection<appointment> appointments { get; set; } = new List<appointment>();

    public virtual business business { get; set; } = null!;

    public virtual category? category { get; set; }
}
