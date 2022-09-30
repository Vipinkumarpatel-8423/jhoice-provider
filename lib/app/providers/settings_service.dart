import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/ui.dart';
import '../models/address_model.dart';
import '../models/setting_model.dart';
import '../repositories/setting_repository.dart';
import 'auth_service.dart';


class SettingsService extends GetxService {
  final setting = Setting().obs;
  final address = Address().obs;
  GetStorage _box;

  SettingRepository _settingsRepo;

  SettingsService() {
    _settingsRepo = new SettingRepository();
    _box = new GetStorage();
  }

  Future<SettingsService> init() async {
    address.listen((Address _address) {
      _box.write('current_address', _address.toJson());
    });
    setting.value = await _settingsRepo.get();
    await getAddress();
    return this;
  }

  Future getAddress() async {
    try {
      if (_box.hasData('current_address') && !address.value.isUnknown()) {
        address.value = Address.fromJson(await _box.read('current_address'));
      } else if (Get.find<AuthService>().isAuth) {
        List<Address> _addresses = await _settingsRepo.getAddresses();
        if (_addresses.isNotEmpty) {
          address.value = _addresses.firstWhere((_address) => _address.isDefault, orElse: () {
            return _addresses.first;
          });
        }
      }
    } catch (e) {
      Get.log(e.toString());
    }
  }
}
