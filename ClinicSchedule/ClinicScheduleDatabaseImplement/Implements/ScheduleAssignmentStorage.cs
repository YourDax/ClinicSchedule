using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;

namespace ClinicScheduleDatabaseImplement.Implements
{
    public class ScheduleAssignmentStorage : IScheduleAssignmentStorage
    {
        public List<ScheduleAssignmentViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();
            return context.ScheduleAssignments
                .ToList()
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public List<ScheduleAssignmentViewModel> GetFilteredList(ScheduleAssignmentSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();
            return context.ScheduleAssignments
                .Where(x =>
                    (!model.id.HasValue || x.id == model.id.Value) &&
                    (!model.scheduleId.HasValue || x.scheduleId == model.scheduleId.Value) &&
                    (!model.shiftId.HasValue || x.shiftId == model.shiftId.Value) &&
                    (!model.staffId.HasValue || x.staffId == model.staffId.Value) &&
                    (!model.role.HasValue || x.role == model.role.Value))
                .ToList()
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public ScheduleAssignmentViewModel? GetElement(ScheduleAssignmentSearchModel model)
        {
            if (!model.id.HasValue) return null;

            using var context = new ClinicScheduleDatabase();
            var assignment = context.ScheduleAssignments
                .FirstOrDefault(x => x.id == model.id.Value);

            return assignment?.GetViewModel;
        }

        public ScheduleAssignmentViewModel? Insert(ScheduleAssignmentBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();
            var newAssignment = ScheduleAssignment.Create(model);
            if (newAssignment == null)
                return null;

            context.ScheduleAssignments.Add(newAssignment);
            context.SaveChanges();

            return newAssignment.GetViewModel;
        }

        public ScheduleAssignmentViewModel? Delete(ScheduleAssignmentBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();
            var assignment = context.ScheduleAssignments
                .FirstOrDefault(x => x.id == model.id);

            if (assignment == null)
                return null;

            context.ScheduleAssignments.Remove(assignment);
            context.SaveChanges();

            return assignment.GetViewModel;
        }
    }
}
