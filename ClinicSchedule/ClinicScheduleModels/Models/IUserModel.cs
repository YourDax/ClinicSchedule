using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleModels.Models
{
    public interface IUserModel : IId
    {
         string login { get; }
         string password { get; }
        string fullname { get; }
        DateTime birthdate { get; }
        string phoneNumber { get; }
        List<DateTime> vacationDates { get; }
        Roles role { get; }
        double workedHours { get; }
    }
}
