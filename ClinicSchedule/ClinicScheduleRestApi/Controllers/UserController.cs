using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ClinicRestApi.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class UserController : Controller
    {
        private readonly ILogger _logger;
        private readonly IUserLogic _userLogic;
        private readonly IDoctorLogic _doctorLogic;
        private readonly INurseLogic _nurseLogic;

        public UserController(IUserLogic userLogic, IDoctorLogic doctorLogic, INurseLogic nurseLogic, ILogger<UserController> logger)
        {
            _logger = logger;
            _userLogic = userLogic;
            _doctorLogic = doctorLogic;
            _nurseLogic = nurseLogic;
        }

        [HttpPost]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            try
            {
                var doctor = _doctorLogic.ReadElement(new DoctorSearchModel
                {
                    login = request.login,
                    password = request.password
                });
                if (doctor != null) return Ok(doctor);

                var nurse = _nurseLogic.ReadElement(new NurseSearchModel
                {
                    login = request.login,
                    password = request.password
                });
                if (nurse != null) return Ok(nurse);

                var admin = _userLogic.ReadElement(new UserSearchModel
                {
                    login = request.login,
                    password = request.password
                });
                if (admin != null) return Ok(admin);

                return NotFound("Пользователь с такими данными не найден");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Login error");
                return StatusCode(500, "Ошибка сервера");
            }
        }



        [HttpPost]
        public void Register([FromBody] UniversalUserRegisterModel model)
        {
            try
            {
                switch (model.role)
                {
                    case Roles.Nurse:
                        if (!model.departmentId.HasValue)
                            throw new ArgumentException("departmentId обязателен для медсестры");
                        _nurseLogic.Create(new NurseBindingModel
                        {
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            departmentId = model.departmentId.Value,
                            specialization = model.specialization,
                            workedHours = 0
                        });
                        break;

                    case Roles.Doctor:
                        if (!model.departmentId.HasValue || !model.experienceYears.HasValue)
                            throw new ArgumentException("departmentId и experienceYears обязательны для доктора");
                        _doctorLogic.Create(new DoctorBindingModel
                        {
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            departmentId = model.departmentId.Value,
                            experienceYears = model.experienceYears.Value,
                            workedHours = 0
                        });
                        break;

                    case Roles.Admin:
                        _userLogic.Create(new UserBindingModel
                        {
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            workedHours = 0
                        });
                        break;

                    default:
                        throw new InvalidOperationException("Неизвестная роль");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Register error");
                throw;
            }
        }


        [HttpPost]
        public void UpdateData([FromBody] UniversalUserUpdateModel model)
        {
            try
            {
                switch (model.role)
                {
                    case Roles.Nurse:
                        if (!model.departmentId.HasValue)
                            throw new ArgumentException("departmentId обязателен для медсестры");
                        _nurseLogic.Update(new NurseBindingModel
                        {
                            id = model.id,
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            workedHours = model.workedHours,
                            departmentId = model.departmentId.Value
                        });
                        break;

                    case Roles.Doctor:
                        if (!model.departmentId.HasValue || !model.experienceYears.HasValue)
                            throw new ArgumentException("departmentId и experienceYears обязательны для доктора");
                        _doctorLogic.Update(new DoctorBindingModel
                        {
                            id = model.id,
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            workedHours = model.workedHours,
                            departmentId = model.departmentId.Value,
                            experienceYears = model.experienceYears.Value
                        });
                        break;

                    case Roles.Admin:
                        _userLogic.Update(new UserBindingModel
                        {
                            id = model.id,
                            login = model.login,
                            password = model.password,
                            fullname = model.fullname,
                            birthdate = model.birthdate,
                            phoneNumber = model.phoneNumber,
                            vacationDates = model.vacationDates,
                            workedHours = model.workedHours
                        });
                        break;

                    default:
                        throw new InvalidOperationException("Неизвестная роль пользователя");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Update error");
                throw;
            }
        }



        [HttpGet]
        public IActionResult GetById(int id, int role)
        {
            try
            {
                var userRole = (Roles)role;

                return userRole switch
                {
                    Roles.Nurse => Ok(_nurseLogic.ReadElement(new NurseSearchModel { id = id })),
                    Roles.Doctor => Ok(_doctorLogic.ReadElement(new DoctorSearchModel { id = id })),
                    Roles.Admin => Ok(_userLogic.ReadElement(new UserSearchModel { id = id })),
                    _ => BadRequest("Неизвестная роль")
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetById error");
                return StatusCode(500, "Ошибка сервера");
            }
        }
    }
}
