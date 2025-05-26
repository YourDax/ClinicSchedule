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
    public class UserStorage : IUserStorage
    {
        public UserViewModel? Delete(UserBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Users.FirstOrDefault(x => x.id == model.id);
            if (element != null)
            {
                context.Users.Remove(element);
                context.SaveChanges();
                return element.GetViewModel;
            }

            return null;
        }

        public UserViewModel? GetElement(UserSearchModel model)
        {
            if (!model.id.HasValue) return null;

            using var context = new ClinicScheduleDatabase();

            return context.Users.FirstOrDefault(x => x.id == model.id.Value)?.GetViewModel;
        }

        public List<UserViewModel> GetFilteredList(UserSearchModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var query = context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(model?.login))
                query = query.Where(x => x.login.Contains(model.login));

            if (model?.role != null)
                query = query.Where(x => x.role == model.role);

            return query.Select(x => x.GetViewModel).ToList();
        }

        public List<UserViewModel> GetFullList()
        {
            using var context = new ClinicScheduleDatabase();

            return context.Users.Select(x => x.GetViewModel).ToList();
        }

        public UserViewModel? Insert(UserBindingModel model)
        {
            var element = User.Create(model);
            if (element == null) return null;

            using var context = new ClinicScheduleDatabase();

            context.Users.Add(element);
            context.SaveChanges();

            return element.GetViewModel;
        }

        public UserViewModel? Update(UserBindingModel model)
        {
            using var context = new ClinicScheduleDatabase();

            var element = context.Users.FirstOrDefault(x => x.id == model.id);
            if (element == null) return null;

            element.Update(model);
            context.SaveChanges();

            return element.GetViewModel;
        }
    }
}
