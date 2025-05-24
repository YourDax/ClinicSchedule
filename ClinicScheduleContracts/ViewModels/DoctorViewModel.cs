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
    public class DoctorViewModel : IDoctorModel
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
        public Roles role => Roles.Doctor;

        [DisplayName("Отработанные часы")]
        public double workedHours { get; set; }

        [DisplayName("Стаж (лет)")]
        public int experienceYears { get; set; }

        [DisplayName("ID отделения")]
        public int departmentId { get; set; }

        [DisplayName("Специализация")]
        public string specialization { get; set; } = string.Empty;
    }
}
