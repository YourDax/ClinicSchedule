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
    public interface INurseLogic
    {
        List<NurseViewModel>? ReadList(NurseSearchModel? searchModel);
        NurseViewModel? ReadElement(NurseSearchModel searchModel);
        bool Create(NurseBindingModel model);
        bool Update(NurseBindingModel model);
        bool Delete(NurseBindingModel model);
    }
}
