using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Models;
using Microsoft.EntityFrameworkCore;

namespace ClinicScheduleDatabaseImplement.Implements
{
    public class DepartmentStorage : IDepartmentStorage
    {
        public DepartmentViewModel? Delete(DepartmentBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Departments.FirstOrDefault(rec => rec.id == model.id);
            if (element != null)
            {
                context.Departments.Remove(element);
                context.SaveChanges();
                return element.GetViewModel;
            }

            return null;
        }

        public DepartmentViewModel? GetElement(DepartmentSearchModel model)
        {
            if (!model.id.HasValue)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();

            return context.Departments
                .FirstOrDefault(x => x.id == model.id)?.GetViewModel;
        }

        public List<DepartmentViewModel> GetFilteredList(DepartmentSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Departments.AsQueryable();

            if (!string.IsNullOrWhiteSpace(model.name))
            {
                query = query.Where(x => x.name.Contains(model.name));
            }

            return query.Select(x => x.GetViewModel).ToList();
        }

        public List<DepartmentViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();

            return context.Departments
                .Select(x => x.GetViewModel)
                .ToList();
        }

        public DepartmentViewModel? Insert(DepartmentBindingModel model)
        {
            var newDepartment = Department.Create(model);
            if (newDepartment == null)
            {
                return null;
            }

            using var context = new ClinicScheduleDatabase();
            context.Departments.Add(newDepartment);
            context.SaveChanges();

            return newDepartment.GetViewModel;
        }

        public DepartmentViewModel? Update(DepartmentBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var department = context.Departments.FirstOrDefault(x => x.id == model.id);
            if (department == null)
            {
                return null;
            }

            department.Update(model);
            context.SaveChanges();

            return department.GetViewModel;
        }
    }
}
