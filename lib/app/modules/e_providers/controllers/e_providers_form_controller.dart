import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/models/address_model.dart';
import 'package:home_services_provider/app/models/e_provider_type_model.dart';
import 'package:home_services_provider/app/models/user_model.dart';
import 'package:home_services_provider/app/modules/addresses/controllers/address_controller.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_controller.dart';
import 'package:home_services_provider/app/providers/api_provider.dart';
import 'package:home_services_provider/app/repositories/user_repository.dart';
import 'package:home_services_provider/app/services/auth_service.dart';
import 'package:home_services_provider/common/uuid.dart';

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

class EProviderFormController extends GetxController with ApiClient {
  final eProvider = EProvider().obs;
  final users = [].obs;
  final eProviderType = [].obs;
  final addresses = [].obs;
  final taxes = [].obs;
  final isLoading = false.obs;
  final pageLoading = false.obs;
  final isFirstProvider = false.obs;

  GlobalKey<FormState> providerForm = new GlobalKey<FormState>();
  EServiceRepository _eServiceRepository;
  CategoryRepository _categoryRepository;
  EProviderRepository _eProviderRepository;

  dio.Dio _httpClient;
  dio.Options _optionsNetwork;
  dio.Options _optionsCache;

  EProviderFormController() {
    this.baseUrl = this.globalService.global.value.laravelBaseUrl;
    _httpClient = new dio.Dio();
    _eProviderRepository = new EProviderRepository();
  }

  @override
  void onInit() async {
    var arguments = Get.arguments as EProvider;
    if (arguments != null) {
      eProvider.value = arguments;
    }
    var parameters = Get.parameters as Map<String, dynamic>;
    isFirstProvider.value = parameters['isFirstProvider'].toString() == 'true';
    if (foundation.kIsWeb || foundation.kDebugMode) {
      _optionsNetwork = dio.Options();
      _optionsCache = dio.Options();
    } else {
      _optionsNetwork =
          buildCacheOptions(Duration(days: 3), forceRefresh: true);
      _optionsCache =
          buildCacheOptions(Duration(minutes: 10), forceRefresh: true);
      _httpClient.interceptors.add(
          DioCacheManager(CacheConfig(baseUrl: getApiBaseUrl(""))).interceptor);
    }
    super.onInit();
  }

  @override
  void onReady() async {
    await refreshEProvider();

    super.onReady();
  }

  Future getAddress() async {
    String user_id = Get.find<AuthService>().user.value.id;

    var _queryParameters = {
      'api_token': Get.find<AuthService>().user.value.apiToken
    };

    Uri _uri = getApiBaseUri("custom_providers/create")
        .replace(queryParameters: _queryParameters);

    var response = await _httpClient.getUri(_uri, options: _optionsNetwork);

    addresses.clear();
    // print(response);
    if (response.data['address'] != null && response.data['address'].length > 0)
      Map<dynamic, dynamic>.from(response.data['address'] ?? {})
          .forEach((key, value) async {
        addresses.add({'id': key, 'name': value});
      });
  }

  Future refreshEProvider({bool showMessage = false}) async {
    if (isCreateForm()) {
      try {
        pageLoading.value = true;
        String user_id = Get.find<AuthService>().user.value.id;

        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        Uri _uri = getApiBaseUri("custom_providers/create")
            .replace(queryParameters: _queryParameters);

        var response = await _httpClient.getUri(_uri, options: _optionsNetwork);

        debugPrint(response.toString());

        if (response.data['message'] == 'success') {
          Map<dynamic, dynamic>.from(response.data['eProviderType'] ?? {})
              .forEach((key, value) {
            eProviderType.add({'id': key, 'name': value});
          });
          if (response.data['user'] != null && response.data['user'].length > 0)
            Map<dynamic, dynamic>.from(response.data['user'] ?? {})
                .forEach((key, value) async {
              users.add({'id': key, 'name': value});
            });
          if (response.data['address'] != null &&
              response.data['address'].length > 0)
            Map<dynamic, dynamic>.from(response.data['address'] ?? {})
                .forEach((key, value) async {
              addresses.add({'id': key, 'name': value});
            });
          if (response.data['tax'] != null && response.data['tax'].length > 0)
            Map<dynamic, dynamic>.from(response.data['tax'] ?? {})
                .forEach((key, value) async {
              taxes.add({'id': key, 'name': value});
            });
        }
        if (showMessage) {
          Get.showSnackbar(Ui.SuccessSnackBar(
              message: eProvider.value.name +
                  " " +
                  "page refreshed successfully".tr));
        }
      } catch (e) {
        print(e);
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        pageLoading.value = false;
      }
    } else {
      try {
        pageLoading.value = true;
        String user_id = Get.find<AuthService>().user.value.id;

        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        String id = eProvider.value.id;

        Uri _uri = getApiBaseUri("custom_providers/$id/edit")
            .replace(queryParameters: _queryParameters);
        var response = await _httpClient.getUri(_uri, options: _optionsNetwork);

        debugPrint(response.toString());

        if (response.data['message'] == 'success') {
          Map<dynamic, dynamic>.from(response.data['eProviderType'] ?? {})
              .forEach((key, value) {
            eProviderType.add({'id': key, 'name': value});
          });
          if (response.data['user'] != null && response.data['user'].length > 0)
            Map<dynamic, dynamic>.from(response.data['user'] ?? {})
                .forEach((key, value) async {
              users.add({'id': key, 'name': value});
            });
          if (response.data['address'] != null &&
              response.data['address'].length > 0)
            Map<dynamic, dynamic>.from(response.data['address'] ?? {})
                .forEach((key, value) async {
              addresses.add({'id': key, 'name': value});
            });
          if (response.data['tax'] != null && response.data['tax'].length > 0)
            Map<dynamic, dynamic>.from(response.data['tax'] ?? {})
                .forEach((key, value) async {
              taxes.add({'id': key, 'name': value});
            });
          eProvider.value = EProvider.fromJson(response.data['eProvider']);
          eProvider.value.employees = response.data['usersSelected'] ?? [];
          eProvider.value.addresses = response.data['addressesSelected'] ?? [];
          eProvider.value.taxes = response.data['taxesSelected'] ?? [];
          eProvider.value.type =
              (response.data['eProvider']['e_provider_type_id'] ?? 0)
                  .toString();
          eProvider.value.available =
              response.data['eProvider']['available'] ?? false;
        }
        if (showMessage) {
          Get.showSnackbar(Ui.SuccessSnackBar(
              message: eProvider.value.name +
                  " " +
                  "page refreshed successfully".tr));
        }
      } catch (e) {
        print(e);
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        pageLoading.value = false;
      }
    }
  }

  List<SelectDialogItem<dynamic>> getSelectProviderTypeItems() {
    return eProviderType.map((element) {
      return SelectDialogItem(element, element["name"]);
    }).toList();
  }

  List<MultiSelectDialogItem<dynamic>> getUserItems() {
    return users.map((element) {
      return MultiSelectDialogItem(element, element["name"]);
    }).toList();
  }

  List<MultiSelectDialogItem<dynamic>> getAddressItems() {
    return addresses.map((element) {
      return MultiSelectDialogItem(element, element["name"]);
    }).toList();
  }

  List<MultiSelectDialogItem<dynamic>> getTaxItems() {
    return taxes.map((element) {
      return MultiSelectDialogItem(element, element["name"]);
    }).toList();
  }

  /*
  * Check if the form for create new service or edit
  * */
  bool isCreateForm() {
    var arguments = Get.arguments as EProvider;
    return arguments == null;
  }

  void createProviderForm() async {
    Get.focusScope.unfocus();
    if (providerForm.currentState.validate()) {
      if (eProvider.value.images == null ||
          eProvider.value.images.length == 0) {
        Get.showSnackbar(
            Ui.ErrorSnackBar(message: "Please Select atleast one Image".tr));
        return;
      }
      try {
        providerForm.currentState.save();
        // print(coupon);
        isLoading.value = true;
        String user_id = Get.find<AuthService>().user.value.id;
        var _queryParameters = {
          'api_token': Get.find<AuthService>().user.value.apiToken
        };

        // List<String> eProviders = [];
        Map<String, dynamic> data = {
          'user_id': user_id,
          'name': eProvider.value.name,
          'e_provider_type_id': eProvider.value.type,
          'users': eProvider.value.employees,
          'description': eProvider.value.description,
          'image': eProvider.value.images != null
              ? eProvider.value.images
                  .where((element) => Uuid.isUuid(element.id))
                  .map((v) => v.id)
                  .toList()
              : [],
          'phone_number': eProvider.value.phoneNumber,
          'mobile_number': eProvider.value.mobileNumber,
          'addresses': eProvider.value.addresses,
          'taxes': eProvider.value.taxes != null ? eProvider.value.taxes : [],
          'availability_range': eProvider.value.availabilityRange,
          'available': eProvider.value.available,
          'featured': eProvider.value.featured,
        };
        Uri _uri = getApiBaseUri("custom_providers_add")
            .replace(queryParameters: _queryParameters);
        print(_uri);
        var response = await _httpClient.postUri(_uri,
            data: json.encode(data), options: _optionsNetwork);

        if (!Get.find<EProvidersController>().isClosed)
          Get.find<EProvidersController>().refreshEProviders();
        if (response.data['message'] == 'success') {
          Get.back();
          Get.offAndToNamed(Routes.AVAILIBILITY, parameters: {
            'eprovider_id': response.data['id'].toString() ?? '',
            'isUpdate': 'false',
            'isFirstProvider': isFirstProvider.value ? 'true' : 'false'
          });
        } else {
          Get.showSnackbar(
              Ui.ErrorSnackBar(message: "Provider Creation Failed"));
        }
        isLoading.value = false;
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

  void updateProviderForm() async {
    print("1st UPDATE!");
    Get.focusScope.unfocus();
    if (providerForm.currentState.validate()) {
      if (eProvider.value.images == null ||
          eProvider.value.images.length == 0) {
        Get.showSnackbar(
            Ui.ErrorSnackBar(message: "Please Select atleast one Image".tr));
        return;
      }
      try {
        try {
          providerForm.currentState.save();
          // print(coupon);
          isLoading.value = true;
          String user_id = Get.find<AuthService>().user.value.id;
          var _queryParameters = {
            'api_token': Get.find<AuthService>().user.value.apiToken
          };

          // List<String> eProviders = [];

          Map<String, dynamic> data = {
            'user_id': user_id,
            'id': eProvider.value.id,
            'name': eProvider.value.name,
            'e_provider_type_id': eProvider.value.type,
            'users': eProvider.value.employees,
            'description': eProvider.value.description,
            'image': eProvider.value.images
                .where((element) => Uuid.isUuid(element.id))
                .map((v) => v.id)
                .toList(),
            'phone_number': eProvider.value.phoneNumber,
            'mobile_number': eProvider.value.mobileNumber,
            'addresses': eProvider.value.addresses,
            'taxes': eProvider.value.taxes,
            'availability_range': eProvider.value.availabilityRange,
            'available': eProvider.value.available,
            'featured': eProvider.value.featured,
          };

          var id = eProvider.value.id;

          Uri _uri = getApiBaseUri("custom_providers/$id")
              .replace(queryParameters: _queryParameters);

          var response = await _httpClient.patchUri(_uri,
              data: json.encode(data), options: _optionsNetwork);

          if (response.data['message'] == 'success') {
            Get.offAndToNamed(Routes.AVAILIBILITY, parameters: {
              'eprovider_id': eProvider.value.id ?? '',
              'isUpdate': 'true',
              'isFirstProvider': 'false'
            });
          } else {
            Get.showSnackbar(
                Ui.ErrorSnackBar(message: "Provider updation Failed"));
          }
          isLoading.value = false;

          // Get.offAndToNamed(Routes.E_PROVIDERS);

        } catch (e) {
          print(e);
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        } finally {
          isLoading.value = false;
        }
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {}
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(
          message: "There are errors in some fields please correct them!".tr));
    }
  }

  void deleteProvider() async {
    try {
      String user_id = Get.find<AuthService>().user.value.id;

      var _queryParameters = {
        'api_token': Get.find<AuthService>().user.value.apiToken
      };

      var id = eProvider.value.id;

      Uri _uri = getApiBaseUri("custom_providers/$id")
          .replace(queryParameters: _queryParameters);

      var response =
          await _httpClient.deleteUri(_uri, options: _optionsNetwork);

      if (response.data['message'] == 'success') {
        if (!Get.find<EProvidersController>().isClosed)
          Get.find<EProvidersController>().refreshEProviders();
        Get.back();
        Get.showSnackbar(Ui.SuccessSnackBar(
            message: eProvider.value.name + " " + "has been removed"));
      } else {
        Get.back();
        Get.showSnackbar(Ui.SuccessSnackBar(
            message: eProvider.value.name +
                " " +
                "was not removed. Please try again later."));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
