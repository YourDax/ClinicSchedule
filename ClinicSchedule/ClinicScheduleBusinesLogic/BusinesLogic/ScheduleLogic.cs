using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using Microsoft.Extensions.Logging;

namespace ClinicScheduleBusinessLogic.BusinessLogic
{
    public class ScheduleLogic : IScheduleLogic
    {
        private readonly ILogger _logger;
        private readonly IScheduleStorage _scheduleStorage;
        private readonly IShiftStorage _shiftStorage;
        private readonly IDoctorStorage _doctorStorage;
        private readonly INurseStorage _nurseStorage;

        public ScheduleLogic(
            ILogger<ScheduleLogic> logger,
            IScheduleStorage scheduleStorage,
            IShiftStorage shiftStorage,
            IDoctorStorage doctorStorage,
            INurseStorage nurseStorage)
        {
            _logger = logger;
            _scheduleStorage = scheduleStorage;
            _shiftStorage = shiftStorage;
            _doctorStorage = doctorStorage;
            _nurseStorage = nurseStorage;
        }

        public List<ScheduleViewModel>? ReadList(ScheduleSearchModel? model)
        {
            _logger.LogInformation("ReadList. DepartmentId: {DepartmentId}, Date: {Date}", model?.departmentId, model?.date);
            var list = model == null
                ? _scheduleStorage.GetFullList()
                : _scheduleStorage.GetFilteredList(model);

            if (list == null)
            {
                _logger.LogWarning("ReadList вернул null");
                return null;
            }

            _logger.LogInformation("ReadList. Count: {Count}", list.Count);
            return list;
        }

        public ScheduleViewModel? ReadElement(ScheduleSearchModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            _logger.LogInformation("ReadElement. Id: {Id}, Date: {Date}", model.id, model.date);
            var element = _scheduleStorage.GetElement(model);

            if (element == null)
            {
                _logger.LogWarning("Расписание не найдено");
                return null;
            }

            _logger.LogInformation("Расписание найдено. Id: {Id}", element.id);
            return element;
        }

        public bool Create(ScheduleBindingModel model)
        {
            CheckModel(model);

            // Проверка — не дублируем расписание
            var existing = _scheduleStorage.GetFilteredList(new()
            {
                departmentId = model.departmentId,
                date = model.date.Date
            })?.FirstOrDefault();

            if (existing != null)
            {
                _logger.LogWarning("Расписание уже существует для этой даты и департамента");
                return false;
            }

            // Получаем докторов и медсестёр
            var doctors = _doctorStorage.GetFilteredList(new() { departmentId = model.departmentId });
            var nurses = _nurseStorage.GetFilteredList(new() { departmentId = model.departmentId });

            if (doctors.Count == 0 || nurses.Count == 0)
            {
                throw new InvalidOperationException("Нельзя создать расписание без доступных врачей и медсестёр");
            }

            // Для назначений
            var assignments = new List<ScheduleAssignmentBindingModel>();

            // Обрабатываем смены
            foreach (var shiftInput in model.shifts)
            {
                var existingShift = _shiftStorage.GetFilteredList(new() { departmentId = model.departmentId })
                    .FirstOrDefault(s => s.startTime == shiftInput.startTime && s.endTime == shiftInput.endTime);

                var shiftId = existingShift?.id ?? _shiftStorage.Insert(new ShiftBindingModel
                {
                    startTime = shiftInput.startTime,
                    endTime = shiftInput.endTime,
                    requiredDoctors = shiftInput.requiredDoctors,
                    requiredNurses = shiftInput.requiredNurses,
                    departmentId = model.departmentId
                })!.id;

                // Назначаем первого доступного врача и медсестру (или по логике — любых подходящих)
                assignments.Add(new ScheduleAssignmentBindingModel
                {
                    shiftId = shiftId,
                    staffId = doctors.First().id,
                    role = Roles.Doctor
                });
                assignments.Add(new ScheduleAssignmentBindingModel
                {
                    shiftId = shiftId,
                    staffId = nurses.First().id,
                    role = Roles.Nurse
                });

                _logger.LogInformation("Созданы назначения для смены {Start}-{End}", shiftInput.startTime, shiftInput.endTime);
            }

            // Создаём расписание с назначениями
            var result = _scheduleStorage.Insert(new ScheduleBindingModel
            {
                date = model.date.Date,
                departmentId = model.departmentId,
                assignments = assignments
            });

            if (result == null)
            {
                _logger.LogWarning("Ошибка при создании расписания");
                return false;
            }

            _logger.LogInformation("Создано расписание на {Date} для департамента {DepartmentId}", model.date, model.departmentId);
            return true;
        }

        public bool Update(ScheduleBindingModel model)
        {
            CheckModel(model);
            if (_scheduleStorage.Update(model) == null)
            {
                _logger.LogWarning("Не удалось обновить расписание");
                return false;
            }
            return true;
        }

        public bool Delete(ScheduleBindingModel model)
        {
            CheckModel(model, false);
            _logger.LogInformation("Удаление расписания. Id: {Id}", model.id);
            if (_scheduleStorage.Delete(model) == null)
            {
                _logger.LogWarning("Удаление не удалось");
                return false;
            }
            return true;
        }

        private void CheckModel(ScheduleBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (model.departmentId <= 0)
                throw new ArgumentException("Не задан департамент", nameof(model.departmentId));

            if (model.date == default)
                throw new ArgumentException("Не указана дата", nameof(model.date));

            if (model.shifts == null || model.shifts.Count == 0)
                throw new ArgumentException("Не указаны смены", nameof(model.shifts));
        }
        public bool GenerateSchedule(int departmentId, List<DateTime> dates)
        {
            if (dates == null || dates.Count == 0)
                throw new ArgumentException("Список дат не может быть пустым");

            var shiftsTemplate = new[]
            {
                new { StartHour = 8, EndHour = 16, RequiredDoctors = 2, RequiredNurses = 4 },
                new { StartHour = 16, EndHour = 24, RequiredDoctors = 2, RequiredNurses = 4 }
            };

            foreach (var date in dates)
            {
                var existingSchedule = _scheduleStorage.GetFilteredList(new() { departmentId = departmentId, date = date }).FirstOrDefault();
                if (existingSchedule != null)
                {
                    _logger.LogInformation($"Расписание на {date:dd.MM.yyyy} для департамента {departmentId} уже существует");
                    continue;
                }

                // Создаём смены, если они ещё не созданы
                var existingShifts = _shiftStorage.GetFilteredList(new() { departmentId = departmentId })
                                    .Where(s => dates.Any(d => s.startTime.Date == d.Date))
                                    .ToList();

                foreach (var st in shiftsTemplate)
                {
                    var shiftExists = existingShifts.Any(s =>
                        s.startTime.Hour == st.StartHour &&
                        s.endTime.Hour == st.EndHour &&
                        s.startTime.Date == date.Date);

                    if (!shiftExists)
                    {
                        _shiftStorage.Insert(new ShiftBindingModel
                        {
                            startTime = date.Date.AddHours(st.StartHour),
                            endTime = date.Date.AddHours(st.EndHour),
                            requiredDoctors = st.RequiredDoctors,
                            requiredNurses = st.RequiredNurses,
                            departmentId = departmentId
                        });
                    }
                }

                // Обновим список смен после возможных добавлений
                var shifts = _shiftStorage.GetFilteredList(new() { departmentId = departmentId })
                             .Where(s => s.startTime.Date == date.Date).ToList();

                // Выбираем доступных докторов и медсестер, исключая тех, кто в отпуске на эту дату
                var doctors = _doctorStorage.GetFilteredList(new() { departmentId = departmentId })
                    .Where(d => d.vacationDates == null || !d.vacationDates.Contains(date.Date))
                    .OrderBy(d => d.workedHours)
                    .ToList();

                var nurses = _nurseStorage.GetFilteredList(new() { departmentId = departmentId })
                    .Where(n => n.vacationDates == null || !n.vacationDates.Contains(date.Date))
                    .OrderBy(n => n.workedHours)
                    .ToList();

                var assignments = new List<ScheduleAssignmentBindingModel>();

                // Для отслеживания занятых сотрудников на дату
                var assignedDoctorIds = new HashSet<int>();
                var assignedNurseIds = new HashSet<int>();

                foreach (var shift in shifts)
                {
                    // ДОКТОРА на смену
                    var availableDoctors = doctors
                        .Where(d => !assignedDoctorIds.Contains(d.id))
                        .Take(shift.requiredDoctors)
                        .ToList();

                    foreach (var doc in availableDoctors)
                    {
                        assignments.Add(new ScheduleAssignmentBindingModel
                        {
                            shiftId = shift.id,
                            staffId = doc.id,
                            role = Roles.Doctor
                        });

                        assignedDoctorIds.Add(doc.id); // помечаем как занятого
                        doc.workedHours += shift.durationHours;

                        var doctorFromDb = _doctorStorage.GetElement(new DoctorSearchModel { id = doc.id });
                        if (doctorFromDb != null)
                        {
                            _doctorStorage.Update(new DoctorBindingModel
                            {
                                id = doctorFromDb.id,
                                login = doctorFromDb.login,
                                password = doctorFromDb.password,
                                fullname = doctorFromDb.fullname,
                                birthdate = doctorFromDb.birthdate,
                                phoneNumber = doctorFromDb.phoneNumber,
                                experienceYears = doctorFromDb.experienceYears,
                                departmentId = doctorFromDb.departmentId,
                                workedHours = doc.workedHours
                            });
                        }
                    }

                    // МЕДСЁСТРЫ на смену
                    var availableNurses = nurses
                        .Where(n => !assignedNurseIds.Contains(n.id))
                        .Take(shift.requiredNurses)
                        .ToList();

                    foreach (var nurse in availableNurses)
                    {
                        assignments.Add(new ScheduleAssignmentBindingModel
                        {
                            shiftId = shift.id,
                            staffId = nurse.id,
                            role = Roles.Nurse
                        });

                        assignedNurseIds.Add(nurse.id); // помечаем как занятую
                        nurse.workedHours += shift.durationHours;

                        var nurseFromDb = _nurseStorage.GetElement(new NurseSearchModel { id = nurse.id });
                        if (nurseFromDb != null)
                        {
                            _nurseStorage.Update(new NurseBindingModel
                            {
                                id = nurseFromDb.id,
                                login = nurseFromDb.login,
                                password = nurseFromDb.password,
                                fullname = nurseFromDb.fullname,
                                birthdate = nurseFromDb.birthdate,
                                phoneNumber = nurseFromDb.phoneNumber,
                                specialization = nurseFromDb.specialization,
                                departmentId = nurseFromDb.departmentId,
                                workedHours = nurse.workedHours
                            });
                        }
                    }
                }


                // Создаём расписание без назначений
                var newSchedule = _scheduleStorage.Insert(new ScheduleBindingModel
                {
                    date = date,
                    departmentId = departmentId
                });

                if (newSchedule == null)
                {
                    _logger.LogWarning($"Не удалось создать расписание на {date:dd.MM.yyyy} для департамента {departmentId}");
                    continue;
                }

                // Привязываем назначения к расписанию
                foreach (var assignment in assignments)
                {
                    assignment.scheduleId = newSchedule.id;
                }

                // Обновляем расписание с назначениями
                _scheduleStorage.Update(new ScheduleBindingModel
                {
                    id = newSchedule.id,
                    date = date,
                    departmentId = departmentId,
                    assignments = assignments
                });

                _logger.LogInformation($"Создано расписание на {date:dd.MM.yyyy} для департамента {departmentId}");
            }

            return true;
        }


    }
}
