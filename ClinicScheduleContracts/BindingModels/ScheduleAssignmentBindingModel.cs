using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class ScheduleAssignmentBindingModel : IScheduleAssignmentModel
    {
        public int id { get; set; }
        public int scheduleId { get; set; }
        public int shiftId { get; set; }
        public IUserModel user { get; set; }
    }

}
