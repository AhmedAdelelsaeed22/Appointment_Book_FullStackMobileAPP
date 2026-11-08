using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class appointment_status
{
    public long id { get; set; }

    public string name { get; set; } = null!;

    public string? description { get; set; }

    public virtual ICollection<appointment_history> appointment_historynew_statuses { get; set; } = new List<appointment_history>();

    public virtual ICollection<appointment_history> appointment_historyold_statuses { get; set; } = new List<appointment_history>();

    public virtual ICollection<appointment> appointments { get; set; } = new List<appointment>();
}
