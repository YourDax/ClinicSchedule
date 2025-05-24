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
    public interface INurseStorage
    {
        List<NurseViewModel> GetFullList();

        List<NurseViewModel> GetFilteredList(NurseSearchModel model);

        NurseViewModel? GetElement(NurseSearchModel model);

        NurseViewModel? Insert(NurseBindingModel model);

        NurseViewModel? Update(NurseBindingModel model);

        NurseViewModel? Delete(NurseBindingModel model);
    }
}
