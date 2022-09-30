import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_controller.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_form_controller.dart';

class EProvidersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EProvidersController>(
      () => EProvidersController(),
    );
    Get.lazyPut<EProviderFormController>(
      () => EProviderFormController(),
    );
  }
}
