using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class ScheduleAssignment : IScheduleAssignmentModel
    {
        public int id { get; private set; }

        [Required]
        public int scheduleId { get; set; }

        [Required]
        public int shiftId { get; set; }

        [Required]
        public int staffId { get; set; } // ID из Doctor или Nurse

        [Required]
        public Roles role { get; set; } // Nurse или Doctor

        // Реализация свойства интерфейса
        public IUserModel? user
        {
            get
            {
                // Здесь вернуть null или реализовать логику загрузки пользователя
                return null;
            }
        }

        public static ScheduleAssignment? Create(ScheduleAssignmentBindingModel model)
        {
            if (model == null) return null;
            return new ScheduleAssignment
            {
                id = model.id,
                scheduleId = model.scheduleId,
                shiftId = model.shiftId,
                staffId = model.staffId,
                role = model.role
            };
        }

        public void Update(ScheduleAssignmentBindingModel model)
        {
            if (model == null) return;
            scheduleId = model.scheduleId;
            shiftId = model.shiftId;
            staffId = model.staffId;
            role = model.role;
        }

        public ScheduleAssignmentViewModel GetViewModel => new()
        {
            id = id,
            scheduleId = scheduleId,
            shiftId = shiftId,
            staffId = staffId,
            role = role
        };
    }

}
