using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleModels.Models
{
    public interface IShiftModel : IId
    {
        DateTime startTime { get; }
        DateTime endTime { get; }

        // Автоматически вычисляемое значение
        double durationHours { get; }

        // Требуемое количество докторов и медсестёр на смену
        int requiredDoctors { get;  }
        int requiredNurses { get; }

        int departmentId { get; }
    }
}
