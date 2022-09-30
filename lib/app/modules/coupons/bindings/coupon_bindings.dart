import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/coupons/controllers/coupons_controller.dart';
import 'package:home_services_provider/app/modules/coupons/controllers/coupons_form_controller.dart';

class CouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponsController>(
      () => CouponsController(),
    );
    Get.lazyPut<CustomCouponFormController>(
      () => CustomCouponFormController(),
    );
  }
}
