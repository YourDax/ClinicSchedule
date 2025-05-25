using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleModels.Models
{
    public interface IScheduleAssignmentModel : IId
    {
        int scheduleId { get; }
        int shiftId { get; }

        int staffId { get; }         // ID назначенного сотрудника (Doctor или Nurse)
        Roles role { get; }          // Роль назначенного сотрудника

        IUserModel? user { get; }    // Связанная сущность пользователя (может быть null или реализована через логику)
    }

}
