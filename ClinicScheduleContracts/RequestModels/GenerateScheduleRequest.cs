using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.RequestModels
{
    public class GenerateScheduleRequest
    {
        public int departmentId { get; set; }
        public List<DateTime> dates { get; set; } = new();
    }
}
