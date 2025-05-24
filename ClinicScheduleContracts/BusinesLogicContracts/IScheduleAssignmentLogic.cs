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
    public interface IScheduleAssignmentLogic
    {
        List<ScheduleAssignmentViewModel>? ReadList(ScheduleAssignmentSearchModel? searchModel);
        ScheduleAssignmentViewModel? ReadElement(ScheduleAssignmentSearchModel searchModel);
        bool Create(ScheduleAssignmentBindingModel model);
        bool Delete(ScheduleAssignmentBindingModel model);
    }
}
