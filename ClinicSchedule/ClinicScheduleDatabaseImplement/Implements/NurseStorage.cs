using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;

namespace ClinicScheduleDatabaseImplement.Implements
{
    public class NurseStorage : INurseStorage
    {
        public NurseViewModel? Delete(NurseBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Nurses.FirstOrDefault(rec => rec.id == model.id);

            if (element != null)
            {
                context.Nurses.Remove(element);
                context.SaveChanges();
                return element.GetViewModel;
            }

            return null;
        }

        public NurseViewModel? GetElement(NurseSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Nurses.AsQueryable();

            if (model.id.HasValue)
            {
                query = query.Where(x => x.id == model.id);
            }
            else if (!string.IsNullOrEmpty(model.login) && !string.IsNullOrEmpty(model.password))
            {
                query = query.Where(x => x.login == model.login && x.password == model.password);
            }
            else
            {
                return null;
            }

            return query.FirstOrDefault()?.GetViewModel;
        }


        public List<NurseViewModel> GetFilteredList(NurseSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Nurses.AsQueryable();

            if (!string.IsNullOrWhiteSpace(model.fullname))
            {
                query = query.Where(x => x.fullname.Contains(model.fullname));
            }

            return query.Select(x => x.GetViewModel).ToList();
        }

        public List<NurseViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();

            return context.Nurses
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public NurseViewModel? Insert(NurseBindingModel model)
        {
            var newNurse = Nurse.Create(model);
            if (newNurse == null)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();
            context.Nurses.Add(newNurse);
            context.SaveChanges();

            return newNurse.GetViewModel;
        }

        public NurseViewModel? Update(NurseBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var nurse = context.Nurses.FirstOrDefault(x => x.id == model.id);
            if (nurse == null)
            {
                return null;
            }

            nurse.Update(model);
            context.SaveChanges();

            return nurse.GetViewModel;
        }
    }
}
