using ClinicScheduleContracts.BindingModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.RequestModels
{
    public class AssignmentRequest
    {
        public ScheduleAssignmentBindingModel model { get; set; } = null!;
        public double shiftDurationHours { get; set; }
    }
}
