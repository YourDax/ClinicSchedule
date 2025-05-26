using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;

namespace ClinicScheduleDatabaseImplement.Implements
{
    public class DoctorStorage : IDoctorStorage
    {
        public DoctorViewModel? Delete(DoctorBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Doctors.FirstOrDefault(rec => rec.id == model.id);

            if (element != null)
            {
                context.Doctors.Remove(element);
                context.SaveChanges();
                return element.GetViewModel;
            }

            return null;
        }

        public DoctorViewModel? GetElement(DoctorSearchModel model)
        {
            if (!model.id.HasValue)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();

            return context.Doctors
                .FirstOrDefault(x => x.id == model.id)?.GetViewModel;
        }

        public List<DoctorViewModel> GetFilteredList(DoctorSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Doctors.AsQueryable();

            if (!string.IsNullOrWhiteSpace(model.fullname))
            {
                query = query.Where(x => x.fullname.Contains(model.fullname));
            }

            return query.Select(x => x.GetViewModel).ToList();
        }

        public List<DoctorViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();

            return context.Doctors
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public DoctorViewModel? Insert(DoctorBindingModel model)
        {
            var newDoctor = Doctor.Create(model);
            if (newDoctor == null)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();
            context.Doctors.Add(newDoctor);
            context.SaveChanges();

            return newDoctor.GetViewModel;
        }

        public DoctorViewModel? Update(DoctorBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var doctor = context.Doctors.FirstOrDefault(x => x.id == model.id);
            if (doctor == null)
            {
                return null;
            }

            doctor.Update(model);
            context.SaveChanges();

            return doctor.GetViewModel;
        }
    }
}
