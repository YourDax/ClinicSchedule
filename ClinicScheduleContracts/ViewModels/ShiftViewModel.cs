using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.ViewModels
{
    public class ShiftViewModel : IShiftModel
    {
        public int id { get; set; }

        [DisplayName("Время начала")]
        public DateTime startTime { get; set; }

        [DisplayName("Время окончания")]
        public DateTime endTime { get; set; }

        [DisplayName("Требуемое количество докторов")]
        public int requiredDoctors { get; set; }

        [DisplayName("Требуемое количество медсестёр")]
        public int requiredNurses { get; set; }

        [DisplayName("ID отделения")]
        public int departmentId { get; set; }

        public double durationHours => (endTime - startTime).TotalHours;
    }

}
