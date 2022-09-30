import 'package:get/get.dart';
import 'package:home_services_provider/app/models/custom_coupon.dart';
import 'package:home_services_provider/app/services/auth_service.dart';
import 'package:home_services_provider/common/ui.dart';
import '../../../providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;

class CouponsController extends GetxController with ApiClient {
  final coupons = [].obs; //= <CustomCoupon>[].obs;
  dio.Dio _httpClient;
  dio.Options _optionsNetwork;
  dio.Options _optionsCache;
  final loading = true.obs;

  @override
  void onInit() async {
    this.baseUrl = this.globalService.global.value.laravelBaseUrl;
    _httpClient = new dio.Dio();
    await refreshCoupons();
    super.onInit();
  }

  // CouponsController(){
  //   refreshCoupons();
  //   this.baseUrl = this.globalService.global.value.laravelBaseUrl;
  //   _httpClient = new dio.Dio();
  // }

  Future refreshCoupons() async {
    try {
      loading.value = true;
      if (Get.find<AuthService>().isAuth) {
        String user_id = Get.find<AuthService>().user.value.id;
        var _queryParameters = {
          'user_id': user_id,
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        Uri _uri = getApiBaseUri("custom_coupons")
            .replace(queryParameters: _queryParameters);

        var response = await _httpClient.getUri(_uri);

        print(response.data);

        if (response.data['message'] == 'success') {
          coupons.value = response.data['data'];
        }
      }
      loading.value = false;
    } catch (e) {
      print(e);
      loading.value = false;

      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
