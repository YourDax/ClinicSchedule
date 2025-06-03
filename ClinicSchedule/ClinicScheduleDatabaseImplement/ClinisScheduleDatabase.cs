using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace ClinicScheduleDatabaseImplement
{
    public class ClinicScheduleDatabase : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (optionsBuilder.IsConfigured == false)
            {
                optionsBuilder.UseNpgsql(@"Host=localhost;Port=5432;Database=ClinicScheduleDatabase;Username=postgres;Password=postgres");
            }

            base.OnConfiguring(optionsBuilder);

            AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
            AppContext.SetSwitch("Npgsql.DisableDateTimeInfinityConversions", true);
        }

        public virtual DbSet<User> Users { get; set; }

        public virtual DbSet<Doctor> Doctors { get; set; }

        public virtual DbSet<Nurse> Nurses { get; set; }

        public virtual DbSet<Department> Departments { get; set; }

        public virtual DbSet<Shift> Shifts { get; set; }

        public virtual DbSet<Schedule> Schedules { get; set; }

        public virtual DbSet<ScheduleAssignment> ScheduleAssignments { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Doctor>(entity =>
            {
                entity.HasIndex(e => e.login).IsUnique();
                entity.HasIndex(e => e.fullname).IsUnique();
                entity.HasIndex(e => e.phoneNumber).IsUnique();
            });

            modelBuilder.Entity<Nurse>(entity =>
            {
                entity.HasIndex(e => e.login).IsUnique();
                entity.HasIndex(e => e.fullname).IsUnique();
                entity.HasIndex(e => e.phoneNumber).IsUnique();
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(e => e.login).IsUnique();
                entity.HasIndex(e => e.fullname).IsUnique();
                entity.HasIndex(e => e.phoneNumber).IsUnique();
            });
        }
    }
}
