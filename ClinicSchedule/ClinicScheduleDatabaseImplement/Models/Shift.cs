using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class Shift : IShiftModel
    {
        public int id { get; private set; }

        [Required]
        public DateTime startTime { get; set; }

        [Required]
        public DateTime endTime { get; set; }

        [Required]
        public int requiredDoctors { get; set; }

        [Required]
        public int requiredNurses { get; set; }

        [Required]
        public int departmentId { get; set; }

        public double durationHours => (endTime - startTime).TotalHours;

        public static Shift? Create(ShiftBindingModel model)
        {
            if (model == null) return null;
            return new Shift
            {
                id = model.id,
                startTime = model.startTime,
                endTime = model.endTime,
                requiredDoctors = model.requiredDoctors,
                requiredNurses = model.requiredNurses,
                departmentId = model.departmentId
            };
        }

        public void Update(ShiftBindingModel model)
        {
            if (model == null) return;
            startTime = model.startTime;
            endTime = model.endTime;
            requiredDoctors = model.requiredDoctors;
            requiredNurses = model.requiredNurses;
            departmentId = model.departmentId;
        }

        public ShiftViewModel GetViewModel => new()
        {
            id = id,
            startTime = startTime,
            endTime = endTime,
            requiredDoctors = requiredDoctors,
            requiredNurses = requiredNurses,
            departmentId = departmentId,
        };
    }
}
