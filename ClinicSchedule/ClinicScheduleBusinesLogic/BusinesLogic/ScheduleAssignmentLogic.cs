using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ClinicScheduleBusinessLogic.BusinessLogic
{
    public class ScheduleAssignmentLogic : IScheduleAssignmentLogic
    {
        private readonly ILogger<ScheduleAssignmentLogic> _logger;
        private readonly IScheduleAssignmentStorage _assignmentStorage;
        private readonly IDoctorStorage _doctorStorage;
        private readonly INurseStorage _nurseStorage;

        public ScheduleAssignmentLogic(
            ILogger<ScheduleAssignmentLogic> logger,
            IScheduleAssignmentStorage assignmentStorage,
            IDoctorStorage doctorStorage,
            INurseStorage nurseStorage)
        {
            _logger = logger;
            _assignmentStorage = assignmentStorage;
            _doctorStorage = doctorStorage;
            _nurseStorage = nurseStorage;
        }

        public List<ScheduleAssignmentViewModel>? ReadList(ScheduleAssignmentSearchModel? model)
        {
            _logger.LogInformation("ReadList ScheduleAssignment");
            var list = model == null ? _assignmentStorage.GetFullList() : _assignmentStorage.GetFilteredList(model);
            if (list == null)
            {
                _logger.LogWarning("ReadList returned null");
                return null;
            }
            _logger.LogInformation("ReadList count: {Count}", list.Count);
            return list;
        }

        public ScheduleAssignmentViewModel? ReadElement(ScheduleAssignmentSearchModel model)
        {
            if (model == null) throw new ArgumentNullException(nameof(model));
            _logger.LogInformation("ReadElement ScheduleAssignment with id: {Id}", model.id);
            var element = _assignmentStorage.GetElement(model);
            if (element == null)
            {
                _logger.LogWarning("ReadElement: not found");
                return null;
            }
            return element;
        }

        public bool AddAssignment(ScheduleAssignmentBindingModel model, double shiftDurationHours)
        {
            CheckModel(model);

            // Проверяем, что такого назначения ещё нет (scheduleId + shiftId + staffId + role уникальны)
            var existing = _assignmentStorage.GetFilteredList(new ScheduleAssignmentSearchModel
            {
                scheduleId = model.scheduleId,
                shiftId = model.shiftId,
                staffId = model.staffId,
                role = model.role
            });
            if (existing != null && existing.Any())
            {
                _logger.LogWarning("AddAssignment: Assignment already exists");
                return false;
            }

            // Добавляем назначение
            var result = _assignmentStorage.Insert(model);
            if (result == null)
            {
                _logger.LogWarning("AddAssignment: Insert failed");
                return false;
            }

            // Увеличиваем workedHours у доктора или медсестры
            UpdateWorkedHours(model.staffId, model.role, shiftDurationHours, addHours: true);

            _logger.LogInformation("AddAssignment: Assignment added successfully");
            return true;
        }

        public bool RemoveAssignment(ScheduleAssignmentBindingModel model, double shiftDurationHours)
        {
            CheckModel(model, false);

            var existing = _assignmentStorage.GetFilteredList(new ScheduleAssignmentSearchModel
            {
                id = model.id
            })?.FirstOrDefault();

            if (existing == null)
            {
                _logger.LogWarning("RemoveAssignment: Assignment not found");
                return false;
            }

            var result = _assignmentStorage.Delete(new ScheduleAssignmentBindingModel { id = model.id });
            if (result == null)
            {
                _logger.LogWarning("RemoveAssignment: Delete failed");
                return false;
            }

            // Уменьшаем workedHours
            UpdateWorkedHours(existing.staffId, existing.role, shiftDurationHours, addHours: false);

            _logger.LogInformation("RemoveAssignment: Assignment removed successfully");
            return true;
        }

        private void UpdateWorkedHours(int staffId, Roles role, double hours, bool addHours)
        {
            if (role == Roles.Doctor)
            {
                var doctor = _doctorStorage.GetElement(new DoctorSearchModel { id = staffId });
                if (doctor != null)
                {
                    var workedHours = addHours ? doctor.workedHours + hours : doctor.workedHours - hours;
                    if (workedHours < 0) workedHours = 0;
                    _doctorStorage.Update(new DoctorBindingModel
                    {
                        id = doctor.id,
                        login = doctor.login,
                        password = doctor.password,
                        fullname = doctor.fullname,
                        birthdate = doctor.birthdate,
                        phoneNumber = doctor.phoneNumber,
                        specialization = doctor.specialization,
                        experienceYears = doctor.experienceYears,
                        departmentId = doctor.departmentId,
                        workedHours = workedHours,
                        vacationDates = doctor.vacationDates
                    });
                }
            }
            else if (role == Roles.Nurse)
            {
                var nurse = _nurseStorage.GetElement(new NurseSearchModel { id = staffId });
                if (nurse != null)
                {
                    var workedHours = addHours ? nurse.workedHours + hours : nurse.workedHours - hours;
                    if (workedHours < 0) workedHours = 0;
                    _nurseStorage.Update(new NurseBindingModel
                    {
                        id = nurse.id,
                        login = nurse.login,
                        password = nurse.password,
                        fullname = nurse.fullname,
                        birthdate = nurse.birthdate,
                        phoneNumber = nurse.phoneNumber,
                        specialization = nurse.specialization,
                        departmentId = nurse.departmentId,
                        workedHours = workedHours,
                        vacationDates = nurse.vacationDates
                    });
                }
            }
        }

        private void CheckModel(ScheduleAssignmentBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (model.scheduleId <= 0)
                throw new ArgumentException("ScheduleId должен быть положительным", nameof(model.scheduleId));
            if (model.shiftId <= 0)
                throw new ArgumentException("ShiftId должен быть положительным", nameof(model.shiftId));
            if (model.staffId <= 0)
                throw new ArgumentException("StaffId должен быть положительным", nameof(model.staffId));
        }
    }
}
