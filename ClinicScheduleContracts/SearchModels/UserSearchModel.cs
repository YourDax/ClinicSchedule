using ClinicScheduleModels.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClinicScheduleContracts.SearchModels
{
    public class UserSearchModel
    {
        public int? id { get; set; }

        public string? login { get; set; }

        public Roles? role { get; set; }

        public string? fullname { get; set; }
        public string? password { get; set; }

        public string? phoneNumber { get; set; }
    }
}
