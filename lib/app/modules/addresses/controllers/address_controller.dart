// import 'dart:html';

import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/global_widgets/tab_bar_widget.dart';
import 'package:home_services_provider/app/services/settings_service.dart';

import '../../../../common/ui.dart';
import '../../../models/address_model.dart';
import '../../../repositories/setting_repository.dart';
import '../../../services/auth_service.dart';

class AddressController extends GetxController {
  SettingRepository _settingRepository;
  final addresses = <Address>[].obs;
  final loading = true.obs;

  AddressController() {
    _settingRepository = new SettingRepository();
  }

  Address get currentAddress => Get.find<SettingsService>().address.value;

  @override
  void onInit() async {
    await refreshAddresses();
    super.onInit();
  }

  Future refreshAddresses({bool showMessage}) async {
    loading.value = true;
    await getAddresses();
    loading.value = false;
    if (showMessage == true) {
      Get.showSnackbar(Ui.SuccessSnackBar(
          message: "List of addresses refreshed successfully".tr));
    }
  }

  Future getAddress() async {
    try {
      if (Get.find<AuthService>().isAuth) {
        addresses.assignAll(await _settingRepository.getAddresses());
        if (!currentAddress.isUnknown()) {
          addresses.remove(currentAddress);
          addresses.insert(0, currentAddress);
        }
        if (Get.isRegistered<TabBarController>(tag: 'addresses')) {
          Get.find<TabBarController>(tag: 'addresses').selectedId.value =
              addresses.elementAt(0).id;
        }
      }
    } catch (e) {
      loading.value = false;

      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getAddresses() async {
    try {
      if (Get.find<AuthService>().isAuth) {
        loading.value = true;
        addresses.assignAll(await _settingRepository.getAddresses());
      }
    } catch (e) {
      loading.value = false;

      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
