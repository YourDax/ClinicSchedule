using ClinicScheduleBusinessLogic.BusinessLogic;
using ClinicScheduleBusinessLogic.Logic;
using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.RequestModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
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
        public List<ScheduleViewModel> GetForUser(int id, DateTime startDate, DateTime endDate)
        {
            var user = _user.ReadElement(new UserSearchModel { id = id });
            if (user == null)
            {
                return new List<ScheduleViewModel>();
            }

            // Получаем doctorId или nurseId
            var doctor = _doctor.ReadElement(new DoctorSearchModel { id = id });
            var nurse = _nurse.ReadElement(new NurseSearchModel { id = id });

            var doctorId = doctor?.id;
            var nurseId = nurse?.id;

            // Получаем все расписания в заданном диапазоне
            var schedules = _schedule.ReadList(new ScheduleSearchModel
            {
                startDateFrom = startDate,
                startDateTo = endDate
            });

            // Получаем все назначения
            var assignments = _scheduleAssignment.ReadList(null);

            // Фильтруем назначения, относящиеся к этому пользователю
            var userAssignments = assignments
                .Where(x => (doctorId.HasValue && x.staffId == doctorId) ||
                            (nurseId.HasValue && x.staffId == nurseId))
                .ToList();

            // Собираем расписания с назначениями, в которых участвует пользователь
            var result = new List<ScheduleViewModel>();
            foreach (var schedule in schedules)
            {
                // Выбираем только те назначения, которые соответствуют текущему расписанию
                var scheduleAssignments = userAssignments
                    .Where(a => a.scheduleId == schedule.id)
                    .ToList();

                if (scheduleAssignments.Count == 0)
                    continue;

                result.Add(new ScheduleViewModel
                {
                    id = schedule.id,
                    date = schedule.date,
                    departmentId = schedule.departmentId,
                    assignments = scheduleAssignments.Select(a => new ScheduleAssignmentViewModel
                    {
                        id = a.id,
                        scheduleId = a.scheduleId,
                        shiftId = a.shiftId,
                        staffId = a.staffId,
                        role = a.role
                    }).ToList()
                });
            }

            return result;
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

    }
}
