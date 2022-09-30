import 'package:get/get.dart';
import 'package:home_services_provider/app/models/e_provider_model.dart';
import 'package:home_services_provider/app/repositories/e_provider_repository.dart';
import 'package:home_services_provider/app/services/auth_service.dart';
import 'package:home_services_provider/common/ui.dart';
import '../../../providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;

class EProvidersController extends GetxController with ApiClient {
  final eProviders = <EProvider>[].obs; //= <CustomCoupon>[].obs;
  EProviderRepository _eProviderRepository;
  dio.Dio _httpClient;
  dio.Options _optionsNetwork;
  dio.Options _optionsCache;
  final loading = true.obs;

  EProvidersController() {
    _eProviderRepository = new EProviderRepository();
  }

  @override
  void onInit() async {
    this.baseUrl = this.globalService.global.value.laravelBaseUrl;
    _httpClient = new dio.Dio();
    await refreshEProviders();

    super.onInit();
  }

  Future refreshEProviders() async {
    try {
      loading.value = true;
      eProviders.clear();
      eProviders.assignAll(await _eProviderRepository.getAll());
      loading.value = false;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
