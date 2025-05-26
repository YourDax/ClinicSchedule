using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ClinicScheduleModels.Models;
using System.Collections.Generic;
using System.ComponentModel;

namespace ClinicScheduleContracts.ViewModels
{
    public class ScheduleViewModel : IScheduleModel
    {
        public int id { get; set; }

        [DisplayName("Дата расписания")]
        public DateTime date { get; set; }

        [DisplayName("ID отделения")]
        public int departmentId { get; set; }

        public List<ShiftViewModel> shiftViews { get; set; } = new();

        public List<IShiftModel> shifts => shiftViews.Cast<IShiftModel>().ToList();

        public Dictionary<int, List<IDoctorModel>> shiftDoctors { get; set; } = new();

        public Dictionary<int, List<INurseModel>> shiftNurses { get; set; } = new();

        public List<ScheduleAssignmentViewModel> assignments { get; set; } = new();
    }

}
