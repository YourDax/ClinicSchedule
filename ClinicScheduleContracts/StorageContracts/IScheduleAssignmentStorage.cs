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
    public interface IScheduleAssignmentStorage
    {
        List<ScheduleAssignmentViewModel> GetFullList();

        List<ScheduleAssignmentViewModel> GetFilteredList(ScheduleAssignmentSearchModel model);

        ScheduleAssignmentViewModel? GetElement(ScheduleAssignmentSearchModel model);

        ScheduleAssignmentViewModel? Insert(ScheduleAssignmentBindingModel model);

        ScheduleAssignmentViewModel? Delete(ScheduleAssignmentBindingModel model);
    }
}
