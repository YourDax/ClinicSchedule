using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class UserBindingModel : IUserModel
    {
        public int id { get; set; }
        public string login { get; set; }
        public string password { get; set; }
        public string fullname { get; set; }
        public DateTime birthdate { get; set; }
        public string phoneNumber { get; set; }
        public List<DateTime> vacationDates { get; set; } = new();
        public Roles role { get; set; }
        public double workedHours { get; set; }
    }
}
