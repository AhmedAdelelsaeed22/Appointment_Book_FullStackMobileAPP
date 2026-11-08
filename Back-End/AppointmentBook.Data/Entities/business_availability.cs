using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class business_availability
{
    public long id { get; set; }

    public long business_id { get; set; }

    public TimeOnly available_time { get; set; }

    public virtual business business { get; set; } = null!;
}
