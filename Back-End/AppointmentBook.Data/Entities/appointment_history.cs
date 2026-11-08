using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class appointment_history
{
    public long id { get; set; }

    public long appointment_id { get; set; }

    public long changed_by_user_id { get; set; }

    public long? old_status_id { get; set; }

    public long? new_status_id { get; set; }

    public DateTime? old_start_datetime { get; set; }

    public DateTime? new_start_datetime { get; set; }

    public long? old_staff_id { get; set; }

    public long? new_staff_id { get; set; }

    public string? reason { get; set; }

    public DateTime created_at { get; set; }

    public virtual appointment appointment { get; set; } = null!;

    public virtual user changed_by_user { get; set; } = null!;

    public virtual appointment_status? new_status { get; set; }

    public virtual appointment_status? old_status { get; set; }
}
