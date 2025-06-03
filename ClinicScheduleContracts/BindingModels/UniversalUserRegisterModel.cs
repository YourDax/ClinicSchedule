using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class UniversalUserRegisterModel
    {
        public string login { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;
        public string fullname { get; set; } = string.Empty;
        public DateTime birthdate { get; set; }
        public string phoneNumber { get; set; } = string.Empty;
        public List<DateTime> vacationDates { get; set; } = new();
        public Roles role { get; set; }

        // Только для докторов и медсестёр
        public int? departmentId { get; set; }

        // Только для докторов
        public int? experienceYears { get; set; }
        // Только для медсестер
        public string specialization {  get; set; } = string.Empty ;
    }
}
