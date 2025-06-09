using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;

namespace ClinicScheduleDatabaseImplement.Implements
{
    public class ScheduleStorage : IScheduleStorage
    {
        public ScheduleViewModel? Insert(ScheduleBindingModel model)
        {
            var newSchedule = Schedule.Create(model);
            if (newSchedule == null)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();
            context.Schedules.Add(newSchedule);
            context.SaveChanges();
            return newSchedule.GetViewModel;
        }

        public ScheduleViewModel? Update(ScheduleBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();
            var schedule = context.Schedules
                .Include(x => x.shiftEntities)
                .Include(x => x.assignments)
                .FirstOrDefault(x => x.id == model.id);
            if (schedule == null)
            {
                return null;
            }

            schedule.Update(model);
            context.SaveChanges();
            return schedule.GetViewModel;
        }

        public ScheduleViewModel? Delete(ScheduleBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();
            var schedule = context.Schedules
                .Include(x => x.shiftEntities)
                .Include(x => x.assignments)
                .FirstOrDefault(x => x.id == model.id);

            if (schedule != null)
            {
                // Удаляем связанные назначения
                if (schedule.assignments != null)
                {
                    context.ScheduleAssignments.RemoveRange(schedule.assignments);
                }

                // Удаляем связанные смены
                if (schedule.shiftEntities != null)
                {
                    context.Shifts.RemoveRange(schedule.shiftEntities);
                }

                // Удаляем само расписание
                context.Schedules.Remove(schedule);

                context.SaveChanges();
                return schedule.GetViewModel;
            }

            return null;
        }


        public ScheduleViewModel? GetElement(ScheduleSearchModel model)
        {
            if (!model.id.HasValue)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();
            return context.Schedules
                .Include(x => x.shiftEntities)
                .Include(x => x.assignments)
                .FirstOrDefault(x => x.id == model.id)?.GetViewModel;
        }

        public List<ScheduleViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();
            return context.Schedules
                .Include(x => x.shiftEntities)
                .Include(x => x.assignments)
                .ToList()
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public List<ScheduleViewModel> GetFilteredList(ScheduleSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();
            return context.Schedules
                .Where(s =>
                    (!model.id.HasValue || s.id == model.id) &&
                    (!model.departmentId.HasValue || s.departmentId == model.departmentId) &&
                    (!model.date.HasValue || s.date == model.date) &&
                    (!model.startDateFrom.HasValue || s.date >= model.startDateFrom.Value) &&
                    (!model.startDateTo.HasValue || s.date <= model.startDateTo.Value))
                .Select(s => new ScheduleViewModel
                {
                    id = s.id,
                    departmentId = s.departmentId,
                    date = s.date
                })
                .ToList();
        }

    }
}
