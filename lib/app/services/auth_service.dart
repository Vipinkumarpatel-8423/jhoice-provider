import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'settings_service.dart';

class AuthService extends GetxService {
  final user = User().obs;
  GetStorage _box;

  UserRepository _usersRepo;

  AuthService() {
    _usersRepo = new UserRepository();
    _box = new GetStorage();
  }

  Future<AuthService> init() async {
    user.listen((User _user) {
      if (Get.isRegistered<SettingsService>()) {
        Get.find<SettingsService>().address.value.userId = _user.id;
      }
      _box.write('current_user', _user.toJson());
    });
    await getCurrentUser();
    return this;
  }

  Future getCurrentUser() async {
    if (user.value.auth == null && _box.hasData('current_user')) {
      user.value = User.fromJson(await _box.read('current_user'));
      user.value.auth = true;
    } else {
      user.value.auth = false;
    }
  }

  Future removeCurrentUser() async {
    user.value = new User();
    await _usersRepo.signOut();
    await _box.remove('current_user');
    await _box.remove('firstlogincamp');
    if (_box.read('lastlogin') != null) await _box.remove('lastlogin');
  }

  Future saveLastLoginTime() async {
    DateTime now = new DateTime.now();
    _box.write('lastlogin', now.toIso8601String().split('T').first);
  }

  Future saveFirstLoginCampaign() async {
    DateTime now = new DateTime.now();
    _box.write('firstlogincamp', true);
  }

  Future<bool> isTodaysFirstLogin() async {
    if (_box.read('lastlogin') == null)
      return true;
    else {
      String date = _box.read('lastlogin');
      DateTime now = new DateTime.now();
      return date != now.toIso8601String().split('T').first;
    }
  }

  Future<bool> isFirstLogin() async {
    return _box.read('firstlogincamp') ?? false;
  }

  bool get isAuth => user.value.auth ?? false;

  String get apiToken => (user.value.auth ?? false) ? user.value.apiToken : '';
}
