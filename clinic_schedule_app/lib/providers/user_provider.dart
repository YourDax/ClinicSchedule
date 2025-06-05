import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/UniversalUserUpdateModel.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
  void updateUserFromModel(UniversalUserUpdateModel model) {
    if (_user == null) {
      print('UserProvider.updateUserFromModel: user is null, skip update');
      return;
    }
    print('UserProvider.updateUserFromModel: updating user with id=${_user!.id}');
    _user = _user!.copyWith(
      fullname: model.fullname,
      phoneNumber: model.phoneNumber,
      birthdate: model.birthdate,
      password: model.password ?? _user!.password,
      login: model.login,
    );
    print('UserProvider.updateUserFromModel: user updated to login=${_user!.login}');
    notifyListeners();
  }


  bool get isLoggedIn => _user != null;

  Future<void> loadUserFromApi() async {
    if (_user == null) throw Exception('User is not set, cannot load');

    print('UserProvider.loadUserFromApi: loading user id=${_user!.id}, role=${_user!.role.index}');

    final freshUser = await ApiClient.getUserById(_user!.id, _user!.role.index);
    _user = freshUser;

    notifyListeners();
    print('UserProvider.loadUserFromApi: user updated');
  }
}
