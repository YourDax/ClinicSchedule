using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.ViewModels
{
    public class DepartmentViewModel : IDepartmentModel
    {
        public int id { get; set; }

        [DisplayName("Название отделения")]
        public string name { get; set; } = string.Empty;
    }

}
