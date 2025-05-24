using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.StorageContracts
{
    public interface IDepartmentStorage
    {
        List<DepartmentViewModel> GetFullList();

        List<DepartmentViewModel> GetFilteredList(DepartmentSearchModel model);

        DepartmentViewModel? GetElement(DepartmentSearchModel model);

        DepartmentViewModel? Insert(DepartmentBindingModel model);

        DepartmentViewModel? Update(DepartmentBindingModel model);

        DepartmentViewModel? Delete(DepartmentBindingModel model);
    }
}
