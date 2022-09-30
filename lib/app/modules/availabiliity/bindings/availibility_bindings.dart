import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/availabiliity/controllers/availibility_form_controller.dart';

class AvailibilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvailibilityFormController>(
      () => AvailibilityFormController(),
    );
  }
}
