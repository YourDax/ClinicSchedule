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
    public class ScheduleAssignmentViewModel : IScheduleAssignmentModel
    {
        public int id { get; set; }

        [DisplayName("ID расписания")]
        public int scheduleId { get; set; }

        [DisplayName("ID смены")]
        public int shiftId { get; set; }

        [DisplayName("ID рабочего")]
        public int staffId { get; set; }
        public Roles role { get; set; }
        public string fullName { get; set; }
        public string roleName => role == Roles.Doctor ? "Доктор" : "Медсестра";

        // Этот метод можно реализовать в логике, подгружая нужного пользователя по role и staffId
        IUserModel IScheduleAssignmentModel.user => throw new NotImplementedException();
    }
}
