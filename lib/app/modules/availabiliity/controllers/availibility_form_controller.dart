import 'dart:developer';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/models/availability_hour_model.dart';
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

class AvailibilityFormController extends GetxController with ApiClient {
  final availibility = {}.obs;
  final availibilitySave = {}.obs;

  final optionGroups = <OptionGroup>[].obs;
  final categories = <Category>[].obs;
  final eProviders = <EProvider>[].obs;
  final eServices = <EService>[].obs;
  final availabilityHour = <AvailabilityHour>[].obs;
  final isLoading = false.obs;
  final isUpdate = false.obs;
  final isFirstProvider = false.obs;

  GlobalKey<FormState> availableForm = new GlobalKey<FormState>();
  EProviderRepository _eProviderRepository;

  AvailibilityFormController() {
    _eProviderRepository = new EProviderRepository();
  }
  @override
  void onInit() async {
    var parameters = Get.parameters as Map<String, dynamic>;
    isUpdate.value = parameters['isUpdate'].toString() == 'true';
    isFirstProvider.value = parameters['isFirstProvider'].toString() == 'true';
    setDaysInitially();
    if (isUpdate.value) {
      availabilityHour.value =
          await getAvailibilityHour(parameters['eprovider_id'].toString());
      availabilityHour.value.forEach((value) => {
            availibilitySave.addIf(true, value.day, {
              'day': value.day,
              'startsat': value.startAt.obs,
              'endsat': value.endAt.obs,
              'isHoliday': false.obs
            })
          });
    }
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();
  }

  holidayButtonClicked(index) {
    availibilitySave.values.elementAt(index)['isHoliday'].value =
        !(availibilitySave.values.elementAt(index)['isHoliday'].value);
  }

  changeTime(index, value, isStart) {
    if (isStart)
      availibilitySave.values.elementAt(index)['startsat'].value = value;
    else
      availibilitySave.values.elementAt(index)['endsat'].value = value;
  }

  setDaysInitially() {
    var days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    days.forEach((element) {
      print(element);
      availibilitySave.addIf(true, element, {
        'day': element,
        'startsat': '00:00'.obs,
        'endsat': '00:00'.obs,
        'isHoliday': true.obs,
      });
    });
  }

  Future<List<AvailabilityHour>> getAvailibilityHour(String providerid) {
    return _eProviderRepository.getAvailabilityByProviderId(providerid);
  }

  /*
  * Check if the form for create new service or edit
  * */
  bool isCreateForm() {
    var arguments = Get.arguments as Map<String, dynamic>;
    return arguments == null;
  }

  void createAvailibility() async {
    Get.focusScope.unfocus();
    if (!isLoading.value && availibilitySave.value.length > 0) {
      try {
        availableForm.currentState.save();
        var parameters = Get.parameters as Map<String, dynamic>;
        var providid = parameters['eprovider_id'].toString();

        isLoading.value = true;
        bool success = true;
        await availibilitySave.value.forEach((key, value) async {
          if (!value['isHoliday'].value) {
            Map<String, dynamic> data = {
              'day': value['day'],
              'start_at': value['startsat'].value,
              'end_at': value['endsat'].value,
              'data': {"en": null},
              'e_provider_id': providid,
            };
            if (!await _eProviderRepository.addAvailibility(data)) {
              success = false;
            }
          }
        });

        if (isFirstProvider.value)
          Get.offAndToNamed(Routes.E_SERVICE_FORM, parameters: {
            'isFirstProvider': isFirstProvider.value ? 'true' : 'false'
          });
        else
          Get.toNamed(Routes.E_PROVIDERS);

        if (success)
          Get.showSnackbar(Ui.SuccessSnackBar(
              message: 'Service Provider Created Successfully'));
        isLoading.value = false;
      } catch (e) {
        print(e);
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.showSnackbar(
          Ui.ErrorSnackBar(message: "Please select atleast one day".tr));
    }
  }

  void updateAvailability() async {
    print("1st UPDATE!");
    Get.focusScope.unfocus();

    if (!isLoading.value && availibilitySave.value.length > 0) {
      try {
        isLoading.value = true;
        print("UPDATE!");
        var parameters = Get.parameters as Map<String, dynamic>;
        var providid = parameters['eprovider_id'].toString();
        if (await _eProviderRepository
            .deleteAvailabilityByProviderId(providid)) {
          bool success = true;
          await availibilitySave.value.forEach((key, value) async {
            if (!value['isHoliday'].value) {
              Map<String, dynamic> data = {
                'day': value['day'],
                'start_at': value['startsat'].value,
                'end_at': value['endsat'].value,
                'data': {"en": null},
                'e_provider_id': providid,
              };
              if (!await _eProviderRepository.addAvailibility(data)) {
                success = false;
              }
            }
          });

          Get.back();

          if (success)
            Get.showSnackbar(Ui.SuccessSnackBar(
                message: 'Successfully updated Service Provider'));
          isLoading.value = false;
        }
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {}
    } else {
      Get.showSnackbar(
          Ui.ErrorSnackBar(message: "Please select atleast one day".tr));
    }
  }
}
