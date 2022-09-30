import 'package:get/get.dart';

import '../controllers/address_controller.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(
      () => AddressController(),
    );
  }
}