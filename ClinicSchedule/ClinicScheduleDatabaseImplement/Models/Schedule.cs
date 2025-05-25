using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class Schedule : IScheduleModel
    {
        public int id { get; private set; }

        [Required]
        public DateTime date { get; set; }

        [Required]
        public int departmentId { get; set; }

        [ForeignKey("scheduleId")]
        public virtual List<Shift> shiftEntities { get; set; } = new();

        [NotMapped]
        public List<IShiftModel> shifts => shiftEntities.Cast<IShiftModel>().ToList();

        [NotMapped]
        public Dictionary<int, List<IDoctorModel>> shiftDoctors { get; set; } = new();

        [NotMapped]
        public Dictionary<int, List<INurseModel>> shiftNurses { get; set; } = new();

        public static Schedule? Create(ScheduleBindingModel model)
        {
            if (model == null) return null;
            return new Schedule
            {
                id = model.id,
                date = model.date,
                departmentId = model.departmentId
            };
        }

        public void Update(ScheduleBindingModel model)
        {
            if (model == null) return;
            date = model.date;
            departmentId = model.departmentId;
        }

        public ScheduleViewModel GetViewModel => new()
        {
            id = id,
            date = date,
            departmentId = departmentId,
            shiftViews = shiftEntities.Select(s => s.GetViewModel).ToList(),
            shiftDoctors = shiftDoctors,
            shiftNurses = shiftNurses
        };
    }
}
