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
    public interface IDepartmentLogic
    {
        List<DepartmentViewModel>? ReadList(DepartmentSearchModel? searchModel);
        DepartmentViewModel? ReadElement(DepartmentSearchModel searchModel);
        bool Create(DepartmentBindingModel model);
        bool Update(DepartmentBindingModel model);
        bool Delete(DepartmentBindingModel model);
    }
}
