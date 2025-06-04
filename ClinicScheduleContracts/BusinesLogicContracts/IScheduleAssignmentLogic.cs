using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.ViewModels;
using System.Collections.Generic;

namespace ClinicScheduleContracts.BusinessLogicContracts
{
    public interface IScheduleAssignmentLogic
    {
        List<ScheduleAssignmentViewModel>? ReadList(ScheduleAssignmentSearchModel? model);
        ScheduleAssignmentViewModel? ReadElement(ScheduleAssignmentSearchModel model);

        /// <summary>
        /// Добавляет назначение и обновляет отработанные часы у сотрудника.
        /// </summary>
        /// <param name="model">Модель назначения.</param>
        /// <param name="shiftDurationHours">Длительность смены в часах.</param>
        /// <returns>True при успешном добавлении, иначе false.</returns>
        bool AddAssignment(ScheduleAssignmentBindingModel model);

        /// <summary>
        /// Удаляет назначение и корректирует отработанные часы у сотрудника.
        /// </summary>
        /// <param name="model">Модель назначения с id для удаления.</param>
        /// <param name="shiftDurationHours">Длительность смены в часах.</param>
        /// <returns>True при успешном удалении, иначе false.</returns>
        bool RemoveAssignment(ScheduleAssignmentBindingModel model);
    }
}
