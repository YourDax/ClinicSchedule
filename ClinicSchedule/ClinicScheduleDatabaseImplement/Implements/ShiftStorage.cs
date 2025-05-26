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
    public class ShiftStorage : IShiftStorage
    {
        public ShiftViewModel? Delete(ShiftBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Shifts.FirstOrDefault(rec => rec.id == model.id);
            if (element != null)
            {
                context.Shifts.Remove(element);
                context.SaveChanges();
                return element.GetViewModel;
            }

            return null;
        }

        public ShiftViewModel? GetElement(ShiftSearchModel model)
        {
            if (!model.id.HasValue)
                return null;

            using var context = new ClinicScheduleDatabase();

            return context.Shifts
                .FirstOrDefault(x => x.id == model.id)
                ?.GetViewModel;
        }

        public List<ShiftViewModel> GetFilteredList(ShiftSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Shifts.AsQueryable();

            if (model.departmentId.HasValue)
                query = query.Where(x => x.departmentId == model.departmentId.Value);

            if (model.id.HasValue)
                query = query.Where(x => x.id == model.id.Value);

            return query.Select(x => x.GetViewModel).ToList();
        }


        public List<ShiftViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();

            return context.Shifts
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public ShiftViewModel? Insert(ShiftBindingModel model)
        {
            var newShift = Shift.Create(model);
            if (newShift == null)
                return null;

            using var context = new ClinicScheduleDatabase();

            context.Shifts.Add(newShift);
            context.SaveChanges();

            return newShift.GetViewModel;
        }

        public ShiftViewModel? Update(ShiftBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var shift = context.Shifts.FirstOrDefault(x => x.id == model.id);
            if (shift == null)
                return null;

            shift.Update(model);
            context.SaveChanges();

            return shift.GetViewModel;
        }
    }
}
