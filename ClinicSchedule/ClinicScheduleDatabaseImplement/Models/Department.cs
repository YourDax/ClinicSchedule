using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Models;
using System.ComponentModel.DataAnnotations;

namespace ClinicScheduleDatabaseImplement.Models
{
    public class Department : IDepartmentModel
    {
        public int id { get; private set; }

        [Required]
        public string name { get; set; } = string.Empty;

        public static Department? Create(DepartmentBindingModel model)
        {
            if (model == null) return null;
            return new Department
            {
                id = model.id,
                name = model.name
            };
        }

        public void Update(DepartmentBindingModel model)
        {
            if (model == null) return;
            name = model.name;
        }

        public DepartmentViewModel GetViewModel => new()
        {
            id = id,
            name = name
        };
    }
}
