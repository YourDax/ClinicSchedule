using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class ScheduleAssignmentSearchModel
    {
        public int? id { get; set; }
        public int? scheduleId { get; set; }
        public int? shiftId { get; set; }
        public int? staffId { get; set; }
        public Roles? role { get; set; }
    }

}
