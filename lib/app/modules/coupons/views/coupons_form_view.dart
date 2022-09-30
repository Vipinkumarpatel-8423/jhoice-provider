import 'dart:math';
import 'package:html/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/coupons/controllers/coupons_form_controller.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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

class CustomCouponFormView extends GetView<CustomCouponFormController> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    print(controller.coupon.value);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            controller.isCreateForm()
                ? "Create Coupon".tr
                : controller.coupon.value['code'] ?? '',
            style: context.textTheme.headline6,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
            onPressed: () async {
              await Get.offAndToNamed(Routes.COUPONS);
            },
          ),
          elevation: 0,
          actions: [
            controller.isCreateForm()
                ? Container()
                : new IconButton(
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
                    
                    if (!controller.coupon.containsKey('id')) {
                      controller.createCouponForm();
                    } else {
                      controller.updateCouponForm();
                    }
                  },
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Get.theme.accentColor,
                  child: Obx(() {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.isLoading.value
                            ? SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )).marginOnly(right: 12)
                            : SizedBox(),
                        Text("Save".tr,
                            style: Get.textTheme.bodyText2.merge(
                                TextStyle(color: Get.theme.primaryColor))),
                      ],
                    );
                  }),
                  elevation: 0,
                ),
              ),
            ],
          ).paddingSymmetric(vertical: 10, horizontal: 20),
        ),
        body: Form(
          key: controller.couponForm,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Coupon Details".tr, style: Get.textTheme.headline5)
                    .paddingOnly(top: 25, bottom: 0, right: 22, left: 22),
                Text("Fill the following details and save them".tr,
                        style: Get.textTheme.caption)
                    .paddingSymmetric(horizontal: 22, vertical: 5),
                controller.isCreateForm()? TextFieldWidget(
                  onSaved: (input) => controller.coupon.addAll({'code': input}),
                  validator: (input) => input.length < 3
                      ? "Should be more than 3 letters".tr
                      : null,
                  initialValue: controller.coupon.value['code'],
                  hintText: "DISCOUNT50",
                  labelText: "Coupon Code",
                ):Container(
                  padding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  margin:
                      EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
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
                              "Coupon Code",
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.coupon.value['code']??"",
                              style: Get.textTheme.bodyText2,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ]
                      ),
                    ]
                  )
                ),
                TextFieldWidget(
                  onSaved: (input) =>
                      controller.coupon.addAll({'description': input}),
                  validator: (input) => input.length < 3
                      ? "Should be more than 3 letters".tr
                      : null,
                  keyboardType: TextInputType.multiline,
                  initialValue: controller.coupon.value["description"] != null? (!(controller.coupon.value["description"] is String)) && controller.coupon.value["description"].containsKey('en')? _parseHtmlString(controller.coupon.value["description"]["en"]) : _parseHtmlString(controller.coupon.value["description"]) : controller.coupon.value["description"],
                  hintText: "Description for DISCOUNT50 Coupon".tr,
                  labelText: "Description".tr,
                ),
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
                      border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Discount Type",
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
                                value: "percent",
                                groupValue:
                                    controller.coupon.value['discount_type'],
                                selected:
                                    controller.coupon.value['discount_type'] ==
                                        "percent",
                                title: Text("Percent"),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                onChanged: (checked) {
                                  controller.coupon
                                      .addAll({'discount_type': 'percent'});
                                },
                              ),
                              RadioListTile(
                                value: "fixed",
                                groupValue:
                                    controller.coupon.value['discount_type'],
                                selected:
                                    controller.coupon.value['discount_type'] ==
                                        "fixed",
                                title: Text("Fixed"),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                onChanged: (checked) {
                                  controller.coupon
                                      .addAll({'discount_type': 'fixed'});
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                TextFieldWidget(
                  onSaved: (input) =>
                      controller.coupon.addAll({'discount': input}),
                  validator: (input) => input.isBlank ? "Required" : null,
                  initialValue: controller.coupon.value['discount'] != null
                      ? controller.coupon.value['discount'].toString()
                      : '',
                  hintText: "Money that is to be discounted",
                  labelText: "Discount",
                  keyboardType: TextInputType.number,
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
                                                  .coupon.value['categories']
                                                  ?.where((element) =>
                                                      element.toString() ==
                                                      category.id.toString())
                                                  ?.isNotEmpty ??
                                              false,
                                        )
                                        .toSet(),
                                  );
                                },
                              );
                              if (selectedValues != null) {
                                
                                controller.coupon.addAll({
                                  'categories': selectedValues
                                          ?.map((e) => e.id)
                                          ?.toList()
                                });
                                print(controller.coupon['categories']);
                              }
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
                        if (controller.coupon.value['categories']?.isEmpty ??
                            true) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Select categories".tr,
                              style: Get.textTheme.caption,
                            ),
                          );
                        } else {
                          return buildCategories(controller.coupon.value);
                        }
                      })
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.eProviders.length > 1)
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
                                  final selectedValues =
                                      await showDialog<Set<EProvider>>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return MultiSelectDialog(
                                        title: "Select Provider".tr,
                                        submitText: "Submit".tr,
                                        cancelText: "Cancel".tr,
                                        items: controller
                                            .getSelectProvidersItems(),
                                        initialSelectedValues: controller
                                            .eProviders
                                            .where(
                                              (provider) =>
                                                  controller.coupon
                                                      .value['eProviders']
                                                      ?.where((element) =>
                                                          element.toString() ==
                                                          provider.id
                                                              .toString())
                                                      ?.isNotEmpty ??
                                                  false,
                                            )
                                            .toSet(),
                                      );
                                    },
                                  );
                                  // if(controller.coupon.containsKey('eProviders')){
                                  //   List<EProvider> provider = controller.coupon.value['eProviders'];
                                  //   provider.add(selectedValue);
                                  //   controller.coupon.addAll(
                                  //     {'eProviders': provider});
                                  // }else{
                                  //
                                  // }

                                  if (selectedValues != null) {
                                    controller.coupon.addAll({
                                      'eProviders': selectedValues
                                              ?.map((e) => e.id)
                                              ?.toList()
                                    });
                                  }

                                  // controller.eService.update((val) {
                                  //   val.eProvider = selectedValue;
                                  // });
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
                            if (controller.coupon.value['eProviders'] == null) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "Select providers".tr,
                                  style: Get.textTheme.caption,
                                ),
                              );
                            } else {
                              return buildProvider(Map<dynamic, dynamic>.from(
                                  controller.coupon.toJson()));
                            }
                          })
                        ],
                      ),
                    );
                  else if (controller.eProviders.length == 1) {
                    controller.coupon.value['eProviders'] = [
                      controller.eProviders.first.id
                    ];
                    return SizedBox();
                  } else {
                    return SizedBox();
                  }
                }),
                Obx(() {
                  if (controller.eServices.length > 1) {
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
                                  "Services",
                                  style: Get.textTheme.bodyText1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  final selectedValues =
                                      await showDialog<Set<EService>>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return MultiSelectDialog(
                                        title: "Select Provider".tr,
                                        submitText: "Submit".tr,
                                        cancelText: "Cancel".tr,
                                        items:
                                            controller.getSelectServiceItems(),
                                        initialSelectedValues: controller
                                            .eServices
                                            .where(
                                              (provider) =>
                                                  controller
                                                      .coupon.value['eServices']
                                                      ?.where((element) =>
                                                          element.toString() ==
                                                          provider.id
                                                              .toString())
                                                      ?.isNotEmpty ??
                                                  false,
                                            )
                                            .toSet(),
                                      );
                                    },
                                  );
                                  // if(controller.coupon.containsKey('eProviders')){
                                  //   List<EProvider> provider = controller.coupon.value['eProviders'];
                                  //   provider.add(selectedValue);
                                  //   controller.coupon.addAll(
                                  //     {'eProviders': provider});
                                  // }else{
                                  //
                                  // }
                                  if (selectedValues != null) {
                                    controller.coupon.addAll({
                                      'eServices': selectedValues
                                              ?.map((e) => e.id)
                                              ?.toList()
                                    });
                                  }
                                  // controller.eService.update((val) {
                                  //   val.eProvider = selectedValue;
                                  // });
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
                            if (controller.coupon.value['eServices'] == null) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "Select Services",
                                  style: Get.textTheme.caption,
                                ),
                              );
                            } else {
                              return buildServices(Map<dynamic, dynamic>.from(
                                  controller.coupon.toJson()));
                            }
                          })
                        ],
                      ),
                    );
                  } else if (controller.eServices.length == 1) {
                    controller.coupon.value['eServices'] = [
                      controller.eServices.first
                    ];
                    return SizedBox();
                  } else {
                    return SizedBox();
                  }
                }),
                // TextFieldWidget(
                //   onSaved: (input) =>
                //       controller.coupon.value['expires_at'] = input,
                //   initialValue: controller.coupon.value['expires_at'],
                //   validator: (input) => input.isEmpty? "Should be a valid datetime"
                //       : null,
                //   hintText: "Enter date when this coupon will expire",
                //   labelText: "Expires at",
                //   keyboardType: TextInputType.datetime,
                // ),
                Container(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expires At",
                              style: Get.textTheme.bodyText1,
                              textAlign: TextAlign.start,
                            ),
                            GestureDetector(
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  showTitleActions: true,
                                  minTime: DateTime.now(),
                                  onConfirm: (date) {
                                    print(date);
                                    controller.coupon.addAll({
                                      'expires_at': date
                                          .toString()
                                          .replaceAll(':00.000', '')
                                    });
                                  },
                                  // currentTime: controller
                                  //             .coupon.value['expires_at'] !=
                                  //         null
                                  //     ? DateTime.tryParse(
                                  //         controller.coupon.value['expires_at'])
                                  //     : DateTime.now(),
                                );
                              },
                              child: Obx(() {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: (controller.coupon.value['expires_at']
                                              ?.isEmpty ??
                                          true)
                                      ? Text(
                                          "Select Date and Time",
                                          style: Get.textTheme.caption,
                                        )
                                      : Text(
                                          controller.coupon.value['expires_at']
                                              .toString(),
                                          style: Get.textTheme.caption,
                                        ),
                                );
                              }),
                            )
                          ],
                        )
                      ],
                    )),
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
                                    controller.coupon.value['enabled'] ?? false,
                                selected:
                                    controller.coupon.value['enabled'] ?? false,
                                title: Text("Enabled"),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                onChanged: (checked) {
                                  controller.coupon
                                      .addAll({'enabled': checked});
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

  Widget buildCategories(Map<dynamic, dynamic> coupon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 5,
        runSpacing: 8,
        children: List.generate(coupon['categories']?.length ?? 0, (index) {
              var category_id = coupon['categories'].elementAt(index);
              Category _category = (controller.categories.firstWhere(
                  (category) =>
                      (category.id).toString() == (category_id).toString(),
                  orElse: () => null));
              if (_category != null) {
                print(_category.name);
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
              } else {
                return Container();
              }
            }) 
      ),
    );
  }

  Widget buildProvider(Map<dynamic, dynamic> coupon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(coupon['eProviders']?.length ?? 0, (index) {
            var provider_id = coupon['eProviders'].elementAt(index);
            EProvider _provider = (controller.eProviders.firstWhere(
                (provider) =>
                    (provider.id).toString() == (provider_id).toString(),
                orElse: () => null));
            if (_provider != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_provider.name, style: Get.textTheme.bodyText2),
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

  Widget buildServices(Map<dynamic, dynamic> coupon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(coupon['eServices']?.length ?? 0, (index) {
            var service_id = coupon['eServices'].elementAt(index);
            EService _service = (controller.eServices.firstWhere(
                (service) => (service.id).toString() == (service_id).toString(),
                orElse: () => null));
            if (_service != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_service.name, style: Get.textTheme.bodyText2),
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

  // Widget buildProvider(Map<dynamic, dynamic> coupon) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 10),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(vertical: 4),
  //       child: Text(coupon['eProviders']['name'] ?? '',
  //           style: Get.textTheme.bodyText2),
  //       decoration:
  //           BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
  //     ),
  //   );
  // }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Coupon".tr,
            style: TextStyle(color: Colors.redAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("This coupon will removed from your account".tr,
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
                controller.deleteCoupon();
              },
            ),
          ],
        );
      },
    );
  }
}
