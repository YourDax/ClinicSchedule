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
        public int? Id { get; set; }

        public string? Login { get; set; }

        public Roles? Role { get; set; }

        public string? Fullname { get; set; }

        public string? PhoneNumber { get; set; }
    }
}
