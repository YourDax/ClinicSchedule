using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class NurseSearchModel
    {
        public int? id { get; set; }
        public string? fullname { get; set; }
        public string? specialization { get; set; }
        public int? departmentId { get; set; }
    }

}
