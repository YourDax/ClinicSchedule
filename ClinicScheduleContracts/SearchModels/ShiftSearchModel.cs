using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class ShiftSearchModel
    {
        public int? id { get; set; }
        public int? departmentId { get; set; }
        public int? scheduleId { get; set; }
        public DateTime? date { get; set; }
    }

}
