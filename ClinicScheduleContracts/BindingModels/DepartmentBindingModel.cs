using ClinicScheduleModels.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.BindingModels
{
    public class DepartmentBindingModel : IDepartmentModel
    {
        public int id { get; set; }
        public string name { get; set; }
    }

}
