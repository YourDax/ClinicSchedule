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
    public interface IShiftLogic
    {
        List<ShiftViewModel>? ReadList(ShiftSearchModel? searchModel);
        ShiftViewModel? ReadElement(ShiftSearchModel searchModel);
        bool Create(ShiftBindingModel model);
        bool Update(ShiftBindingModel model);
        bool Delete(ShiftBindingModel model);
    }
}
