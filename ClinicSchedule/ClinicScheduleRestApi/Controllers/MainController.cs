using ClinicScheduleBusinessLogic.BusinessLogic;
using ClinicScheduleBusinessLogic.Logic;
using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.RequestModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ClinicRestApi.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class MainController : Controller
    {
        private readonly ILogger _logger;
        private readonly IDepartmentLogic _department;
        private readonly IDoctorLogic _doctor;
        private readonly INurseLogic _nurse;
        private readonly IShiftLogic _shift;
        private readonly IScheduleLogic _schedule;
        private readonly IScheduleAssignmentLogic _scheduleAssignment;
        private readonly IUserLogic _user;

        public MainController(ILogger<MainController> logger, IDepartmentLogic department, IDoctorLogic doctor,
            INurseLogic nurse, IShiftLogic shift, IScheduleLogic schedule, IUserLogic user, IScheduleAssignmentLogic scheduleAssignment)
        {
            _logger = logger;
            _department = department;
            _doctor = doctor;
            _nurse = nurse;
            _shift = shift;
            _schedule = schedule;
            _user = user;
            _scheduleAssignment = scheduleAssignment;
        }
        /// <summary>
        /// Doctors
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public List<DoctorViewModel>? GetDoctorList()
        {
            try
            {
                return _doctor.ReadList(null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error get list Doctor");
                throw;
            }
        }
        [HttpGet]
        public DoctorViewModel? GetDoctorById(int doctorId)
        {
            try
            {
                return _doctor.ReadElement(new DoctorSearchModel { id = doctorId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting doctor by id={Id}", doctorId);
                throw;
            }
        }

        [HttpPost]
        public void CreateDoctor(DoctorBindingModel model)
        {
            try
            {
                _doctor.Create(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error create Doctor");
                throw;
            }
        }

        [HttpPost]
        public void UpdateDoctor(DoctorBindingModel model)
        {
            try
            {
                _doctor.Update(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error update Doctor");
                throw;
            }
        }

        [HttpPost]
        public void DeleteDoctor(DoctorBindingModel model)
        {
            try
            {
                _doctor.Delete(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error delete Doctor");
                throw;
            }
        }
        /// <summary>
        /// Nurses
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public List<NurseViewModel>? GetNurseList()
        {
            try
            {
                return _nurse.ReadList(null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error get list Nurse");
                throw;
            }
        }
        [HttpGet]
        public NurseViewModel? GetNurseById(int nurseId)
        {
            try
            {
                return _nurse.ReadElement(new NurseSearchModel { id = nurseId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting nurse by id={Id}", nurseId);
                throw;
            }
        }

        [HttpPost]
        public void CreateNurse(NurseBindingModel model)
        {
            try
            {
                _nurse.Create(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error create Nurse");
                throw;
            }
        }

        [HttpPost]
        public void UpdateNurse(NurseBindingModel model)
        {
            try
            {
                _nurse.Update(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error update Nurse");
                throw;
            }
        }

        [HttpPost]
        public void DeleteNurse(NurseBindingModel model)
        {
            try
            {
                _nurse.Delete(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error delete Nurse");
                throw;
            }
        }
        /// <summary>
        /// Departments
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public List<DepartmentViewModel>? GetDepartmentList()
        {
            try
            {
                return _department.ReadList(null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error get list Department");
                throw;
            }
        }
        [HttpGet]
        public DepartmentViewModel? GetDepartmentById(int departmentId)
        {
            try
            {
                return _department.ReadElement(new DepartmentSearchModel { id = departmentId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting department by id={Id}", departmentId);
                throw;
            }
        }
        [HttpPost]
        public void CreateDepartment(DepartmentBindingModel model)
        {
            try
            {
                _department.Create(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка создания департамента");
                throw;
            }
        }

        [HttpPost]
        public void UpdateDepartment(DepartmentBindingModel model)
        {
            try
            {
                _department.Update(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка обновления департамента");
                throw;
            }
        }

        [HttpPost]
        public void DeleteDepartment(DepartmentBindingModel model)
        {
            try
            {
                _department.Delete(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка удаления департамента");
                throw;
            }
        }
        /// <summary>
        /// Shifts
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public List<ShiftViewModel>? GetShiftList()
        {
            try
            {
                return _shift.ReadList(null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка получения списка смен");
                throw;
            }
        }
        [HttpGet]
        public ShiftViewModel? GetShiftById(int id)
        {
            try
            {
                return _shift.ReadElement(new ShiftSearchModel { id = id });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка получения смены по id={id}", id);
                throw;
            }
        }
        [HttpPost]
        public void CreateShift(ShiftBindingModel model)
        {
            try
            {
                _shift.Create(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка создания смены");
                throw;
            }
        }

        [HttpPost]
        public void UpdateShift(ShiftBindingModel model)
        {
            try
            {
                _shift.Update(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка обновления смены");
                throw;
            }
        }

        [HttpPost]
        public void DeleteShift(ShiftBindingModel model)
        {
            try
            {
                _shift.Delete(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка удаления смены");
                throw;
            }
        }
        /// <summary>
        /// Schedule
        /// </summary>
        /// <param name="model"></param>
        [HttpPost]
        public void CreateSchedule(ScheduleBindingModel model)
        {
            try
            {
                _schedule.Create(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error create Schedule");
                throw;
            }
        }
        [HttpPost]
        public void UpdateSchedule(ScheduleBindingModel model)
        {
            try
            {
                _schedule.Update(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating schedule");
                throw;
            }
        }

        [HttpPost]
        public void DeleteSchedule(ScheduleBindingModel model)
        {
            try
            {
                _schedule.Delete(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting schedule");
                throw;
            }
        }

        [HttpGet]
        public List<ScheduleViewModel>? GetScheduleList(int departmentId)
        {
            try
            {
                return _schedule.ReadList(new ScheduleSearchModel { departmentId = departmentId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error get list Schedule");
                throw;
            }
        }
        [HttpGet]
        public ScheduleViewModel? GetScheduleById(int scheduleId)
        {
            try
            {
                return _schedule.ReadElement(new ScheduleSearchModel { id = scheduleId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting schedule by id={Id}", scheduleId);
                throw;
            }
        }

        [HttpGet]
        public List<ScheduleViewModel> GetForUser(int userId, string role, DateTime startDate, DateTime endDate)
        {
            if (string.IsNullOrEmpty(role))
                return new List<ScheduleViewModel>();

            int? staffId = null;
            int targetRole = -1;

            if (role.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
            {
                var doctor = _doctor.ReadElement(new DoctorSearchModel { id = userId });
                if (doctor == null) return new List<ScheduleViewModel>();
                staffId = doctor.id;
                targetRole = 1;
            }
            else if (role.Equals("Nurse", StringComparison.OrdinalIgnoreCase))
            {
                var nurse = _nurse.ReadElement(new NurseSearchModel { id = userId });
                if (nurse == null) return new List<ScheduleViewModel>();
                staffId = nurse.id;
                targetRole = 0;
            }
            else
            {
                return new List<ScheduleViewModel>();
            }

            var schedules = _schedule.ReadList(new ScheduleSearchModel
            {
                startDateFrom = startDate,
                startDateTo = endDate
            });

            var allAssignments = _scheduleAssignment.ReadList(null);

            var result = new List<ScheduleViewModel>();

            foreach (var schedule in schedules)
            {
                // Назначения в этом дне
                var scheduleAssignments = allAssignments
                    .Where(a => a.scheduleId == schedule.id)
                    .ToList();
                Roles roleEnum = (Roles)targetRole;
                // Находим смены, в которых участвует текущий пользователь
                var userShifts = scheduleAssignments
                    .Where(a => a.staffId == staffId && a.role == roleEnum)
                    .Select(a => a.shiftId)
                    .Distinct()
                    .ToList();

                if (!userShifts.Any())
                    continue;

                // Отбираем все назначения в этих же сменах
                var relatedAssignments = scheduleAssignments
                    .Where(a => userShifts.Contains(a.shiftId))
                    .ToList();

                var detailedAssignments = new List<ScheduleAssignmentViewModel>();

                foreach (var assignment in relatedAssignments)
                {
                    string name = "";
                    if (assignment.role == Roles.Doctor) // Доктор
                    {
                        var doc = _doctor.ReadElement(new DoctorSearchModel { id = assignment.staffId });
                        name = doc?.fullname ?? "(неизвестный доктор)";
                    }
                    else if (assignment.role == Roles.Nurse) // Медсестра
                    {
                        var nurse = _nurse.ReadElement(new NurseSearchModel { id = assignment.staffId });
                        name = nurse?.fullname ?? "(неизвестная медсестра)";
                    }

                    detailedAssignments.Add(new ScheduleAssignmentViewModel
                    {
                        id = assignment.id,
                        scheduleId = assignment.scheduleId,
                        shiftId = assignment.shiftId,
                        staffId = assignment.staffId,
                        role = assignment.role,
                        fullName = name
                    });
                }

                result.Add(new ScheduleViewModel
                {
                    id = schedule.id,
                    date = schedule.date,
                    departmentId = schedule.departmentId,
                    assignments = detailedAssignments
                });
            }

            return result;
        }

        [HttpGet]
        public List<ScheduleViewModel> GetForDepartment(int departmentId, DateTime startDate, DateTime endDate)
        {
            var schedules = _schedule.ReadList(new ScheduleSearchModel
            {
                departmentId = departmentId,
                startDateFrom = startDate,
                startDateTo = endDate
            });

            var allAssignments = _scheduleAssignment.ReadList(null);

            var result = new List<ScheduleViewModel>();

            foreach (var schedule in schedules)
            {
                var scheduleAssignments = allAssignments
                    .Where(a => a.scheduleId == schedule.id)
                    .ToList();

                var detailedAssignments = new List<ScheduleAssignmentViewModel>();

                foreach (var assignment in scheduleAssignments)
                {
                    string name = "";
                    if (assignment.role == Roles.Doctor)
                    {
                        var doc = _doctor.ReadElement(new DoctorSearchModel { id = assignment.staffId });
                        name = doc?.fullname ?? "(неизвестный доктор)";
                    }
                    else if (assignment.role == Roles.Nurse)
                    {
                        var nurse = _nurse.ReadElement(new NurseSearchModel { id = assignment.staffId });
                        name = nurse?.fullname ?? "(неизвестная медсестра)";
                    }

                    detailedAssignments.Add(new ScheduleAssignmentViewModel
                    {
                        id = assignment.id,
                        scheduleId = assignment.scheduleId,
                        shiftId = assignment.shiftId,
                        staffId = assignment.staffId,
                        role = assignment.role,
                        fullName = name
                    });
                }

                // Получаем уникальные shiftId из назначений для текущего расписания
                var uniqueShiftIds = scheduleAssignments
                    .Select(a => a.shiftId)
                    .Distinct()
                    .ToList();

                // Загружаем смены по shiftId
                var shifts = new List<ShiftViewModel>();
                foreach (var shiftId in uniqueShiftIds)
                {
                    var shift = _shift.ReadElement(new ShiftSearchModel { id = shiftId });
                    if (shift != null)
                        shifts.Add(shift);
                }

                // Считаем суммарное требуемое количество докторов и медсестёр
                int totalRequiredDoctors = shifts.Any() ? shifts.Max(s => s.requiredDoctors) : 0;
                int totalRequiredNurses = shifts.Any() ? shifts.Max(s => s.requiredNurses) : 0;


                result.Add(new ScheduleViewModel
                {
                    id = schedule.id,
                    date = schedule.date,
                    departmentId = schedule.departmentId,
                    assignments = detailedAssignments,
                    requiredDoctors = totalRequiredDoctors,
                    requiredNurses = totalRequiredNurses
                });
            }

            return result;
        }

        [HttpGet]
        public ScheduleViewModel? GetByDateAndDepartment(int departmentId, DateTime date)
        {
            var schedules = _schedule.ReadList(new ScheduleSearchModel
            {
                departmentId = departmentId,
                startDateFrom = date,
                startDateTo = date
            });

            var schedule = schedules.FirstOrDefault();
            if (schedule == null)
                return null;

            var allAssignments = _scheduleAssignment.ReadList(null)
                .Where(a => a.scheduleId == schedule.id)
                .ToList();

            var detailedAssignments = new List<ScheduleAssignmentViewModel>();

            foreach (var assignment in allAssignments)
            {
                string name = "";
                if (assignment.role == Roles.Doctor)
                {
                    var doc = _doctor.ReadElement(new DoctorSearchModel { id = assignment.staffId });
                    name = doc?.fullname ?? "(неизвестный доктор)";
                }
                else if (assignment.role == Roles.Nurse)
                {
                    var nurse = _nurse.ReadElement(new NurseSearchModel { id = assignment.staffId });
                    name = nurse?.fullname ?? "(неизвестная медсестра)";
                }

                detailedAssignments.Add(new ScheduleAssignmentViewModel
                {
                    id = assignment.id,
                    scheduleId = assignment.scheduleId,
                    shiftId = assignment.shiftId,
                    staffId = assignment.staffId,
                    role = assignment.role,
                    fullName = name
                });
            }

            var uniqueShiftIds = allAssignments
                .Select(a => a.shiftId)
                .Distinct()
                .ToList();

            var shifts = new List<ShiftViewModel>();
            foreach (var shiftId in uniqueShiftIds)
            {
                var shift = _shift.ReadElement(new ShiftSearchModel { id = shiftId });
                if (shift != null)
                    shifts.Add(shift);
            }

            int totalRequiredDoctors = shifts.Any() ? shifts.Max(s => s.requiredDoctors) : 0;
            int totalRequiredNurses = shifts.Any() ? shifts.Max(s => s.requiredNurses) : 0;

            return new ScheduleViewModel
            {
                id = schedule.id,
                date = schedule.date,
                departmentId = schedule.departmentId,
                assignments = detailedAssignments,
                requiredDoctors = totalRequiredDoctors,
                requiredNurses = totalRequiredNurses
            };
        }

        [HttpGet]
        public List<ShiftViewModel> GetShiftsByDateAndDepartment(int departmentId, DateTime date)
        {
            var allShifts = _shift.ReadList(new ShiftSearchModel
            {
                departmentId = departmentId
            });

            return allShifts
                .Where(s => s.startTime.Date == date.Date)
                .ToList();
        }
        [HttpPost]
        public bool AddAssignment([FromBody] ScheduleAssignmentBindingModel model)
        {
            try
            {
                return _scheduleAssignment.AddAssignment(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding schedule assignment");
                throw;
            }
        }
        [HttpPost]
        public bool RemoveAssignment([FromBody] ScheduleAssignmentBindingModel model)
        {
            try
            {
                return _scheduleAssignment.RemoveAssignment(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing schedule assignment");
                throw;
            }
        }



        [HttpPost]
        public bool GenerateSchedule([FromBody] GenerateScheduleRequest request)
        {
            try
            {
                return _schedule.GenerateSchedule(request.departmentId, request.dates);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating schedule");
                throw;
            }
        }
        [HttpGet]
        public List<DoctorViewModel> GetDoctorsByDepartment(int departmentId)
        {
            try
            {
                var model = new DoctorSearchModel { departmentId = departmentId };
                var list = _doctor.ReadList(model);
                return list ?? new List<DoctorViewModel>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка получения докторов для departmentId={departmentId}", departmentId);
                throw;
            }
        }

        [HttpGet]
        public List<NurseViewModel> GetNursesByDepartment(int departmentId)
        {
            try
            {
                var model = new NurseSearchModel { departmentId = departmentId };
                var list = _nurse.ReadList(model);
                return list ?? new List<NurseViewModel>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка получения медсестёр для departmentId={departmentId}", departmentId);
                throw;
            }
        }


    }
}
