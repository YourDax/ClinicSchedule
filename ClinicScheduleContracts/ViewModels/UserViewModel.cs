using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.ViewModels
{
    public class UserViewModel : IUserModel
    {
        public int id { get; set; }

        [DisplayName("Логин")]
        public string login { get; set; } = string.Empty;

        [DisplayName("Пароль")]
        public string password { get; set; } = string.Empty;

        [DisplayName("ФИО")]
        public string fullname { get; set; } = string.Empty;

        [DisplayName("Дата рождения")]
        public DateTime birthdate { get; set; }

        [DisplayName("Телефон")]
        public string phoneNumber { get; set; } = string.Empty;

        [DisplayName("Даты отпуска")]
        public List<DateTime> vacationDates { get; set; } = new();

        [DisplayName("Роль")]
        public Roles role { get; set; }

        [DisplayName("Отработанные часы")]
        public double workedHours { get; set; }
    }
}
