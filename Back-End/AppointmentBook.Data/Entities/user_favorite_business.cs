using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class user_favorite_business
{
    public long id { get; set; }

    public long user_id { get; set; }

    public long business_id { get; set; }

    public DateTime created_at { get; set; }

    public virtual business business { get; set; } = null!;

    public virtual user user { get; set; } = null!;
}
