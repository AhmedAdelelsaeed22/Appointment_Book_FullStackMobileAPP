using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class business
{
    public long id { get; set; }

    public long owner_id { get; set; }

    public string name { get; set; } = null!;

    public string? description { get; set; }

    public string email { get; set; } = null!;

    public string phone { get; set; } = null!;

    public string? logo_url { get; set; }

    public string timezone { get; set; } = null!;

    public bool is_open { get; set; }

    public long service_category_id { get; set; }

    public decimal rating { get; set; }

    public string location { get; set; } = null!;

    public virtual ICollection<appointment> appointments { get; set; } = new List<appointment>();

    public virtual ICollection<business_availability> business_availabilities { get; set; } = new List<business_availability>();

    public virtual ICollection<location> locations { get; set; } = new List<location>();

    public virtual user owner { get; set; } = null!;

    public virtual category service_category { get; set; } = null!;

    public virtual ICollection<service> services { get; set; } = new List<service>();

    public virtual ICollection<staff> staff { get; set; } = new List<staff>();

    public virtual ICollection<user_favorite_business> user_favorite_businesses { get; set; } = new List<user_favorite_business>();
}
