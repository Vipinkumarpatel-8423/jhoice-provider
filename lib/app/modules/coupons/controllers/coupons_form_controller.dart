import 'dart:developer';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/providers/api_provider.dart';
import 'package:home_services_provider/app/services/auth_service.dart';

import '../../../../common/ui.dart';
import '../../../models/category_model.dart';
import '../../../models/e_provider_model.dart';
import '../../../models/e_service_model.dart';
import '../../../models/option_group_model.dart';
import '../../../repositories/category_repository.dart';
import '../../../repositories/e_provider_repository.dart';
import '../../../repositories/e_service_repository.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/multi_select_dialog.dart';
import '../../global_widgets/select_dialog.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' as foundation;
import 'dart:convert';

class CustomCouponFormController extends GetxController with ApiClient {
  final coupon = {}.obs;
  final optionGroups = <OptionGroup>[].obs;
  final categories = <Category>[].obs;
  final eProviders = <EProvider>[].obs;
  final eServices = <EService>[].obs;
  final isLoading = false.obs;
  GlobalKey<FormState> couponForm = new GlobalKey<FormState>();
  EServiceRepository _eServiceRepository;
  CategoryRepository _categoryRepository;
  EProviderRepository _eProviderRepository;

  dio.Dio _httpClient;
  dio.Options _optionsNetwork;
  dio.Options _optionsCache;

  CustomCouponFormController() {
    this.baseUrl = this.globalService.global.value.laravelBaseUrl;
    _httpClient = new dio.Dio();
    _eServiceRepository = new EServiceRepository();
    _categoryRepository = new CategoryRepository();
    _eProviderRepository = new EProviderRepository();
  }

  @override
  void onInit() async {

    var arguments = Get.arguments as Map<String, dynamic>;
    if (arguments != null) {
      coupon.value = arguments;
      print(arguments);
    }
    if (foundation.kIsWeb || foundation.kDebugMode) {
      _optionsNetwork = dio.Options();
      _optionsCache = dio.Options();
    } else {
      _optionsNetwork =
          buildCacheOptions(Duration(days: 3), forceRefresh: true);
      _optionsCache =
          buildCacheOptions(Duration(minutes: 10), forceRefresh: false);
      _httpClient.interceptors.add(
          DioCacheManager(CacheConfig(baseUrl: getApiBaseUrl(""))).interceptor);
    }
    super.onInit();
  }

  @override
  void onReady() async {
    await refreshCoupon();
    super.onReady();
  }

  Future refreshCoupon({bool showMessage = false}) async {
    await getCoupon();
    await getCategories();
    await getEProviders();
    await getEServices();

    if (showMessage) {
      Get.showSnackbar(Ui.SuccessSnackBar(
          message:
              coupon.value["code"] + " " + "page refreshed successfully".tr));
    }
  }

  Future getCoupon() async {
    if (coupon.value.isNotEmpty) {
      try {
        String user_id = Get.find<AuthService>().user.value.id;

        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        var id = coupon.value["id"];

        Uri _uri = getApiBaseUri("custom_coupons/$id/edit")
            .replace(queryParameters: _queryParameters);

        var response = await _httpClient.getUri(_uri, options: _optionsNetwork);

        if (response.data['message'] == 'success') {
          // coupon.value["code"] = response.data['data']["code"];
          // coupon.value["discount_type"] = response.data['data']["discount_type"];
          // coupon.value["discount"] = response.data['data']["discount"];
          // coupon.value["description"] = response.data['data']["description"];
          coupon.value["eServices"] = response.data['data']["eServices"];
          coupon.value["categories"] = response.data['data']["categories"];
          // coupon.value["enabled"] = response.data['data']["enabled"];
          coupon.value["eProviders"] = response.data['data']["eProviders"];
        }
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    else{
      coupon.addAll({'enabled': true});
    }
  }

  Future getCategories() async {
    try {
      categories.assignAll(await _categoryRepository.getAll());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getEProviders() async {
    try {
      eProviders.assignAll(await _eProviderRepository.getAll());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getEServices() async {
    try {
      eServices.assignAll(await _eProviderRepository.getEServices(page: 0));
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  List<MultiSelectDialogItem<Category>> getMultiSelectCategoriesItems() {
    return categories.map((element) {
      return MultiSelectDialogItem(element, element.name);
    }).toList();
  }

  List<MultiSelectDialogItem<EProvider>> getSelectProvidersItems() {
    return eProviders.map((element) {
      return MultiSelectDialogItem(element, element.name);
    }).toList();
  }

  List<MultiSelectDialogItem<EService>> getSelectServiceItems() {
    return eServices.map((element) {
      return MultiSelectDialogItem(element, element.name);
    }).toList();
  }

  /*
  * Check if the form for create new service or edit
  * */
  bool isCreateForm() {
    var arguments = Get.arguments as Map<String, dynamic>;
    return arguments == null;
  }

  void createCouponForm() async {
    print("CREATE!");
    Get.focusScope.unfocus();
    if (couponForm.currentState.validate()) {
      try {
        couponForm.currentState.save();
        
        isLoading.value = true;
        String user_id = Get.find<AuthService>().user.value.id;
        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        List<String> eProviders = [];

        Map<String, dynamic> data = {
          'user_id': user_id,
          'code': coupon.value['code'],
          'discount_type': coupon.value['discount_type'],
          'discount': coupon.value['discount'],
          "description": '<p>${coupon.value['description']}</p>',
          "files": null,
          "eServices": coupon.value['eServices'],
          "eProviders": coupon.value['eProviders'],
          "categories": coupon.value['categories'],
          'expires_at': coupon.value['expires_at'],
          'enabled': coupon.value['enabled'].toString(),
        };

        Uri _uri = getApiBaseUri("custom_coupons")
            .replace(queryParameters: _queryParameters);
print(_uri);
        var response = await _httpClient.postUri(_uri,
            data: json.encode(data), options: _optionsNetwork);
        
        
        if (response.data['message'] == 'success') {
          coupon.value = response.data['data'];
        }
        Get.offAndToNamed(Routes.COUPONS,
            arguments: {'coupon': coupon, 'heroTag': 'coupon_create_form'});
      } catch (e) {
        print(e);
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(
          message: "There are errors in some fields please correct them!".tr));
    }
  }

  void updateCouponForm() async {
    print("1st UPDATE!");
    Get.focusScope.unfocus();
    if (couponForm.currentState.validate()) {
      try {
        couponForm.currentState.save();
        isLoading.value = true;
        print("UPDATE!");
        String user_id = Get.find<AuthService>().user.value.id;

        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        int coupon_id = coupon.value['id'];

        Map<String, dynamic> data = {
          'code': coupon.value['code'],
          'discount_type': coupon.value['discount_type'],
          'discount': coupon.value['discount'],
          "description": '<p>${coupon.value['description']}</p>',
          "files": null,
          "eServices": coupon.value['eServices'],
          "eProviders": coupon.value['eProviders'],
          "categories": coupon.value['categories'],
          'expires_at': coupon.value['expires_at'],
          'enabled': coupon.value['enabled'].toString(),
        };

        Uri _uri = getApiBaseUri("custom_coupons/$coupon_id")
            .replace(queryParameters: _queryParameters);

        var response = await _httpClient.putUri(_uri,
            data: json.encode(data), options: _optionsNetwork);

        if (response.data['message'] == 'success') {
          coupon.value = response.data['data'];
        }
        Get.offAndToNamed(Routes.COUPONS);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {}
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(
          message: "There are errors in some fields please correct them!".tr));
    }
  }

  void deleteCoupon() async {
    try {
      String user_id = Get.find<AuthService>().user.value.id;

      var _queryParameters = {
        'api_token': Get.find<AuthService>().user.value.apiToken
      };

      var id = coupon.value["id"];

      Uri _uri = getApiBaseUri("custom_coupons/$id")
          .replace(queryParameters: _queryParameters);

      var response = await _httpClient.deleteUri(_uri, options: _optionsNetwork);

      if (response.data['message'] == 'success') {
        Get.offAndToNamed(Routes.COUPONS);
        Get.showSnackbar(Ui.SuccessSnackBar(
            message:
                coupon.value["code"] + " " + "has been removed"));
      }else{
        Get.offAndToNamed(Routes.COUPONS);
        Get.showSnackbar(Ui.SuccessSnackBar(
            message:
                coupon.value["code"] + " " + "was not removed. Please try again later."));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
