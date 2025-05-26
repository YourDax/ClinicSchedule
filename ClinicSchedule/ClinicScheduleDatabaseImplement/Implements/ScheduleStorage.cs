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
            var query = context.Schedules
                .Include(x => x.shiftEntities)
                .Include(x => x.assignments)
                .AsQueryable();

            if (model.departmentId.HasValue)
            {
                query = query.Where(x => x.departmentId == model.departmentId.Value);
            }

            if (model.date.HasValue)
            {
                query = query.Where(x => x.date == model.date.Value);
            }

            return query.ToList().Select(x => x.GetViewModel).ToList();
        }
    }
}
