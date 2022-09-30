import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/models/campaign_model.dart';
import 'package:home_services_provider/app/repositories/notification_repository.dart';

import '../../../../common/ui.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_messaging_service.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

class AuthController extends GetxController {
  final Rx<User> currentUser = Get.find<AuthService>().user;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<FormState> registerFormKey;
  GlobalKey<FormState> forgotPasswordFormKey;
  final hidePassword = true.obs;
  final loading = false.obs;
  final smsSent = ''.obs;
  final campaign = <Campaign>[].obs;

  UserRepository _userRepository;
  NotificationRepository _notificationRepository;

  AuthController() {
    _userRepository = UserRepository();
    _notificationRepository = new NotificationRepository();
  }

  void login() async {
    Get.focusScope.unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      loading.value = true;
      try {
        await Get.find<FireBaseMessagingService>().setDeviceToken();
        currentUser.value = await _userRepository.login(currentUser.value);
        await _userRepository.signInWithEmailAndPassword(
            currentUser.value.email, currentUser.value.apiToken);
        loading.value = false;
        await Get.toNamed(Routes.ROOT, arguments: 0);
      } catch (e) {
        loading.value = false;
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
      }
    } else {
      loading.value = false;
    }
  }

  void loginWithGoogle() async {
    Get.focusScope.unfocus();
    loading.value = true;
    try {
      await Get.find<FireBaseMessagingService>().setDeviceToken();
      // await _userRepository
      Map<String, dynamic> result = await _userRepository.signInGoogle();
      currentUser.value = await _userRepository.loginSocial(result);
      loading.value = false;
      await Get.toNamed(Routes.ROOT, arguments: 0);
    } catch (e) {
      print(e);
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      print('done');
      loading.value = false;
    }
  }

  void loginWithFacebook() async {
    Get.focusScope.unfocus();
    loading.value = true;
    try {
      await Get.find<FireBaseMessagingService>().setDeviceToken();
      // await _userRepository
      Map<String, dynamic> result = await _userRepository.signInFacebook();
      currentUser.value = await _userRepository.loginSocial(result);
      loading.value = false;
      await Get.toNamed(Routes.ROOT, arguments: 0);
    } catch (e) {
      print(e);
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      print('done');
      loading.value = false;
    }
  }

  void loginWithTrueCaller(Map<String, dynamic> result) async {
    Get.focusScope.unfocus();
    loading.value = true;

    try {
      await Get.find<FireBaseMessagingService>().setDeviceToken();

      currentUser.value = await _userRepository.loginSocial(result);
      fba.UserCredential userCredential =
          await fba.FirebaseAuth.instance.signInAnonymously();

      loading.value = false;
      await Get.toNamed(Routes.ROOT, arguments: 0);
    } catch (e) {
      print(e);
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      loading.value = false;
    }
  }

  void register() async {
    loading.value = true;
    Get.focusScope.unfocus();
    if (registerFormKey.currentState.validate()) {
      registerFormKey.currentState.save();

      try {
        // await _userRepository.sendCodeToPhone();
        // loading.value = false;
        // await Get.toNamed(Routes.PHONE_VERIFICATION);
        await verifyPhone();
        //this one used here for removing phone verification
      } catch (e) {
        loading.value = false;
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        // print('fjdfs');
        // loading.value = false;
      }
    } else {
      loading.value = false;
    }
  }

  Future getCampaign() async {
    try {
      campaign.assignAll(await _notificationRepository.getCampigns());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future<void> verifyPhone() async {
    try {
      // await _userRepository.verifyPhone(smsSent.value);
      await Get.find<FireBaseMessagingService>().setDeviceToken();
      _userRepository.register(currentUser.value).then((value) async {
        currentUser.value = value;
        await _userRepository.signUpWithEmailAndPassword(
            currentUser.value.email, currentUser.value.apiToken);
        // await Get.find<AuthService>().removeCurrentUser();
        loading.value = false;
        await Get.offAndToNamed(Routes.ROOT);
      }).catchError((error) {
        print(error.message);
        loading.value = false;

        Get.showSnackbar(Ui.ErrorSnackBar(
            message: error.message != null
                ? error.message
                    .toString()
                    .replaceAll("[", "")
                    .replaceAll("]", "")
                : error.toString()));
      });
    } catch (e) {
      loading.value = false;
      // Get.toNamed(Routes.REGISTER);

      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      // loading.value = false;
    }
  }

  void sendResetLink() async {
    Get.focusScope.unfocus();
    if (forgotPasswordFormKey.currentState.validate()) {
      forgotPasswordFormKey.currentState.save();
      loading.value = true;
      try {
        await _userRepository.sendResetLinkEmail(currentUser.value);
        loading.value = false;
        Get.showSnackbar(Ui.SuccessSnackBar(
            message:
                "The Password reset link has been sent to your email: ".tr +
                    currentUser.value.email));
        Timer(Duration(seconds: 5), () {
          Get.offAndToNamed(Routes.LOGIN);
        });
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
      }
    }
  }
}
