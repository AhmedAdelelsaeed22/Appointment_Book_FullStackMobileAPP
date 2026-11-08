using System;
using System.Collections.Generic;
using AppointmentBook.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Data;

public partial class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<appointment> appointments { get; set; }

    public virtual DbSet<appointment_history> appointment_histories { get; set; }

    public virtual DbSet<appointment_status> appointment_statuses { get; set; }

    public virtual DbSet<audit_log> audit_logs { get; set; }

    public virtual DbSet<business> businesses { get; set; }

    public virtual DbSet<business_availability> business_availabilities { get; set; }

    public virtual DbSet<businesses_with_category> businesses_with_categories { get; set; }

    public virtual DbSet<category> categories { get; set; }

    public virtual DbSet<email_verification_otp> email_verification_otps { get; set; }

    public virtual DbSet<location> locations { get; set; }

    public virtual DbSet<notification> notifications { get; set; }

    public virtual DbSet<notification_delivery> notification_deliveries { get; set; }

    public virtual DbSet<payment> payments { get; set; }

    public virtual DbSet<payment_method> payment_methods { get; set; }

    public virtual DbSet<refresh_token> refresh_tokens { get; set; }

    public virtual DbSet<service> services { get; set; }

    public virtual DbSet<staff> staff { get; set; }

    public virtual DbSet<user> users { get; set; }

    public virtual DbSet<user_favorite_business> user_favorite_businesses { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("btree_gist");

        modelBuilder.Entity<appointment>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_appointments");

            entity.ToTable("appointments", "booking");

            entity.HasIndex(e => e.business_id, "ix_appointments_business_id");

            entity.HasIndex(e => e.customer_id, "ix_appointments_customer_id");

            entity.HasIndex(e => e.service_id, "ix_appointments_service_id");

            entity.HasIndex(e => e.start_datetime, "ix_appointments_start_datetime");

            entity.HasIndex(e => e.status_id, "ix_appointments_status_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.updated_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.business).WithMany(p => p.appointments)
                .HasForeignKey(d => d.business_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_appointments_business");

            entity.HasOne(d => d.customer).WithMany(p => p.appointments)
                .HasForeignKey(d => d.customer_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_appointments_customer");

            entity.HasOne(d => d.service).WithMany(p => p.appointments)
                .HasForeignKey(d => d.service_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_appointments_service");

            entity.HasOne(d => d.staff).WithMany(p => p.appointments)
                .HasForeignKey(d => d.staff_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_appointment_staff");

            entity.HasOne(d => d.status).WithMany(p => p.appointments)
                .HasForeignKey(d => d.status_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_appointments_status");
        });

        modelBuilder.Entity<appointment_history>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_appointment_history");

            entity.ToTable("appointment_history", "booking");

            entity.HasIndex(e => e.appointment_id, "ix_appointment_history_appointment_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.appointment).WithMany(p => p.appointment_histories)
                .HasForeignKey(d => d.appointment_id)
                .HasConstraintName("fk_appointment_history_appointment");

            entity.HasOne(d => d.changed_by_user).WithMany(p => p.appointment_histories)
                .HasForeignKey(d => d.changed_by_user_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_appointment_history_user");

            entity.HasOne(d => d.new_status).WithMany(p => p.appointment_historynew_statuses)
                .HasForeignKey(d => d.new_status_id)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_appointment_history_new_status");

            entity.HasOne(d => d.old_status).WithMany(p => p.appointment_historyold_statuses)
                .HasForeignKey(d => d.old_status_id)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_appointment_history_old_status");
        });

        modelBuilder.Entity<appointment_status>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_appointment_statuses");

            entity.ToTable("appointment_statuses", "booking");

            entity.HasIndex(e => e.name, "uq_appointment_statuses_name").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.description).HasMaxLength(255);
            entity.Property(e => e.name).HasMaxLength(50);
        });

        modelBuilder.Entity<audit_log>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_audit_logs");

            entity.ToTable("audit_logs", "audit");

            entity.HasIndex(e => e.created_at, "ix_audit_logs_created_at");

            entity.HasIndex(e => e.user_id, "ix_audit_logs_user_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.action).HasMaxLength(100);
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.ip_address).HasMaxLength(45);
            entity.Property(e => e.log_type)
                .HasMaxLength(100)
                .HasDefaultValueSql("'Information'::character varying");

            entity.HasOne(d => d.user).WithMany(p => p.audit_logs)
                .HasForeignKey(d => d.user_id)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_audit_logs_user");
        });

        modelBuilder.Entity<business>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_businesses");

            entity.ToTable("businesses", "business");

            entity.HasIndex(e => e.owner_id, "ix_businesses_owner_id");

            entity.HasIndex(e => e.service_category_id, "ix_service_category");

            entity.HasIndex(e => e.email, "uq_business_email").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.email).HasMaxLength(320);
            entity.Property(e => e.is_open).HasDefaultValue(true);
            entity.Property(e => e.name).HasMaxLength(200);
            entity.Property(e => e.phone).HasMaxLength(30);
            entity.Property(e => e.rating).HasPrecision(3, 2);
            entity.Property(e => e.timezone)
                .HasMaxLength(100)
                .HasDefaultValueSql("'UTC'::character varying");

            entity.HasOne(d => d.owner).WithMany(p => p.businesses)
                .HasForeignKey(d => d.owner_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_businesses_owner");

            entity.HasOne(d => d.service_category).WithMany(p => p.businesses)
                .HasForeignKey(d => d.service_category_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_business_service_category");
        });

        modelBuilder.Entity<business_availability>(entity =>
        {
            entity.HasKey(e => e.id).HasName("business_availability_pkey");

            entity.ToTable("business_availability", "availability");

            entity.HasIndex(e => e.business_id, "idx_business_availability_business_id");

            entity.HasIndex(e => new { e.business_id, e.available_time }, "ix_business_availability_business_id_available_time").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();

            entity.HasOne(d => d.business).WithMany(p => p.business_availabilities)
                .HasForeignKey(d => d.business_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_business_availability_business");
        });

        modelBuilder.Entity<businesses_with_category>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("businesses_with_category", "business");

            entity.Property(e => e.category_name).HasMaxLength(150);
            entity.Property(e => e.email).HasMaxLength(320);
            entity.Property(e => e.name).HasMaxLength(200);
            entity.Property(e => e.phone).HasMaxLength(30);
            entity.Property(e => e.rating).HasPrecision(3, 2);
            entity.Property(e => e.timezone).HasMaxLength(100);
        });

        modelBuilder.Entity<category>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_service_categories");

            entity.ToTable("categories", "catalog");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.name).HasMaxLength(150);
        });

        modelBuilder.Entity<email_verification_otp>(entity =>
        {
            entity.HasKey(e => e.id).HasName("email_verification_otp_pkey");

            entity.ToTable("email_verification_otp", "auth");

            entity.HasIndex(e => e.expires_at, "idx_auth_expires_at");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.attempts).HasDefaultValue(0);
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.is_used).HasDefaultValue(false);
            entity.Property(e => e.otp_hash).HasMaxLength(255);

            entity.HasOne(d => d.user).WithMany(p => p.email_verification_otps)
                .HasForeignKey(d => d.user_id)
                .HasConstraintName("fk_email_verification_otp_user");
        });

        modelBuilder.Entity<location>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_locations");

            entity.ToTable("locations", "business");

            entity.HasIndex(e => e.business_id, "ix_locations_business_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.address_line1).HasMaxLength(255);
            entity.Property(e => e.address_line2).HasMaxLength(255);
            entity.Property(e => e.city).HasMaxLength(100);
            entity.Property(e => e.country).HasMaxLength(100);
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.is_active).HasDefaultValue(true);
            entity.Property(e => e.latitude).HasPrecision(9, 6);
            entity.Property(e => e.longitude).HasPrecision(9, 6);
            entity.Property(e => e.name).HasMaxLength(150);
            entity.Property(e => e.phone).HasMaxLength(30);
            entity.Property(e => e.postal_code).HasMaxLength(20);
            entity.Property(e => e.state).HasMaxLength(100);
            entity.Property(e => e.timezone).HasMaxLength(100);
            entity.Property(e => e.updated_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.business).WithMany(p => p.locations)
                .HasForeignKey(d => d.business_id)
                .HasConstraintName("fk_locations_business");
        });

        modelBuilder.Entity<notification>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_notifications");

            entity.ToTable("notifications", "communication");

            entity.HasIndex(e => new { e.user_id, e.is_read }, "ix_notifications_unread");

            entity.HasIndex(e => e.user_id, "ix_notifications_user_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.is_read).HasDefaultValue(false);
            entity.Property(e => e.title).HasMaxLength(255);
            entity.Property(e => e.type).HasMaxLength(50);

            entity.HasOne(d => d.appointment).WithMany(p => p.notifications)
                .HasForeignKey(d => d.appointment_id)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_notifications_appointment");

            entity.HasOne(d => d.user).WithMany(p => p.notifications)
                .HasForeignKey(d => d.user_id)
                .HasConstraintName("fk_notifications_user");
        });

        modelBuilder.Entity<notification_delivery>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_notification_deliveries");

            entity.ToTable("notification_deliveries", "communication");

            entity.HasIndex(e => e.notification_id, "ix_notification_deliveries_notification_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.channel).HasMaxLength(30);
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.status)
                .HasMaxLength(30)
                .HasDefaultValueSql("'Pending'::character varying");

            entity.HasOne(d => d.notification).WithMany(p => p.notification_deliveries)
                .HasForeignKey(d => d.notification_id)
                .HasConstraintName("fk_notification_deliveries_notification");
        });

        modelBuilder.Entity<payment>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_payments");

            entity.ToTable("payments", "payment");

            entity.HasIndex(e => e.appointment_id, "ix_payments_appointment_id");

            entity.HasIndex(e => e.status, "ix_payments_status");

            entity.HasIndex(e => e.user_id, "ix_payments_user_id");

            entity.HasIndex(e => new { e.provider, e.provider_transaction_id }, "uq_payments_provider_transaction").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.amount).HasPrecision(12, 2);
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.currency)
                .HasMaxLength(3)
                .IsFixedLength();
            entity.Property(e => e.provider).HasMaxLength(50);
            entity.Property(e => e.status)
                .HasMaxLength(30)
                .HasDefaultValueSql("'Pending'::character varying");
            entity.Property(e => e.updated_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.appointment).WithMany(p => p.payments)
                .HasForeignKey(d => d.appointment_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_payments_appointment");

            entity.HasOne(d => d.user).WithMany(p => p.payments)
                .HasForeignKey(d => d.user_id)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_payments_user");
        });

        modelBuilder.Entity<payment_method>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_payment_methods");

            entity.ToTable("payment_methods", "payment");

            entity.HasIndex(e => e.user_id, "ix_payment_methods_user_id");

            entity.HasIndex(e => new { e.provider, e.provider_payment_method_id }, "uq_payment_methods_provider_id").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.is_default).HasDefaultValue(false);
            entity.Property(e => e.provider).HasMaxLength(50);
            entity.Property(e => e.type).HasMaxLength(50);

            entity.HasOne(d => d.user).WithMany(p => p.payment_methods)
                .HasForeignKey(d => d.user_id)
                .HasConstraintName("fk_payment_methods_user");
        });

        modelBuilder.Entity<refresh_token>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_refresh_tokens");

            entity.ToTable("refresh_tokens", "auth");

            entity.HasIndex(e => e.revoked_at, "idx_auth_token_revoked_at");

            entity.HasIndex(e => e.user_id, "ix_refresh_tokens_user_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();

            entity.HasOne(d => d.user).WithMany(p => p.refresh_tokens)
                .HasForeignKey(d => d.user_id)
                .HasConstraintName("fk_refresh_tokens_user");
        });

        modelBuilder.Entity<service>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_services");

            entity.ToTable("services", "catalog");

            entity.HasIndex(e => new { e.business_id, e.name }, "ix_services_business_id_name").IsUnique();

            entity.HasIndex(e => e.category_id, "ix_services_category_id");

            entity.HasIndex(e => new { e.business_id, e.name }, "uq_services_business_name").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.currency)
                .HasMaxLength(3)
                .HasDefaultValueSql("'USD'::bpchar")
                .IsFixedLength();
            entity.Property(e => e.is_available).HasDefaultValue(true);
            entity.Property(e => e.name).HasMaxLength(200);
            entity.Property(e => e.price).HasPrecision(12, 2);
            entity.Property(e => e.updated_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.business).WithMany(p => p.services)
                .HasForeignKey(d => d.business_id)
                .HasConstraintName("fk_services_business");

            entity.HasOne(d => d.category).WithMany(p => p.services)
                .HasForeignKey(d => d.category_id)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_services_category");
        });

        modelBuilder.Entity<staff>(entity =>
        {
            entity.HasKey(e => e.id).HasName("staff_pkey");

            entity.ToTable("staff", "catalog");

            entity.HasIndex(e => e.business_id, "idx_staff_business_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.is_avilable).HasDefaultValue(true);
            entity.Property(e => e.job_title).HasMaxLength(100);

            entity.HasOne(d => d.business).WithMany(p => p.staff)
                .HasForeignKey(d => d.business_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_staff_business");
        });

        modelBuilder.Entity<user>(entity =>
        {
            entity.HasKey(e => e.id).HasName("pk_users");

            entity.ToTable("users", "auth");

            entity.HasIndex(e => e.email, "ix_users_email");

            entity.HasIndex(e => e.email, "uq_users_email").IsUnique();

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.email).HasMaxLength(320);
            entity.Property(e => e.first_name).HasMaxLength(100);
            entity.Property(e => e.is_active).HasDefaultValue(true);
            entity.Property(e => e.last_name).HasMaxLength(100);
            entity.Property(e => e.phone).HasMaxLength(30);
            entity.Property(e => e.user_role).HasMaxLength(200);
        });

        modelBuilder.Entity<user_favorite_business>(entity =>
        {
            entity.HasKey(e => e.id).HasName("user_favorite_businesses_pkey");

            entity.ToTable("user_favorite_businesses", "business");

            entity.HasIndex(e => e.business_id, "idx_user_favorite_businesses_business_id");

            entity.HasIndex(e => e.user_id, "idx_user_favorite_businesses_user_id");

            entity.Property(e => e.id).UseIdentityAlwaysColumn();
            entity.Property(e => e.created_at).HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(d => d.business).WithMany(p => p.user_favorite_businesses)
                .HasForeignKey(d => d.business_id)
                .HasConstraintName("fk_favorite_business");

            entity.HasOne(d => d.user).WithMany(p => p.user_favorite_businesses)
                .HasForeignKey(d => d.user_id)
                .HasConstraintName("fk_favorite_user");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
