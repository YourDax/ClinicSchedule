using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using Microsoft.Extensions.Logging;

namespace ClinicScheduleBusinessLogic.BusinessLogic
{
    public class ShiftLogic : IShiftLogic
    {
        private readonly ILogger _logger;
        private readonly IShiftStorage _shiftStorage;

        public ShiftLogic(ILogger<ShiftLogic> logger, IShiftStorage shiftStorage)
        {
            _logger = logger;
            _shiftStorage = shiftStorage;
        }

        public List<ShiftViewModel>? ReadList(ShiftSearchModel? model)
        {
            _logger.LogInformation("ReadList. DepartmentId: {DepartmentId}, Id: {Id}", model?.departmentId, model?.id);
            var list = model == null
                ? _shiftStorage.GetFullList()
                : _shiftStorage.GetFilteredList(model);

            if (list == null)
            {
                _logger.LogWarning("ReadList returned null");
                return null;
            }

            _logger.LogInformation("ReadList. Count: {Count}", list.Count);
            return list;
        }

        public ShiftViewModel? ReadElement(ShiftSearchModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            _logger.LogInformation("ReadElement. Id: {Id}", model.id);
            var element = _shiftStorage.GetElement(model);

            if (element == null)
            {
                _logger.LogWarning("ReadElement not found");
                return null;
            }

            _logger.LogInformation("ReadElement found. Id: {Id}", element.id);
            return element;
        }

        public bool Create(ShiftBindingModel model)
        {
            CheckModel(model);
            if (_shiftStorage.Insert(model) == null)
            {
                _logger.LogWarning("Create failed");
                return false;
            }
            return true;
        }

        public bool Update(ShiftBindingModel model)
        {
            CheckModel(model);
            if (_shiftStorage.Update(model) == null)
            {
                _logger.LogWarning("Update failed");
                return false;
            }
            return true;
        }

        public bool Delete(ShiftBindingModel model)
        {
            CheckModel(model, false);
            _logger.LogInformation("Delete. Id: {Id}", model.id);
            if (_shiftStorage.Delete(model) == null)
            {
                _logger.LogWarning("Delete failed");
                return false;
            }
            return true;
        }

        private void CheckModel(ShiftBindingModel model, bool withParams = true)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (!withParams)
                return;

            if (model.startTime >= model.endTime)
                throw new ArgumentException("Начало смены должно быть раньше конца");

            if (model.requiredDoctors < 0 || model.requiredNurses < 0)
                throw new ArgumentException("Количество необходимых сотрудников не может быть отрицательным");

            _logger.LogInformation("Shift. Start: {Start}, End: {End}, DepartmentId: {DepId}, Id: {Id}",
                model.startTime, model.endTime, model.departmentId, model.id);

            var existing = _shiftStorage.GetFilteredList(new ShiftSearchModel
            {
                departmentId = model.departmentId
            })?.FirstOrDefault(s =>
                s.startTime == model.startTime &&
                s.endTime == model.endTime &&
                s.id != model.id);

            if (existing != null)
            {
                throw new InvalidOperationException("Такая смена уже существует");
            }
        }
    }
}
