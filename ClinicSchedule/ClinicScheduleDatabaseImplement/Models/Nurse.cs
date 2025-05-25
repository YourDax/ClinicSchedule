using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class Nurse : INurseModel
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

        public Roles role { get; set; } = Roles.Nurse;

        public double workedHours { get; set; }

        public int departmentId { get; set; }

        public string specialization { get; set; } = string.Empty;

        public static Nurse? Create(NurseBindingModel model)
        {
            if (model == null) return null;
            return new Nurse
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
                specialization = model.specialization
            };
        }

        public void Update(NurseBindingModel model)
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
            specialization = model.specialization;
        }

        public NurseViewModel GetViewModel => new()
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
            specialization = specialization
        };
    }
}
