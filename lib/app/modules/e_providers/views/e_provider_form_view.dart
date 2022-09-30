import 'dart:math';
import 'package:home_services_provider/app/models/e_provider_type_model.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_form_controller.dart';
import 'package:home_services_provider/app/modules/e_services/widgets/horizontal_stepper_widget.dart';
import 'package:home_services_provider/app/modules/e_services/widgets/step_widget.dart';
import 'package:home_services_provider/app/modules/global_widgets/circular_loading_widget.dart';
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

class EProviderFormView extends GetView<EProviderFormController> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isCreateForm()
              ? "Create Service Provider".tr
              : controller.eProvider.value.name ?? '',
          style: context.textTheme.headline6,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
          onPressed: () async {
            await Get.back();
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
                  if (controller.eProvider.value.id == null) {
                    controller.createProviderForm();
                  } else {
                    controller.updateProviderForm();
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
                      Text("Next".tr,
                          style: Get.textTheme.bodyText2
                              .merge(TextStyle(color: Get.theme.primaryColor))),
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
        key: controller.providerForm,
        child: SingleChildScrollView(
          child: Obx(() {
            if (controller.pageLoading.value)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularLoadingWidget(height: 300),
                ],
              );
            else
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HorizontalStepperWidget(
                    steps: [
                      StepWidget(
                        title: Text(
                          ("Provider details".tr).substring(
                              0, min("Provider details".tr.length, 15)),
                        ),
                        index: Text("1",
                            style: TextStyle(color: Get.theme.primaryColor)),
                      ),
                      StepWidget(
                        title: Text(
                          ("Availability".tr)
                              .substring(0, min("Availability".tr.length, 15)),
                        ),
                        color: Get.theme.focusColor,
                        index: Text("2",
                            style: TextStyle(color: Get.theme.primaryColor)),
                      ),
                    ],
                  ),
                  Text("Provider Details", style: Get.textTheme.headline5)
                      .paddingOnly(top: 25, bottom: 0, right: 22, left: 22),
                  Text("Fill the following details and save them".tr,
                          style: Get.textTheme.caption)
                      .paddingSymmetric(horizontal: 22, vertical: 5),
                  Obx(() {
                    return ImagesFieldWidget(
                      label: "Images".tr,
                      field: 'image',
                      tag: controller.providerForm.hashCode.toString(),
                      initialImages: controller.eProvider.value.images,
                      uploadCompleted: (uuid) {
                        controller.eProvider.update((val) {
                          val.images = val.images ?? [];
                          val.images.add(new Media(id: uuid));
                        });
                      },
                      reset: (uuids) {
                        controller.eProvider.update((val) {
                          val.images.clear();
                        });
                      },
                    );
                  }),
                  TextFieldWidget(
                    onSaved: (input) => controller.eProvider.value.name = input,
                    validator: (input) => input.length < 3
                        ? "Should be more than 3 letters".tr
                        : null,
                    initialValue: controller.eProvider.value.name,
                    hintText: "Personal Name  or Shop Name or Office Name",
                    labelText: "Provider Name",
                  ),
                  Obx(() {
                    if (controller.eProviderType.length > 1)
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
                                    "Provider Type",
                                    style: Get.textTheme.bodyText1,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    final selectedValue = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SelectDialog(
                                          title: "Select Provider Type",
                                          submitText: "Submit".tr,
                                          cancelText: "Cancel".tr,
                                          items: controller
                                              .getSelectProviderTypeItems(),
                                          initialSelectedValue: controller
                                              .eProviderType
                                              .firstWhere(
                                            (element) {
                                              if (controller
                                                      .eProvider.value.type ==
                                                  null) {
                                                return false;
                                              }
                                              return element["id"] ==
                                                  controller
                                                      .eProvider.value.type;
                                            },
                                            orElse: () => Set(),
                                          ),
                                        );
                                      },
                                    );
                                    if (selectedValue != null) {
                                      controller.eProvider.update((val) {
                                        val.type = selectedValue["id"];
                                      });
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
                              if (controller.eProvider.value?.type == null) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "Select Providers Type",
                                    style: Get.textTheme.caption,
                                  ),
                                );
                              } else {
                                return buildProviderType(
                                    controller.eProvider.value.type);
                              }
                            })
                          ],
                        ),
                      );
                    else if (controller.eProviderType.length == 1) {
                      controller.eProvider.value.type =
                          controller.eProviderType.first;
                      return SizedBox();
                    } else {
                      return SizedBox();
                    }
                  }),

                  //=============================

                  // Container(
                  //   padding: EdgeInsets.only(
                  //       top: 8, bottom: 10, left: 20, right: 20),
                  //   margin: EdgeInsets.only(
                  //       left: 20, right: 20, top: 20, bottom: 20),
                  //   decoration: BoxDecoration(
                  //       color: Get.theme.primaryColor,
                  //       borderRadius: BorderRadius.all(Radius.circular(10)),
                  //       boxShadow: [
                  //         BoxShadow(
                  //             color: Get.theme.focusColor.withOpacity(0.1),
                  //             blurRadius: 10,
                  //             offset: Offset(0, 5)),
                  //       ],
                  //       border: Border.all(
                  //           color: Get.theme.focusColor.withOpacity(0.05))),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //             child: Text(
                  //               "Employees",
                  //               style: Get.textTheme.bodyText1,
                  //               textAlign: TextAlign.start,
                  //             ),
                  //           ),
                  //           MaterialButton(
                  //             onPressed: () async {
                  //               final selectedValue = await showDialog(
                  //                 context: context,
                  //                 builder: (BuildContext context) {
                  //                   return MultiSelectDialog(
                  //                     title: "Select Employees".tr,
                  //                     submitText: "Submit".tr,
                  //                     cancelText: "Cancel".tr,
                  //                     items: controller.getUserItems(),
                  //                     initialSelectedValues: controller.users
                  //                         .where(
                  //                           (user) =>
                  //                               controller
                  //                                   .eProvider.value.employees
                  //                                   ?.where((element) =>
                  //                                       element.toString() ==
                  //                                       user['id'].toString())
                  //                                   ?.isNotEmpty ??
                  //                               false,
                  //                         )
                  //                         .toSet(),
                  //                   );
                  //                 },
                  //               );
                  //               if (selectedValue != null) {
                  //                 List empList = [];
                  //                 selectedValue.forEach((element) {
                  //                   empList.add(element["id"]);
                  //                 });
                  //                 print(selectedValue.toList());
                  //                 controller.eProvider.update((val) {
                  //                   val.employees = empList;
                  //                 });
                  //               }
                  //             },
                  //             shape: StadiumBorder(),
                  //             color: Get.theme.accentColor.withOpacity(0.1),
                  //             child: Text("Select".tr,
                  //                 style: Get.textTheme.subtitle1),
                  //             elevation: 0,
                  //             hoverElevation: 0,
                  //             focusElevation: 0,
                  //             highlightElevation: 0,
                  //           ),
                  //         ],
                  //       ),
                  //       Obx(() {
                  //         if (controller.eProvider.value?.employees == null) {
                  //           return Padding(
                  //             padding: EdgeInsets.symmetric(vertical: 20),
                  //             child: Text(
                  //               "Select Employees",
                  //               style: Get.textTheme.caption,
                  //             ),
                  //           );
                  //         } else {
                  //           return buildEmployees(
                  //               controller.eProvider.value.employees);
                  //         }
                  //       })
                  //     ],
                  //   ),
                  // ),

                  //=============================

                  TextFieldWidget(
                    onSaved: (input) =>
                        controller.eProvider.value.description = input,
                    validator: (input) => input.length < 3
                        ? "Should be more than 3 letters".tr
                        : null,
                    keyboardType: TextInputType.multiline,
                    initialValue: controller.eProvider.value.description != null
                        ? _parseHtmlString(
                            controller.eProvider.value.description)
                        : '',
                    hintText: "Description for this provider",
                    labelText: "Description".tr,
                  ),

                  //=============================

                  TextFieldWidget(
                    onSaved: (input) =>
                        controller.eProvider.value.phoneNumber = input,
                    validator: (input) => input.length < 3
                        ? "Should be more than 3 letters".tr
                        : null,
                    initialValue: controller.eProvider.value.phoneNumber,
                    keyboardType: TextInputType.phone,
                    hintText: "Provider Phone Number",
                    labelText: "Phone Number",
                  ),

                  //=============================

                  TextFieldWidget(
                    onSaved: (input) =>
                        controller.eProvider.value.mobileNumber = input,
                    validator: (input) => input.length < 3
                        ? "Should be more than 3 letters".tr
                        : null,
                    initialValue: controller.eProvider.value.mobileNumber,
                    keyboardType: TextInputType.phone,
                    hintText: "Provider Mobile Number",
                    labelText: "Mobile Number",
                  ),

                  //============================================

                  Container(
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
                                "Addresses",
                                style: Get.textTheme.bodyText1,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                final selectedValue = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MultiSelectDialog(
                                      title: "Select Addresses",
                                      submitText: controller.addresses !=
                                                  null &&
                                              controller.addresses.isNotEmpty
                                          ? "Submit".tr
                                          : "Create Address".tr,
                                      cancelText: "Cancel".tr,
                                      items: controller.getAddressItems(),
                                      initialSelectedValues: controller
                                          .addresses
                                          .where(
                                            (address) =>
                                                controller
                                                    .eProvider.value.addresses
                                                    ?.where((element) =>
                                                        element.toString() ==
                                                        address['id']
                                                            .toString())
                                                    ?.isNotEmpty ??
                                                false,
                                          )
                                          .toSet(),
                                    );
                                  },
                                );
                                if (!(controller.addresses != null &&
                                        controller.addresses.isNotEmpty) &&
                                    selectedValue != null)
                                  Get.toNamed(Routes.ADDRESS_PICKER);
                                else if (selectedValue != null) {
                                  List addList = [];
                                  selectedValue.forEach((element) {
                                    addList.add(element["id"]);
                                  });
                                  print(selectedValue.toList());
                                  controller.eProvider.update((val) {
                                    val.addresses = addList;
                                  });
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
                          if (controller.eProvider.value?.addresses == null) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Select Addresses",
                                style: Get.textTheme.caption,
                              ),
                            );
                          } else {
                            return buildAddresses(
                                controller.eProvider.value.addresses);
                          }
                        })
                      ],
                    ),
                  ),

                  //===========================================

                  Container(
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
                                "Taxes",
                                style: Get.textTheme.bodyText1,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                final selectedValue = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MultiSelectDialog(
                                      title: "Select Taxes",
                                      submitText: "Submit".tr,
                                      cancelText: "Cancel".tr,
                                      items: controller.getTaxItems(),
                                      initialSelectedValues: controller.taxes
                                          .where(
                                            (tax) =>
                                                controller.eProvider.value.taxes
                                                    ?.where((element) =>
                                                        element.toString() ==
                                                        tax['id'].toString())
                                                    ?.isNotEmpty ??
                                                false,
                                          )
                                          .toSet(),
                                    );
                                  },
                                );
                                if (selectedValue != null) {
                                  List taxList = [];
                                  selectedValue.forEach((element) {
                                    taxList.add(element["id"]);
                                  });
                                  print(selectedValue.toList());
                                  controller.eProvider.update((val) {
                                    val.taxes = taxList;
                                  });
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
                          if (controller.eProvider.value?.taxes == null) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Select Taxes",
                                style: Get.textTheme.caption,
                              ),
                            );
                          } else {
                            return buildTaxes(controller.eProvider.value.taxes);
                          }
                        })
                      ],
                    ),
                  ),

                  //===========================================

                  TextFieldWidget(
                    onSaved: (input) => controller.eProvider.value
                        .availabilityRange = double.tryParse(input),
                    validator: (input) => input.isEmpty
                        ? "Please Enter Availability Kms".tr
                        : null,
                    initialValue:
                        controller.eProvider.value.availabilityRange != null
                            ? controller.eProvider.value.availabilityRange
                                .toString()
                            : '',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    hintText: "Range within which provider is available",
                    labelText: "Availability Range in Kms",
                  ),

                  //====================================

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
                                  value: controller.eProvider.value.available ??
                                      false,
                                  selected:
                                      controller.eProvider.value.available ??
                                          false,
                                  title: Text("Available"),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  onChanged: (checked) {
                                    controller.eProvider.update((val) {
                                      val.available = checked;
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

                  //===================================

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
                                  value: controller.eProvider.value.featured ??
                                      false,
                                  selected:
                                      controller.eProvider.value.featured ??
                                          false,
                                  title: Text("Featured"),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  onChanged: (checked) {
                                    controller.eProvider.update((val) {
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
              );
          }),
        ),
      ),
    );
  }

  Widget buildProviderType(String typeId) {
    print(typeId);
    var _providerType = controller.eProviderType
        .firstWhere((element) => element['id'] == typeId, orElse: () => Set());

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
            _providerType != null ? _providerType['name'] ?? '' : 'Not Found',
            style: Get.textTheme.bodyText2),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  Widget buildEmployees(List<dynamic> employees) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(employees?.length ?? 0, (index) {
            var employee_id = employees.elementAt(index);
            var _employee = (controller.users.firstWhere(
                (employee) =>
                    (employee["id"]).toString() == (employee_id).toString(),
                orElse: () => null));
            if (_employee != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_employee["name"], style: Get.textTheme.bodyText2),
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

  Widget buildAddresses(List<dynamic> addresses) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(addresses?.length ?? 0, (index) {
            var address_id = addresses.elementAt(index);
            var _address = (controller.addresses.firstWhere(
                (address) =>
                    (address["id"]).toString() == (address_id.toString()),
                orElse: () => null));
            if (_address != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_address["name"], style: Get.textTheme.bodyText2),
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

  Widget buildTaxes(List<dynamic> taxes) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(taxes?.length ?? 0, (index) {
            var tax_id = taxes.elementAt(index);
            var _tax = (controller.taxes.firstWhere(
                (tax) => (tax["id"]).toString() == (tax_id.toString()),
                orElse: () => null));
            if (_tax != null) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(_tax["name"], style: Get.textTheme.bodyText2),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Provider",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("This provider will removed from your account",
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
                controller.deleteProvider();
              },
            ),
          ],
        );
      },
    );
  }
}
