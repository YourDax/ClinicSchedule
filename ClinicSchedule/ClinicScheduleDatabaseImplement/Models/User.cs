using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class User : IUserModel
    {
        public int id { get; private set; }

        [Required]
        public string login { get; set; } = string.Empty;

        [Required]
        public string password { get; set; } = string.Empty;

        [Required]
        public string fullname { get; set; } = string.Empty;

        public DateTime birthdate { get; set; } = new();

        public string phoneNumber { get; set; } = string.Empty;

        public List<DateTime> vacationDates { get; set; } = new();

        public Roles role { get; set; } = Roles.Admin;

        public double workedHours { get; set; }

        public static User? Create(UserBindingModel model)
        {
            if (model == null) return null;
            return new User
            {
                id = model.id,
                login = model.login,
                password = model.password,
                fullname = model.fullname,
                birthdate = model.birthdate,
                phoneNumber = model.phoneNumber,
                vacationDates = model.vacationDates,
                role = model.role,
                workedHours = model.workedHours
            };
        }

        public void Update(UserBindingModel model)
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
        }

        public UserViewModel GetViewModel => new()
        {
            id = id,
            login = login,
            password = password,
            fullname = fullname,
            birthdate = birthdate,
            phoneNumber = phoneNumber,
            vacationDates = vacationDates,
            role = role,
            workedHours = workedHours
        };
    }
}
