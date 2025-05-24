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
        IUserModel user { get; }
    }

}
