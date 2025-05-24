using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleModels.Models
{
    public interface IDoctorModel :IUserModel
    {
        int experienceYears { get; }
        int departmentId { get; }

    }
}
