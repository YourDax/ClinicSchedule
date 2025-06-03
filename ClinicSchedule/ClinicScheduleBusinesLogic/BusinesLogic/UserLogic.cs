using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleModels.Enums;


namespace ClinicScheduleBusinessLogic.Logic
{
    public class UserLogic : IUserLogic
    {
        private readonly IUserStorage _userStorage;

        public UserLogic(IUserStorage userStorage)
        {
            _userStorage = userStorage;
        }

        public bool Create(UserBindingModel model)
        {
            if (model == null) return false;

            // Проверка на уникальность логина
            var existingUser = _userStorage.GetElement(new UserSearchModel { login = model.login });
            if (existingUser != null) throw new Exception("Пользователь с таким логином уже существует");

            model.role = Roles.Admin;
            _userStorage.Insert(model);
            return true;
        }

        public bool Update(UserBindingModel model)
        {
            if (model == null) return false;

            var existing = _userStorage.GetElement(new UserSearchModel { id = model.id });
            if (existing == null) throw new Exception("Пользователь не найден");

            model.role = Roles.Admin; // Защита от смены роли
            _userStorage.Update(model);
            return true;
        }

        public bool Delete(UserBindingModel model)
        {
            if (model == null) return false;

            var existing = _userStorage.GetElement(new UserSearchModel { id = model.id });
            if (existing == null) throw new Exception("Пользователь не найден");

            _userStorage.Delete(model);
            return true;
        }

        public List<UserViewModel>? ReadList(UserSearchModel? searchModel)
        {
            var list = _userStorage.GetFilteredList(searchModel);
            return list;
        }

        public UserViewModel? ReadElement(UserSearchModel searchModel)
        {
            return _userStorage.GetElement(searchModel);
        }
    }
}
