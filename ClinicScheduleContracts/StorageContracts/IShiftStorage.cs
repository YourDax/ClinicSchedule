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
    public interface IShiftStorage
    {
        List<ShiftViewModel> GetFullList();

        List<ShiftViewModel> GetFilteredList(ShiftSearchModel model);

        ShiftViewModel? GetElement(ShiftSearchModel model);

        ShiftViewModel? Insert(ShiftBindingModel model);

        ShiftViewModel? Update(ShiftBindingModel model);

        ShiftViewModel? Delete(ShiftBindingModel model);
    }
}
