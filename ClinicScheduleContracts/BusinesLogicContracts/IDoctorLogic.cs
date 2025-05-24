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
    public interface IDoctorLogic
    {
        List<DoctorViewModel>? ReadList(DoctorSearchModel? searchModel);
        DoctorViewModel? ReadElement(DoctorSearchModel searchModel);
        bool Create(DoctorBindingModel model);
        bool Update(DoctorBindingModel model);
        bool Delete(DoctorBindingModel model);
    }
}
