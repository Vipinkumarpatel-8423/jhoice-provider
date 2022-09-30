import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

import '../../../../common/helper.dart';
import '../../../../common/ui.dart';
import '../../../models/setting_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  final Setting _settings = Get.find<SettingsService>().setting.value;

  StreamSubscription streamSubscription;

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }
    //super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.loginFormKey = new GlobalKey<FormState>();
    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Login".tr,
            style: Get.textTheme.headline6
                .merge(TextStyle(color: context.theme.primaryColor)),
          ),
          centerTitle: true,
          backgroundColor: Get.theme.accentColor,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Form(
          key: controller.loginFormKey,
          child: ListView(
            primary: true,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    height: 180,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Get.theme.accentColor,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                    ),
                    margin: EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _settings.appName,
                            style: Get.textTheme.headline6.merge(TextStyle(
                                color: Get.theme.primaryColor, fontSize: 24)),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Welcome to the best service provider system!".tr,
                            style: Get.textTheme.caption.merge(
                                TextStyle(color: Get.theme.primaryColor)),
                            textAlign: TextAlign.center,
                          ),
                          // Text("Fill the following credentials to login your account", style: Get.textTheme.caption.merge(TextStyle(color: Get.theme.primaryColor))),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: Ui.getBoxDecoration(
                      radius: 14,
                      border:
                          Border.all(width: 5, color: Get.theme.primaryColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (controller.loading.isTrue)
                  return CircularLoadingWidget(height: 300);
                else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFieldWidget(
                        labelText: "Email Address".tr,
                        hintText: "johndoe@gmail.com".tr,
                        initialValue: controller.currentUser?.value?.email,
                        onSaved: (input) =>
                            controller.currentUser.value.email = input,
                        validator: (input) => !input.contains('@')
                            ? "Should be a valid email".tr
                            : null,
                        iconData: Icons.alternate_email,
                      ),
                      Obx(() {
                        return TextFieldWidget(
                          labelText: "Password".tr,
                          hintText: "••••••••••••".tr,
                          initialValue: controller.currentUser?.value?.password,
                          onSaved: (input) =>
                              controller.currentUser.value.password = input,
                          validator: (input) => input.length < 3
                              ? "Should be more than 3 characters".tr
                              : null,
                          obscureText: controller.hidePassword.value,
                          iconData: Icons.lock_outline,
                          keyboardType: TextInputType.visiblePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.hidePassword.value =
                                  !controller.hidePassword.value;
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(controller.hidePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.toNamed(Routes.FORGOT_PASSWORD);
                            },
                            child: Text("Forgot Password?".tr),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 20),
                      BlockButtonWidget(
                        onPressed: () {
                          controller.login();
                        },
                        color: Get.theme.accentColor,
                        text: Text(
                          "Login".tr,
                          style: Get.textTheme.headline6
                              .merge(TextStyle(color: Get.theme.primaryColor)),
                        ),
                      ).paddingSymmetric(vertical: 10, horizontal: 20),
                      Text(
                        "Or Continue With".tr,
                        style: Get.textTheme.overline,
                        textAlign: TextAlign.center,
                      ).paddingSymmetric(vertical: 10),
                      BlockButtonWidget(
                        onPressed: () {
                          print('pressed');
                          controller.loginWithGoogle();
                        },
                        color: Colors.white,
                        text: Image.asset('assets/img/google-logo.png',
                            width: 60),
                      ).paddingSymmetric(vertical: 5, horizontal: 20),
                      // BlockButtonWidget(
                      //   onPressed: () {
                      //     controller.loginWithFacebook();
                      //   },
                      //   color: Colors.white,
                      //   text: Image.asset('assets/img/facebook-logo.png', width: 85),
                      // ).paddingSymmetric(vertical: 5, horizontal: 20),
                      BlockButtonWidget(
                        onPressed: () {
                          TruecallerSdk.initializeSDK(
                              sdkOptions:
                                  TruecallerSdkScope.SDK_OPTION_WITHOUT_OTP);

                          //OR you can also replace Step 2 and Step 3 directly with this
                          TruecallerSdk.isUsable.then((isUsable) {
                            isUsable
                                ? TruecallerSdk.getProfile
                                : Get.showSnackbar(Ui.ErrorSnackBar(
                                    message:
                                        "You require truecaller app to use this feature."));
                          });

                          streamSubscription = TruecallerSdk.streamCallbackData
                              .listen((truecallerSdkCallback) async {
                            switch (truecallerSdkCallback.result) {
                              case TruecallerSdkCallbackResult.success:
                                print(
                                    truecallerSdkCallback.profile.accessToken);
                                Map<String, dynamic> result = {
                                  "name":
                                      "${truecallerSdkCallback.profile.firstName ?? ''} ${truecallerSdkCallback.profile.lastName ?? ''}",
                                  "email": truecallerSdkCallback.profile.email,
                                  "token":
                                      truecallerSdkCallback.profile.phoneNumber,
                                  "phone_number":
                                      truecallerSdkCallback.profile.phoneNumber,
                                  "avatar_original":
                                      truecallerSdkCallback.profile.avatarUrl,
                                };
                                print("SUCCESS");
                                controller.loginWithTrueCaller(result);

                                break;
                              case TruecallerSdkCallbackResult.failure:
                                Get.showSnackbar(Ui.ErrorSnackBar(
                                    message:
                                        "Authentication failed. Error Code: ${truecallerSdkCallback.error.code}"));
                                print(
                                    "Error code : ${truecallerSdkCallback.error.code}");
                                break;
                              case TruecallerSdkCallbackResult.verification:
                                Get.showSnackbar(Ui.ErrorSnackBar(
                                    message:
                                        "Your Phone number needs to be verified."));
                                break;
                              default:
                                print("Invalid result");
                            }
                          });
                        },
                        color: Colors.white,
                        text: Image.asset('assets/img/truecaller-logo.png',
                            width: 85),
                      ).paddingSymmetric(vertical: 5, horizontal: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.toNamed(Routes.REGISTER);
                            },
                            child: Text("You don't have an account?".tr),
                          ),
                        ],
                      ).paddingSymmetric(vertical: 20),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
