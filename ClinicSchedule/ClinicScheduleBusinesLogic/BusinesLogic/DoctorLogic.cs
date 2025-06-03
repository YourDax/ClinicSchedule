using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ClinicScheduleBusinessLogic.BusinessLogic
{
    public class DoctorLogic : IDoctorLogic
    {
        private readonly ILogger _logger;
        private readonly IDoctorStorage _doctorStorage;

        public DoctorLogic(ILogger<DoctorLogic> logger, IDoctorStorage doctorStorage)
        {
            _logger = logger;
            _doctorStorage = doctorStorage;
        }

        public List<DoctorViewModel>? ReadList(DoctorSearchModel? model)
        {
            _logger.LogInformation("ReadList. Fullname: {Fullname}, Id: {Id}", model?.fullname, model?.id);
            var list = model == null
                ? _doctorStorage.GetFullList()
                : _doctorStorage.GetFilteredList(model);

            if (list == null)
            {
                _logger.LogWarning("ReadList вернул null");
                return null;
            }

            _logger.LogInformation("ReadList. Count: {Count}", list.Count);
            return list;
        }

        public DoctorViewModel? ReadElement(DoctorSearchModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            _logger.LogInformation("ReadElement. Id: {Id}, Fullname: {Fullname}", model.id, model.fullname);
            var element = _doctorStorage.GetElement(model);

            if (element == null)
            {
                _logger.LogWarning("ReadElement: доктор не найден");
                return null;
            }

            _logger.LogInformation("ReadElement найден. Id: {Id}", element.id);
            return element;
        }

        public bool Create(DoctorBindingModel model)
        {
            CheckModel(model);
            if (_doctorStorage.Insert(model) == null)
            {
                _logger.LogWarning("Create не удалось");
                return false;
            }
            return true;
        }

        public bool Update(DoctorBindingModel model)
        {
            CheckModel(model);
            if (_doctorStorage.Update(model) == null)
            {
                _logger.LogWarning("Update не удалось");
                return false;
            }
            return true;
        }

        public bool Delete(DoctorBindingModel model)
        {
            CheckModel(model, false);
            _logger.LogInformation("Delete. Id: {Id}", model.id);
            if (_doctorStorage.Delete(model) == null)
            {
                _logger.LogWarning("Delete не удалось");
                return false;
            }
            return true;
        }

        private void CheckModel(DoctorBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (string.IsNullOrEmpty(model.fullname))
                throw new ArgumentException("ФИО доктора не задано", nameof(model.fullname));

            if (model.experienceYears < 0)
                throw new ArgumentException("Стаж не может быть отрицательным", nameof(model.experienceYears));

            if (model.birthdate > DateTime.Now)
                throw new ArgumentException("Дата рождения не может быть в будущем", nameof(model.birthdate));

            _logger.LogInformation("Проверка доктора: Fullname={Fullname}, Id={Id}", model.fullname, model.id);

            var existing = _doctorStorage.GetFilteredList(new DoctorSearchModel
            {
                fullname = model.fullname
            })?.FirstOrDefault(d => d.id != model.id);

            if (existing != null)
            {
                throw new InvalidOperationException("Доктор с таким ФИО уже существует");
            }
        }
    }
}
