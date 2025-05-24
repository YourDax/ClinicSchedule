using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BusinesLogicContracts
{
    public interface IUserLogic
    {
        List<UserViewModel>? ReadList(UserSearchModel? searchModel);
        UserViewModel? ReadElement(UserSearchModel searchModel);
        bool Create(UserBindingModel model); // Для создания администраторов
        bool Update(UserBindingModel model);
        bool Delete(UserBindingModel model);
    }
}
