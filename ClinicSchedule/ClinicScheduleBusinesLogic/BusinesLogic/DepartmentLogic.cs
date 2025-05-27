using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using Microsoft.Extensions.Logging;

namespace ClinicScheduleBusinessLogic.BusinessLogic
{
    public class DepartmentLogic : IDepartmentLogic
    {
        private readonly ILogger _logger;
        private readonly IDepartmentStorage _departmentStorage;

        public DepartmentLogic(ILogger<DepartmentLogic> logger, IDepartmentStorage departmentStorage)
        {
            _logger = logger;
            _departmentStorage = departmentStorage;
        }

        public List<DepartmentViewModel>? ReadList(DepartmentSearchModel? model)
        {
            _logger.LogInformation("ReadList. Name: {Name}, Id: {Id}", model?.name, model?.id);
            var list = model == null
                ? _departmentStorage.GetFullList()
                : _departmentStorage.GetFilteredList(model);

            if (list == null)
            {
                _logger.LogWarning("ReadList returned null list");
                return null;
            }

            _logger.LogInformation("ReadList. Count: {Count}", list.Count);
            return list;
        }

        public DepartmentViewModel? ReadElement(DepartmentSearchModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            _logger.LogInformation("ReadElement. Name: {Name}, Id: {Id}", model.name, model.id);
            var element = _departmentStorage.GetElement(model);

            if (element == null)
            {
                _logger.LogWarning("ReadElement element not found");
                return null;
            }

            _logger.LogInformation("ReadElement found. Id: {Id}", element.id);
            return element;
        }

        public bool Create(DepartmentBindingModel model)
        {
            CheckModel(model);
            if (_departmentStorage.Insert(model) == null)
            {
                _logger.LogWarning("Insert operation failed");
                return false;
            }
            return true;
        }

        public bool Update(DepartmentBindingModel model)
        {
            CheckModel(model);
            if (_departmentStorage.Update(model) == null)
            {
                _logger.LogWarning("Update operation failed");
                return false;
            }
            return true;
        }

        public bool Delete(DepartmentBindingModel model)
        {
            CheckModel(model, false);
            _logger.LogInformation("Delete. Id: {Id}", model.id);
            if (_departmentStorage.Delete(model) == null)
            {
                _logger.LogWarning("Delete operation failed");
                return false;
            }
            return true;
        }

        private void CheckModel(DepartmentBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (string.IsNullOrWhiteSpace(model.name))
                throw new ArgumentNullException("Название департамента не задано", nameof(model.name));

            _logger.LogInformation("Department. Name: {Name}, Id: {Id}", model.name, model.id);

            var element = _departmentStorage.GetElement(new DepartmentSearchModel
            {
                name = model.name
            });

            if (element != null && element.id != model.id)
                throw new InvalidOperationException("Департамент с таким названием уже существует");
        }
    }
}
