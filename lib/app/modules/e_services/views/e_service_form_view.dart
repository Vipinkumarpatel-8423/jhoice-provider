import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import '../../../models/category_model.dart';
import '../../../models/e_provider_model.dart';
import '../../../models/e_service_model.dart';
import '../../../models/media_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/images_field_widget.dart';
import '../../global_widgets/multi_select_dialog.dart';
import '../../global_widgets/select_dialog.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/e_service_form_controller.dart';
import '../widgets/horizontal_stepper_widget.dart';
import '../widgets/step_widget.dart';
import '../../../services/auth_service.dart';

class EServiceFormView extends GetView<EServiceFormController> {
  String durationMonth = '';
  String durationDay = '';
  String durationYear = '';
  String durationHour = '';
  String duratiionMinute = '';

  void getDuration() {
    var duration = '';
    if (durationHour != null && durationHour != '') duration += durationHour;
    if (duratiionMinute != null && duratiionMinute != '')
      duration += ':' + duratiionMinute;
    if (durationDay != null && durationDay != '')
      duration += ' ' + durationDay + ' ';
    if (durationMonth != null && durationMonth != '')
      duration += durationMonth + ' ';
    if (durationYear != null && durationYear != '')
      duration += durationYear + ' ';
    controller.eService.value.duration = duration;
  }

  @override
  Widget build(BuildContext context) {
    print(controller.eService.value);

    // var _currentUser = Get.find<AuthService>().user;
    return Scaffold(
        appBar: AppBar(
          title: Obx(() {
            return Text(
              controller.isCreateForm()
                  ? "Create Service".tr
                  : controller.eService.value.name ?? '',
              style: context.textTheme.headline6,
            );
          }),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
            onPressed: () async {
              controller.isCreateForm()
                  ? Get.back()
                  : await Get.offAndToNamed(Routes.E_SERVICE, arguments: {
                      'eService': controller.eService.value,
                      'heroTag': 'service_form_back'
                    });
            },
          ),
          elevation: 0,
          actions: [
            new IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20),
              icon: new Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 28,
              ),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Get.theme.focusColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    if (controller.isCreateForm()) {
                      controller.createEServiceForm();
                    } else {
                      controller.updateEServiceForm();
                    }
                  },
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Get.theme.accentColor,
                  child: !controller.isLoading.value
                      ? Text("Save".tr,
                          style: Get.textTheme.bodyText2
                              .merge(TextStyle(color: Get.theme.primaryColor)))
                      : CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                  elevation: 0,
                ),
              ),
              // if (controller.isCreateForm() &&
              //     !controller.isFirstProvider.value)
              //   SizedBox(width: 10),
              // if (controller.isCreateForm() &&
              //     !controller.isFirstProvider.value)
              //   MaterialButton(
              //     onPressed: () {
              //       controller.createEServiceForm(createOptions: true);
              //     },
              //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //     color: Get.theme.accentColor.withOpacity(0.2),
              //     child: Text("Save & Add Options".tr,
              //         style: Get.textTheme.bodyText2
              //             .merge(TextStyle(color: Get.theme.accentColor))),
              //     elevation: 0,
              //   ),
            ],
          ).paddingSymmetric(vertical: 10, horizontal: 20),
        ),
        body: Form(
          key: controller.eServiceForm,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (controller.isCreateForm())
                //   HorizontalStepperWidget(
                //     steps: [
                //       StepWidget(
                //         title: Text(
                //           ("Service details".tr).substring(
                //               0, min("Service details".tr.length, 15)),
                //         ),
                //         index: Text("1",
                //             style: TextStyle(color: Get.theme.primaryColor)),
                //       ),
                //       StepWidget(
                //         title: Text(
                //           ("Options details".tr).substring(
                //               0, min("Options details".tr.length, 15)),
                //         ),
                //         color: Get.theme.focusColor,
                //         index: Text("2",
                //             style: TextStyle(color: Get.theme.primaryColor)),
                //       ),
                //     ],
                //   ),
                Text("Service details".tr, style: Get.textTheme.headline5)
                    .paddingOnly(top: 25, bottom: 0, right: 22, left: 22),
                Text("Fill the following details and save them".tr,
                        style: Get.textTheme.caption)
                    .paddingSymmetric(horizontal: 22, vertical: 5),
                Obx(() {
                  return ImagesFieldWidget(
                    label: "Images".tr,
                    field: 'image',
                    tag: controller.eServiceForm.hashCode.toString(),
                    initialImages: controller.eService.value.images,
                    uploadCompleted: (uuid) {
                      controller.eService.update((val) {
                        val.images = val.images ?? [];
                        val.images.add(new Media(id: uuid));
                      });
                    },
                    reset: (uuids) {
                      controller.eService.update((val) {
                        val.images.clear();
                      });
                    },
                  );
                }),
                TextFieldWidget(
                  onSaved: (input) => controller.eService.value.name = input,
                  validator: (input) => input.length < 3
                      ? "Should be more than 3 letters".tr
                      : null,
                  initialValue: controller.eService.value.name,
                  hintText:
                      "AC Installation or Boys Hostel or Bike Servicing".tr,
                  labelText: "Name".tr,
                ),
                TextFieldWidget(
                  onSaved: (input) =>
                      controller.eService.value.description = input,
                  validator: (input) => input.length < 3
                      ? "Should be more than 3 letters".tr
                      : null,
                  keyboardType: TextInputType.multiline,
                  initialValue: controller.eService.value.description,
                  hintText: "Description for Post Party Cleaning".tr,
                  labelText: "Description".tr,
                ),
                Container(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Categories".tr,
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              final selectedValues =
                                  await showDialog<Set<Category>>(
                                context: context,
                                builder: (BuildContext context) {
                                  return MultiSelectDialog(
                                    title: "Select Categories".tr,
                                    submitText: "Submit".tr,
                                    cancelText: "Cancel".tr,
                                    items: controller
                                        .getMultiSelectCategoriesItems(),
                                    initialSelectedValues: controller.categories
                                        .where(
                                          (category) =>
                                              controller
                                                  .eService.value.categories
                                                  ?.where((element) =>
                                                      element.id == category.id)
                                                  ?.isNotEmpty ??
                                              false,
                                        )
                                        .toSet(),
                                  );
                                },
                              );
                              controller.eService.update((val) {
                                val.categories = selectedValues?.toList();
                              });
                            },
                            shape: StadiumBorder(),
                            color: Get.theme.accentColor.withOpacity(0.1),
                            child: Text("Select".tr,
                                style: Get.textTheme.subtitle1),
                            elevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                          ),
                        ],
                      ),
                      Obx(() {
                        if (controller.eService.value?.categories?.isEmpty ??
                            true) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Select categories".tr,
                              style: Get.textTheme.caption,
                            ),
                          );
                        } else {
                          return buildCategories(controller.eService.value);
                        }
                      })
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.eProviders.length > 0)
                    return Container(
                      padding: EdgeInsets.only(
                          top: 8, bottom: 10, left: 20, right: 20),
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Get.theme.focusColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5)),
                          ],
                          border: Border.all(
                              color: Get.theme.focusColor.withOpacity(0.05))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Providers".tr,
                                  style: Get.textTheme.bodyText1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  final selectedValue =
                                      await showDialog<EProvider>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SelectDialog(
                                        title: "Select Provider".tr,
                                        submitText: "Submit".tr,
                                        cancelText: "Cancel".tr,
                                        items: controller
                                            .getSelectProvidersItems(),
                                        initialSelectedValue:
                                            controller.eProviders.firstWhere(
                                          (element) =>
                                              element.id ==
                                              controller
                                                  .eService.value.eProvider?.id,
                                          orElse: () => new EProvider(),
                                        ),
                                      );
                                    },
                                  );
                                  controller.eService.update((val) {
                                    val.eProvider = selectedValue;
                                  });
                                },
                                shape: StadiumBorder(),
                                color: Get.theme.accentColor.withOpacity(0.1),
                                child: Text("Select".tr,
                                    style: Get.textTheme.subtitle1),
                                elevation: 0,
                                hoverElevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                              ),
                            ],
                          ),
                          Obx(() {
                            if (controller.eService.value?.eProvider == null) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "Select providers".tr,
                                  style: Get.textTheme.caption,
                                ),
                              );
                            } else {
                              return buildProvider(controller.eService.value);
                            }
                          })
                        ],
                      ),
                    );
                  else if (controller.eProviders.length == 1) {
                    controller.eService.value.eProvider =
                        controller.eProviders.first;
                    return SizedBox();
                  } else {
                    return SizedBox();
                  }
                }),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onSaved: (input) => controller.eService.value.price =
                            (double.tryParse(input) ?? 0),
                        validator: (input) => (double.tryParse(input) ?? 0) <= 0
                            ? "Should be number more than 0".tr
                            : null,
                        initialValue:
                            controller.eService.value.price?.toString(),
                        hintText: "23.00".tr,
                        labelText: "Price".tr,
                        suffix: Text(Get.find<SettingsService>()
                            .setting
                            .value
                            .defaultCurrency),
                      ),
                    ),
                    Expanded(
                      child: TextFieldWidget(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onSaved: (input) => controller.eService.value
                            .discountPrice = double.tryParse(input),
                        validator: (input) => (input != "") &&
                                ((double.tryParse(input) ?? 0) <= 0)
                            ? "Should be number more than 0".tr
                            : null,
                        initialValue:
                            (controller.eService.value.discountPrice ?? 0) > 0
                                ? controller.eService.value.discountPrice
                                    ?.toString()
                                : null,
                        hintText: "21.00".tr,
                        labelText: "Discount Price".tr,
                        suffix: Text(Get.find<SettingsService>()
                            .setting
                            .value
                            .defaultCurrency),
                      ),
                    ),
                  ],
                ),
                PriceAndDurationUnit(controller),
                TextFieldWidget(
                  onSaved: (input) =>
                      controller.eService.value.quantityUnit = input,
                  initialValue: controller.eService.value.quantityUnit,
                  hintText: "Piece".tr,
                  labelText: "Quantity Unit".tr,
                ),
                Obx(() {
                  return Container(
                      padding: EdgeInsets.only(
                          top: 8, bottom: 10, left: 20, right: 20),
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Get.theme.focusColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5)),
                          ],
                          border: Border.all(
                              color: Get.theme.focusColor.withOpacity(0.05))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Duration needed to complete service (Optional)".tr,
                                    style: Get.textTheme.bodyText1,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                            if (controller.eService.value.priceUnit == 'hourly')
                              Row(children: [
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: (controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(":"))
                                            ? controller.eService.value.duration
                                                .split(':')[0]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'hours',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          durationHour = text;
                                          getDuration();
                                        })),
                                SizedBox(width: 20),
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(":")
                                            ? controller.eService.value.duration
                                                .split(':')[1]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'minutes',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          duratiionMinute = text;
                                          getDuration();
                                        })),
                              ])
                            else if (controller.eService.value.priceUnit !=
                                'fixed')
                              Center(
                                  child: TextFormField(
                                      initialValue: (controller
                                                  .eService.value.duration !=
                                              null)
                                          ? controller.eService.value.duration
                                          : '',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Total ' +
                                            (controller.eService.value
                                                        .priceUnit ==
                                                    'monthly'
                                                ? 'months'
                                                : controller.eService.value
                                                            .priceUnit ==
                                                        'yearly'
                                                    ? 'years'
                                                    : controller.eService.value
                                                                .priceUnit ==
                                                            'daily'
                                                        ? 'days'
                                                        : '') +
                                            ' Needed',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                      onChanged: (text) {
                                        if (controller
                                                .eService.value.duration !=
                                            null) {
                                          controller.eService.value.duration =
                                              text.toString();
                                        }
                                      }))
                            else
                              Row(children: [
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(" ")
                                            ? controller.eService.value.duration
                                                .split(' ')[0]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'hours',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          durationHour = text;
                                          getDuration();
                                        })),
                                SizedBox(width: 5),
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(" ")
                                            ? controller.eService.value.duration
                                                .split(' ')[1]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'days',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          durationDay = text;
                                          getDuration();
                                        })),
                                SizedBox(width: 5),
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(" ")
                                            ? controller.eService.value.duration
                                                .split(' ')[2]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'months',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          durationMonth = text;
                                          getDuration();
                                        })),
                                SizedBox(width: 5),
                                Expanded(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: controller.eService.value
                                                        .duration !=
                                                    null &&
                                                controller
                                                    .eService.value.duration
                                                    .contains(" ")
                                            ? controller.eService.value.duration
                                                .split(' ')[3]
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'years',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          durationYear = text;
                                          getDuration();
                                        })),
                              ]),
                          ]));
                }),
                Container(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Location",
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              final selectedValue = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SelectDialog(
                                    title: "Select Location",
                                    submitText: "Submit".tr,
                                    cancelText: "Cancel".tr,
                                    items: [
                                      SelectDialogItem("home",
                                          "Provider will visit the customer's location"),
                                      SelectDialogItem("office",
                                          "Customer will visit the provider's location"),
                                      SelectDialogItem("both", "Both"),
                                    ],
                                    initialSelectedValue:
                                        ["home", "office", "both"].firstWhere(
                                      (element) =>
                                          element ==
                                          controller.eService.value.location,
                                      orElse: () => "",
                                    ),
                                  );
                                },
                              );
                              controller.eService.update((val) {
                                val.location = selectedValue;
                              });
                            },
                            shape: StadiumBorder(),
                            color: Get.theme.accentColor.withOpacity(0.1),
                            child: Text("Select".tr,
                                style: Get.textTheme.subtitle1),
                            elevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                          ),
                        ],
                      ),
                      Obx(() {
                        if (controller.eService.value?.location == null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Select Location",
                              style: Get.textTheme.caption,
                            ),
                          );
                        } else {
                          String text = controller.eService.value.location ==
                                  'home'
                              ? "Home"
                              : controller.eService.value.location == 'office'
                                  ? "Office"
                                  : "Both";
                          return buildSelectDisp(text);
                        }
                      })
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Mode",
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              final selectedValue = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SelectDialog(
                                    title: "Select Mode",
                                    submitText: "Submit".tr,
                                    cancelText: "Cancel".tr,
                                    items: [
                                      SelectDialogItem(
                                          "online", "Online Service"),
                                      SelectDialogItem(
                                          "offline", "Offline Service"),
                                      SelectDialogItem("both", "Both"),
                                    ],
                                    initialSelectedValue: [
                                      "online",
                                      "offline",
                                      "both"
                                    ].firstWhere(
                                      (element) =>
                                          element ==
                                          controller.eService.value.mode,
                                      orElse: () => "",
                                    ),
                                  );
                                },
                              );
                              controller.eService.update((val) {
                                val.mode = selectedValue;
                              });
                            },
                            shape: StadiumBorder(),
                            color: Get.theme.accentColor.withOpacity(0.1),
                            child: Text("Select".tr,
                                style: Get.textTheme.subtitle1),
                            elevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                          ),
                        ],
                      ),
                      Obx(() {
                        if (controller.eService.value?.mode == null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Select Mode",
                              style: Get.textTheme.caption,
                            ),
                          );
                        } else {
                          String text =
                              controller.eService.value.mode == 'online'
                                  ? "Online"
                                  : controller.eService.value.mode == 'offline'
                                      ? "Offline"
                                      : "Both";
                          return buildSelectDisp(text);
                        }
                      })
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Terms of Service",
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              print(controller.eService.value.terms);
                              final selectedValues =
                                  await showDialog<Set<String>>(
                                context: context,
                                builder: (BuildContext context) {
                                  return MultiSelectDialog(
                                    title: "Select Terms",
                                    submitText: "Submit".tr,
                                    cancelText: "Cancel".tr,
                                    items: [
                                      MultiSelectDialogItem(
                                          "Re-service accepted with in 5 days",
                                          "Re-service accepted with in 5 days"),
                                      MultiSelectDialogItem(
                                          "Fully refund if not satisfied",
                                          "Fully refund if not satisfied"),
                                      MultiSelectDialogItem(
                                          "No refund if not satisfied",
                                          "No refund if not satisfied"),
                                      MultiSelectDialogItem(
                                          "No free re-service",
                                          "No free re-service"),
                                    ],
                                    initialSelectedValues: [
                                      "Re-service accepted with in 5 days",
                                      "Fully refund if not satisfied",
                                      "No refund if not satisfied",
                                      "No free re-service"
                                    ]
                                        .where(
                                          (term) =>
                                              controller.eService.value.terms
                                                  ?.where((element) =>
                                                      element.toString() ==
                                                      term.toString())
                                                  ?.isNotEmpty ??
                                              false,
                                        )
                                        .toSet(),
                                  );
                                },
                              );
                              controller.eService.update((val) {
                                List termList = [];
                                selectedValues.forEach((element) {
                                  termList.add(element);
                                });
                                val.terms = termList;
                              });
                            },
                            shape: StadiumBorder(),
                            color: Get.theme.accentColor.withOpacity(0.1),
                            child: Text("Select".tr,
                                style: Get.textTheme.subtitle1),
                            elevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                          ),
                        ],
                      ),
                      Obx(() {
                        if (controller.eService.value?.terms == null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Select Mode",
                              style: Get.textTheme.caption,
                            ),
                          );
                        } else {
                          return buildSelectDispList(
                              controller.eService.value?.terms);
                        }
                      })
                    ],
                  ),
                ),
                TextFieldWidget(
                  onSaved: (input) =>
                      controller.eService.value.special_points = input,
                  validator: (input) => input.length < 3
                      ? "Should be more than 3 letters".tr
                      : null,
                  keyboardType: TextInputType.multiline,
                  initialValue: controller.eService.value.description,
                  hintText: "Any Special Points that is needs clarification",
                  labelText: "Special Points",
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.focusColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() {
                        return ListTileTheme(
                          contentPadding: EdgeInsets.all(0.0),
                          horizontalTitleGap: 0,
                          dense: true,
                          textColor: Get.theme.hintColor,
                          child: ListBody(
                            children: [
                              CheckboxListTile(
                                value:
                                    controller.eService.value.featured ?? false,
                                selected:
                                    controller.eService.value.featured ?? false,
                                title: Text("Featured".tr),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                onChanged: (checked) {
                                  controller.eService.update((val) {
                                    val.featured = checked;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildCategories(EService _eService) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 5,
        runSpacing: 8,
        children: List.generate(_eService.categories?.length ?? 0, (index) {
              var _category = _eService.categories.elementAt(index);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_category.name,
                    style: Get.textTheme.bodyText1
                        .merge(TextStyle(color: _category.color))),
                decoration: BoxDecoration(
                    color: _category.color.withOpacity(0.2),
                    border: Border.all(
                      color: _category.color.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              );
            }) +
            List.generate(_eService.subCategories?.length ?? 0, (index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_eService.subCategories.elementAt(index).name,
                    style: Get.textTheme.caption),
                decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    border: Border.all(
                      color: Get.theme.focusColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              );
            }),
      ),
    );
  }

  Widget buildProvider(EService _eService) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(_eService.eProvider?.name ?? '',
            style: Get.textTheme.bodyText2),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  Widget buildSelectDispList(List<dynamic> terms) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(terms?.length ?? 0, (index) {
            var term = terms.elementAt(index);
            if (term != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(term, style: Get.textTheme.bodyText2),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              );
            } else {
              return Container();
            }
          })),
    );
  }

  Widget buildSelectDisp(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(text ?? '', style: Get.textTheme.bodyText2),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Service".tr,
            style: TextStyle(color: Colors.redAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("This service will removed from your account".tr,
                    style: Get.textTheme.bodyText1),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr, style: Get.textTheme.bodyText1),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text(
                "Confirm".tr,
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Get.back();
                controller.deleteEService();
              },
            ),
          ],
        );
      },
    );
  }
}

class PriceAndDurationUnit extends StatefulWidget {
  dynamic controller;

  PriceAndDurationUnit(this.controller);

  @override
  _PriceAndDurationUnitState createState() => _PriceAndDurationUnitState();
}

class _PriceAndDurationUnitState extends State<PriceAndDurationUnit> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Get.theme.focusColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5)),
              ],
              border:
                  Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Price Unit".tr,
                style: Get.textTheme.bodyText1,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Obx(() {
                return ListTileTheme(
                  contentPadding: EdgeInsets.all(0.0),
                  horizontalTitleGap: 0,
                  dense: true,
                  textColor: Get.theme.hintColor,
                  child: ListBody(
                    children: [
                      RadioListTile(
                        value: "hourly",
                        groupValue: widget.controller.eService.value.priceUnit,
                        selected: widget.controller.eService.value.priceUnit ==
                            "hourly",
                        title: Text("Hourly".tr),
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          widget.controller.eService.update((val) {
                            val.priceUnit = "hourly";
                          });
                          setState(() {});
                        },
                      ),
                      RadioListTile(
                        value: "fixed",
                        groupValue: widget.controller.eService.value.priceUnit,
                        title: Text("Fixed".tr),
                        selected: widget.controller.eService.value.priceUnit ==
                            "fixed",
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          widget.controller.eService.update((val) {
                            val.priceUnit = "fixed";
                          });
                          setState(() {});
                        },
                      ),
                      RadioListTile(
                        value: "daily",
                        groupValue: widget.controller.eService.value.priceUnit,
                        title: Text("Daily".tr),
                        selected: widget.controller.eService.value.priceUnit ==
                            "daily",
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          widget.controller.eService.update((val) {
                            val.priceUnit = "daily";
                          });
                          setState(() {});
                        },
                      ),
                      RadioListTile(
                        value: "monthly",
                        groupValue: widget.controller.eService.value.priceUnit,
                        title: Text("Monthly".tr),
                        selected: widget.controller.eService.value.priceUnit ==
                            "monthly",
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          widget.controller.eService.update((val) {
                            val.priceUnit = "monthly";
                          });
                          setState(() {});
                        },
                      ),
                      RadioListTile(
                        value: "yearly",
                        groupValue: widget.controller.eService.value.priceUnit,
                        title: Text("Yearly".tr),
                        selected: widget.controller.eService.value.priceUnit ==
                            "yearly",
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          widget.controller.eService.update((val) {
                            val.priceUnit = "yearly";
                          });
                          setState(() {});
                        },
                      )
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        widget.controller.eService.value.priceUnit == "fixed"
            ? Container()
            // Container(
            //     padding: EdgeInsets.all(20),
            //     margin: EdgeInsets.all(20),
            //     decoration: BoxDecoration(
            //         color: Get.theme.primaryColor,
            //         borderRadius: BorderRadius.all(Radius.circular(10)),
            //         boxShadow: [
            //           BoxShadow(
            //               color: Get.theme.focusColor.withOpacity(0.1),
            //               blurRadius: 10,
            //               offset: Offset(0, 5)),
            //         ],
            //         border: Border.all(
            //             color: Get.theme.focusColor.withOpacity(0.05))),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.stretch,
            //       children: [
            //         Text(
            //           "Duration Unit".tr,
            //           style: Get.textTheme.bodyText1,
            //           textAlign: TextAlign.start,
            //         ),
            //         SizedBox(height: 10),
            //         Obx(() {
            //           return ListTileTheme(
            //             contentPadding: EdgeInsets.all(0.0),
            //             horizontalTitleGap: 0,
            //             dense: true,
            //             textColor: Get.theme.hintColor,
            //             child: ListBody(
            //               children: [
            //                 RadioListTile(
            //                   value: "hourly",
            //                   groupValue:
            //                       widget.controller.eService.value.fixedUnit,
            //                   selected:
            //                       widget.controller.eService.value.fixedUnit ==
            //                           "hourly",
            //                   title: Text("Hourly".tr),
            //                   controlAffinity: ListTileControlAffinity.trailing,
            //                   onChanged: (checked) {
            //                     widget.controller.eService.update((val) {
            //                       val.fixedUnit = "hourly";
            //                     });
            //                   },
            //                 ),
            //                 RadioListTile(
            //                   value: "daily",
            //                   groupValue:
            //                       widget.controller.eService.value.fixedUnit,
            //                   title: Text("Daily".tr),
            //                   selected:
            //                       widget.controller.eService.value.fixedUnit ==
            //                           "daily",
            //                   controlAffinity: ListTileControlAffinity.trailing,
            //                   onChanged: (checked) {
            //                     widget.controller.eService.update((val) {
            //                       val.fixedUnit = "daily";
            //                     });
            //                   },
            //                 ),
            //                 RadioListTile(
            //                   value: "monthly",
            //                   groupValue:
            //                       widget.controller.eService.value.fixedUnit,
            //                   title: Text("Monthly".tr),
            //                   selected:
            //                       widget.controller.eService.value.fixedUnit ==
            //                           "monthly",
            //                   controlAffinity: ListTileControlAffinity.trailing,
            //                   onChanged: (checked) {
            //                     widget.controller.eService.update((val) {
            //                       val.fixedUnit = "monthly";
            //                     });
            //                   },
            //                 ),
            //                 RadioListTile(
            //                   value: "yearly",
            //                   groupValue:
            //                       widget.controller.eService.value.fixedUnit,
            //                   title: Text("Yearly".tr),
            //                   selected:
            //                       widget.controller.eService.value.fixedUnit ==
            //                           "yearly",
            //                   controlAffinity: ListTileControlAffinity.trailing,
            //                   onChanged: (checked) {
            //                     widget.controller.eService.update((val) {
            //                       val.fixedUnit = "yearly";
            //                     });
            //                   },
            //                 )
            //               ],
            //             ),
            //           );
            //         }),
            //       ],
            //     ),
            //   )
            : Container(),
      ],
    );
  }
}
