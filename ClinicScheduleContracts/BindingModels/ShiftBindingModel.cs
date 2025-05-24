using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class ShiftBindingModel : IShiftModel
    {
        public int id { get; set; }
        public DateTime startTime { get; set; }
        public DateTime endTime { get; set; }
        public int requiredDoctors { get; set; }
        public int requiredNurses { get; set; }
        public int departmentId { get; set; }

        public double durationHours => (endTime - startTime).TotalHours;
    }

}
