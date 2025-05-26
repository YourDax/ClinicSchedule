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

        // ID сотрудника из таблицы Doctor или Nurse или User
        [Required]
        public int staffId { get; set; }

        // Роль определяет из какой таблицы брать данные
        [Required]
        public Roles role { get; set; }

        // Интерфейсное свойство — возвращает null.
        // Реальное разрешение должно происходить в сервисе.
        public IUserModel? user => null;

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
