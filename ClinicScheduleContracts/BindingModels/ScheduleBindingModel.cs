using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class ScheduleBindingModel : IScheduleModel
    {
        public int id { get; set; }
        public DateTime date { get; set; }
        public int departmentId { get; set; }
        public List<ShiftBindingModel> shifts { get; set; } = new();
        List<IShiftModel> IScheduleModel.shifts => shifts.Cast<IShiftModel>().ToList();
        public Dictionary<int, List<IDoctorModel>> shiftDoctors { get; set; } = new();
        public Dictionary<int, List<INurseModel>> shiftNurses { get; set; } = new();
        public List<ScheduleAssignmentBindingModel> assignments { get; set; } = new();
    }

}
