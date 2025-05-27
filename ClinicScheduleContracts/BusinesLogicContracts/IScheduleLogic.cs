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
    public interface IScheduleLogic
    {
        List<ScheduleViewModel>? ReadList(ScheduleSearchModel? searchModel);
        ScheduleViewModel? ReadElement(ScheduleSearchModel searchModel);
        bool Create(ScheduleBindingModel model);
        bool Update(ScheduleBindingModel model);
        bool Delete(ScheduleBindingModel model);

        bool GenerateSchedule(int departmentId, List<DateTime> dates);
    }
}
