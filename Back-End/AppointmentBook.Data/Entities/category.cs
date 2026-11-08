using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class category
{
    public long id { get; set; }

    public string name { get; set; } = null!;

    public virtual ICollection<business> businesses { get; set; } = new List<business>();

    public virtual ICollection<service> services { get; set; } = new List<service>();
}
