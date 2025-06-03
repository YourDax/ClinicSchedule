using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class UniversalUserUpdateModel
    {
        public int id { get; set; }
        public string login { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;
        public string fullname { get; set; } = string.Empty;
        public DateTime birthdate { get; set; }
        public string phoneNumber { get; set; } = string.Empty;
        public List<DateTime> vacationDates { get; set; } = new();
        public double workedHours { get; set; }
        public Roles role { get; set; }

        // Только для doctor/nurse
        public int? departmentId { get; set; }

        // Только для doctor
        public int? experienceYears { get; set; }
    }

}
