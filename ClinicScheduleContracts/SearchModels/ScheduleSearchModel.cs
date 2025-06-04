using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class ScheduleSearchModel
    {
        public int? id { get; set; }
        public int? departmentId { get; set; }
        public DateTime? date { get; set; }
        public DateTime? startDateFrom { get; set; }
        public DateTime? startDateTo { get; set; }
    }

}
