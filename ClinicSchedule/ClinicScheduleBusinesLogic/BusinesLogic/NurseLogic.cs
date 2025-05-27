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
    public class NurseLogic : INurseLogic
    {
        private readonly ILogger _logger;
        private readonly INurseStorage _nurseStorage;

        public NurseLogic(ILogger<NurseLogic> logger, INurseStorage nurseStorage)
        {
            _logger = logger;
            _nurseStorage = nurseStorage;
        }

        public List<NurseViewModel>? ReadList(NurseSearchModel? model)
        {
            _logger.LogInformation("ReadList. Fullname: {Fullname}, Id: {Id}", model?.fullname, model?.id);
            var list = model == null
                ? _nurseStorage.GetFullList()
                : _nurseStorage.GetFilteredList(model);

            if (list == null)
            {
                _logger.LogWarning("ReadList вернул null");
                return null;
            }

            _logger.LogInformation("ReadList. Count: {Count}", list.Count);
            return list;
        }

        public NurseViewModel? ReadElement(NurseSearchModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            _logger.LogInformation("ReadElement. Id: {Id}, Fullname: {Fullname}", model.id, model.fullname);
            var element = _nurseStorage.GetElement(model);

            if (element == null)
            {
                _logger.LogWarning("ReadElement: медсестра не найдена");
                return null;
            }

            _logger.LogInformation("ReadElement найдена. Id: {Id}", element.id);
            return element;
        }

        public bool Create(NurseBindingModel model)
        {
            CheckModel(model);
            if (_nurseStorage.Insert(model) == null)
            {
                _logger.LogWarning("Create не удалось");
                return false;
            }
            return true;
        }

        public bool Update(NurseBindingModel model)
        {
            CheckModel(model);
            if (_nurseStorage.Update(model) == null)
            {
                _logger.LogWarning("Update не удалось");
                return false;
            }
            return true;
        }

        public bool Delete(NurseBindingModel model)
        {
            CheckModel(model, false);
            _logger.LogInformation("Delete. Id: {Id}", model.id);
            if (_nurseStorage.Delete(model) == null)
            {
                _logger.LogWarning("Delete не удалось");
                return false;
            }
            return true;
        }

        private void CheckModel(NurseBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (string.IsNullOrEmpty(model.fullname))
                throw new ArgumentException("ФИО медсестры не указано", nameof(model.fullname));

            if (string.IsNullOrEmpty(model.specialization))
                throw new ArgumentException("Специализация не указана", nameof(model.specialization));

            if (model.experienceYears < 0)
                throw new ArgumentException("Стаж не может быть отрицательным", nameof(model.experienceYears));

            if (model.birthdate > DateTime.Now)
                throw new ArgumentException("Дата рождения не может быть в будущем", nameof(model.birthdate));

            _logger.LogInformation("Проверка медсестры: Fullname={Fullname}, Id={Id}", model.fullname, model.id);

            var existing = _nurseStorage.GetFilteredList(new NurseSearchModel
            {
                fullname = model.fullname
            })?.FirstOrDefault(n => n.id != model.id);

            if (existing != null)
            {
                throw new InvalidOperationException("Медсестра с таким ФИО уже существует");
            }
        }
    }
}
