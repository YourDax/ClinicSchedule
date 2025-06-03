using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class DoctorSearchModel
    {
        public int? id { get; set; }
        public string? login { get; set; }
        public string? fullname { get; set; }
        public string? password { get; set; }
        public string? specialization { get; set; }
        public int? departmentId { get; set; }
    }

}
