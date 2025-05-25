using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class Doctor : IDoctorModel
    {
        public int id { get; private set; }

        [Required]
        public string login { get; set; } = string.Empty;

        [Required]
        public string password { get; set; } = string.Empty;

        [Required]
        public string fullname { get; set; } = string.Empty;

        public DateTime birthdate { get; set; }

        public string phoneNumber { get; set; } = string.Empty;

        public List<DateTime> vacationDates { get; set; } = new();

        public Roles role { get; set; } = Roles.Doctor;

        public double workedHours { get; set; }

        public int departmentId { get; set; }

        public int experienceYears { get; set; }

        public static Doctor? Create(DoctorBindingModel model)
        {
            if (model == null) return null;
            return new Doctor
            {
                id = model.id,
                login = model.login,
                password = model.password,
                fullname = model.fullname,
                birthdate = model.birthdate,
                phoneNumber = model.phoneNumber,
                vacationDates = model.vacationDates,
                role = model.role,
                workedHours = model.workedHours,
                departmentId = model.departmentId,
                experienceYears = model.experienceYears
            };
        }

        public void Update(DoctorBindingModel model)
        {
            if (model == null) return;
            login = model.login;
            password = model.password;
            fullname = model.fullname;
            birthdate = model.birthdate;
            phoneNumber = model.phoneNumber;
            vacationDates = model.vacationDates;
            role = model.role;
            workedHours = model.workedHours;
            departmentId = model.departmentId;
            experienceYears = model.experienceYears;
        }

        public DoctorViewModel GetViewModel => new()
        {
            id = id,
            login = login,
            password = password,
            fullname = fullname,
            birthdate = birthdate,
            phoneNumber = phoneNumber,
            vacationDates = vacationDates,
            workedHours = workedHours,
            departmentId = departmentId,
            experienceYears = experienceYears
        };
    }
}
