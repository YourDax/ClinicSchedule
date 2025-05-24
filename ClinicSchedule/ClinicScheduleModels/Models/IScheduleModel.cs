using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleModels.Models
{
    public interface IScheduleModel : IId
    {
        DateTime date { get; }
        int departmentId { get; }

        List<IShiftModel> shifts { get; }

        // Назначения: ID смены -> список сотрудников
        Dictionary<int, List<IDoctorModel>> shiftDoctors { get; }
        Dictionary<int, List<INurseModel>> shiftNurses { get; }
    }
}
