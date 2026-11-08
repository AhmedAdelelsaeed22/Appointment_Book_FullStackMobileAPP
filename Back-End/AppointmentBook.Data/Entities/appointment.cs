using System;
using System.Collections.Generic;

namespace AppointmentBook.Data.Entities;

public partial class appointment
{
    public long id { get; set; }

    public long business_id { get; set; }

    public long customer_id { get; set; }

    public long service_id { get; set; }

    public long status_id { get; set; }

    public DateTime start_datetime { get; set; }

    public DateTime end_datetime { get; set; }

    public string? customer_notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public DateTime? cancelled_at { get; set; }

    public DateTime? completed_at { get; set; }

    public long staff_id { get; set; }

    public virtual ICollection<appointment_history> appointment_histories { get; set; } = new List<appointment_history>();

    public virtual business business { get; set; } = null!;

    public virtual user customer { get; set; } = null!;

    public virtual ICollection<notification> notifications { get; set; } = new List<notification>();

    public virtual ICollection<payment> payments { get; set; } = new List<payment>();

    public virtual service service { get; set; } = null!;

    public virtual staff staff { get; set; } = null!;

    public virtual appointment_status status { get; set; } = null!;
}
