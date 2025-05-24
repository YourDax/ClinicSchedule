using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.ViewModels
{
    public class ScheduleAssignmentViewModel : IScheduleAssignmentModel
    {
        public int id { get; set; }

        [DisplayName("ID расписания")]
        public int scheduleId { get; set; }

        [DisplayName("ID смены")]
        public int shiftId { get; set; }

        [DisplayName("Пользователь")]
        public IUserModel user { get; set; }
    }
}
