using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class staff
{
    public long id { get; set; }

    public long business_id { get; set; }

    public string? job_title { get; set; }

    public bool is_avilable { get; set; }

    public virtual ICollection<appointment> appointments { get; set; } = new List<appointment>();

    public virtual business business { get; set; } = null!;
}
