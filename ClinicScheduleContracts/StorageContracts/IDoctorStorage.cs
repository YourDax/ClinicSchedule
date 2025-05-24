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
    public interface IDoctorStorage
    {
        List<DoctorViewModel> GetFullList();

        List<DoctorViewModel> GetFilteredList(DoctorSearchModel model);

        DoctorViewModel? GetElement(DoctorSearchModel model);

        DoctorViewModel? Insert(DoctorBindingModel model);

        DoctorViewModel? Update(DoctorBindingModel model);

        DoctorViewModel? Delete(DoctorBindingModel model);
    }
}
