import 'dart:math';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:home_services_provider/app/models/key_value_model.dart';
import 'package:home_services_provider/app/modules/availabiliity/controllers/availibility_form_controller.dart';
import 'package:home_services_provider/app/modules/e_services/widgets/horizontal_stepper_widget.dart';
import 'package:home_services_provider/app/modules/e_services/widgets/step_widget.dart';
import 'package:home_services_provider/common/ui.dart';
import 'package:html/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_routes.dart';
import '../../global_widgets/multi_select_dialog.dart';
import '../../global_widgets/text_field_widget.dart';

class AvailibilityFormView extends GetView<AvailibilityFormController> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        appBar: AppBar(
          title: Text(
            controller.isCreateForm() ? "Provider Availibilty".tr : '',
            style: context.textTheme.headline6,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
            onPressed: () async {
              Get.back();
            },
          ),
          elevation: 0,
          actions: [
            controller.isCreateForm()
                ? Container()
                : new IconButton(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    icon: new Icon(
                      Icons.h_mobiledata_outlined,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    onPressed: () => {print('clicked')},
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
                    if (!controller.isUpdate.value) {
                      controller.createAvailibility();
                    } else {
                      controller.updateAvailability();
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
                        Text(
                            !controller.isFirstProvider.value
                                ? (!controller.isUpdate.value
                                    ? "Save"
                                    : "Update")
                                : "Next".tr,
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
          key: controller.availableForm,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HorizontalStepperWidget(
                  steps: [
                    StepWidget(
                      title: Text(
                        ("Provider details".tr).substring(
                            0, min("Provider details".tr.length, 15)),
                      ),
                      color: Get.theme.focusColor,
                      index: Text("1",
                          style: TextStyle(color: Get.theme.primaryColor)),
                    ),
                    StepWidget(
                      title: Text(
                        ("Availability".tr)
                            .substring(0, min("Availability".tr.length, 15)),
                      ),
                      index: Text("2",
                          style: TextStyle(color: Get.theme.primaryColor)),
                    ),
                  ],
                ),
                Text("Availability Details".tr, style: Get.textTheme.headline5)
                    .paddingOnly(top: 25, bottom: 0, right: 22, left: 22),
                Text("Please Select Provider Availibility".tr,
                        style: Get.textTheme.caption)
                    .paddingSymmetric(horizontal: 22, vertical: 5),
                Obx(() {
                  if (controller.availibilitySave.value?.length > 0)
                    return Container(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 10, left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 8, right: 8, top: 20, bottom: 20),
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
                        child: Obx(() {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(
                                controller.availibilitySave.value?.length ?? 0,
                                (index) {
                              return Wrap(children: [
                                Container(
                                    color: index % 2 == 0
                                        ? Colors.grey[50]
                                        : Colors.white,
                                    margin: new EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 20,
                                            child: Text(
                                              controller.availibilitySave.values
                                                      .elementAt(index)['day']
                                                      .replaceFirst(
                                                          controller
                                                                  .availibilitySave
                                                                  .values
                                                                  .elementAt(
                                                                      index)[
                                                              'day'][0],
                                                          controller
                                                              .availibilitySave
                                                              .values
                                                              .elementAt(index)[
                                                                  'day'][0]
                                                              .toUpperCase()) +
                                                  ''.tr,
                                              style: Get.textTheme.caption
                                                  .merge(TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 38,
                                            child: Center(
                                                child: Column(
                                              children: [
                                                Text(
                                                  "Starts at",
                                                  style: Get.textTheme.caption,
                                                ),
                                                MaterialButton(
                                                  onPressed: () async {
                                                    if (!controller
                                                        .availibilitySave.values
                                                        .elementAt(
                                                            index)['isHoliday']
                                                        .value) {
                                                      _showDialog(
                                                          CupertinoDatePicker(
                                                        initialDateTime:
                                                            DateTime(2016, 5,
                                                                10, 00, 00),
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .time,
                                                        use24hFormat: false,
                                                        // This is called when the user changes the time.
                                                        onDateTimeChanged:
                                                            (DateTime newTime) {
                                                          var selectedValues =
                                                              '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                                                          print(selectedValues);
                                                          if (selectedValues !=
                                                                  null &&
                                                              !controller
                                                                  .availibilitySave
                                                                  .values
                                                                  .elementAt(index)[
                                                                      'isHoliday']
                                                                  .value) {
                                                            controller.changeTime(
                                                                index,
                                                                selectedValues,
                                                                true);
                                                          }
                                                        },
                                                      ));
                                                    }
                                                  },
                                                  shape: StadiumBorder(),
                                                  color: !controller
                                                          .availibilitySave
                                                          .values
                                                          .elementAt(index)[
                                                              'isHoliday']
                                                          .value
                                                      ? Get.theme.accentColor
                                                          .withOpacity(0.1)
                                                      : Colors.grey[300],
                                                  child: Text(
                                                      new DateFormat.jm().format(DateTime.parse(
                                                          '2022-05-20 ' + controller.availibilitySave.values.elementAt(index)['startsat'].value ??
                                                              '' + ':00'.tr)),
                                                      style: Get
                                                          .textTheme.subtitle1
                                                          .merge(TextStyle(
                                                              fontSize: 11,
                                                              color: controller
                                                                      .availibilitySave
                                                                      .values
                                                                      .elementAt(
                                                                          index)['isHoliday']
                                                                      .value
                                                                  ? Colors.white
                                                                  : Colors.amber[800]))),
                                                  elevation: 0,
                                                  hoverElevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                ),
                                                Text(
                                                  "Ends at",
                                                  style: Get.textTheme.caption,
                                                ),
                                                MaterialButton(
                                                  onPressed: () async {
                                                    if (!controller
                                                        .availibilitySave.values
                                                        .elementAt(
                                                            index)['isHoliday']
                                                        .value) {
                                                      _showDialog(
                                                          CupertinoDatePicker(
                                                        initialDateTime:
                                                            DateTime(2016, 5,
                                                                10, 00, 00),
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .time,
                                                        use24hFormat: false,
                                                        // This is called when the user changes the time.
                                                        onDateTimeChanged:
                                                            (DateTime newTime) {
                                                          var selectedValues =
                                                              '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                                                          print(selectedValues);
                                                          if (selectedValues !=
                                                                  null &&
                                                              !controller
                                                                  .availibilitySave
                                                                  .values
                                                                  .elementAt(index)[
                                                                      'isHoliday']
                                                                  .value) {
                                                            controller.changeTime(
                                                                index,
                                                                selectedValues,
                                                                false);
                                                          }
                                                        },
                                                      ));
                                                    }
                                                  },
                                                  shape: StadiumBorder(),
                                                  color: !controller
                                                          .availibilitySave
                                                          .values
                                                          .elementAt(index)[
                                                              'isHoliday']
                                                          .value
                                                      ? Get.theme.accentColor
                                                          .withOpacity(0.1)
                                                      : Colors.grey[300],
                                                  child: Text(
                                                      new DateFormat.jm()
                                                          .format(DateTime.parse('2022-05-20 ' +
                                                                  controller
                                                                      .availibilitySave
                                                                      .values
                                                                      .elementAt(index)[
                                                                          'endsat']
                                                                      .value ??
                                                              '' + ':00'))
                                                          .tr,
                                                      style: Get
                                                          .textTheme.subtitle1
                                                          .merge(TextStyle(
                                                        fontSize: 11,
                                                        color: controller
                                                                .availibilitySave
                                                                .values
                                                                .elementAt(index)[
                                                                    'isHoliday']
                                                                .value
                                                            ? Colors.white
                                                            : Colors.amber[800],
                                                      ))),
                                                  elevation: 0,
                                                  hoverElevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                ),
                                              ],
                                            )),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Text("or",
                                                style: Get.textTheme.caption
                                                    .merge(TextStyle(
                                                  fontSize: 11,
                                                ))),
                                          ),
                                          Expanded(
                                              flex: 25,
                                              child: Obx(() {
                                                return MaterialButton(
                                                  shape: StadiumBorder(),
                                                  color: !controller
                                                              .availibilitySave
                                                              .values
                                                              .elementAt(index)[
                                                                  'isHoliday']
                                                              .value ??
                                                          true
                                                      ? Colors.grey[600]
                                                      : Colors.blue,
                                                  child: Text(
                                                    "Holiday",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    controller
                                                        .holidayButtonClicked(
                                                            index);
                                                  },
                                                );
                                              }))
                                        ],
                                      ),
                                    ))
                              ]);
                            }),
                          );
                        }));
                  else
                    return SizedBox();
                }),
              ],
            ),
          ),
        ));
  }

  // Widget buildTextHint(data, key) {
  //   return new Padding(
  //     padding: EdgeInsets.symmetric(vertical: 10),
  //     child: Wrap(
  //         alignment: WrapAlignment.start,
  //         spacing: 5,
  //         runSpacing: 8,
  //         children: List.generate(1, (index) {
  //           return Container(
  //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //             child: Text(
  //                 new DateFormat.jm().format(
  //                     DateTime.parse('2022-05-20 ' + data[key] ?? '' + ':00')),
  //                 style: Get.textTheme.bodyText1
  //                     .merge(TextStyle(color: Colors.grey))),
  //             decoration: BoxDecoration(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 border: Border.all(
  //                   color: Colors.grey.withOpacity(0.1),
  //                 ),
  //                 borderRadius: BorderRadius.all(Radius.circular(20))),
  //           );
  //         })),
  //   );
  // }

  Widget buildDays(Map<dynamic, dynamic> availibility) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: List.generate(availibility['days']?.length ?? 0, (index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(availibility['days'][index],
                  style: Get.textTheme.bodyText1
                      .merge(TextStyle(color: Colors.grey))),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            );
          })),
    );
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: Get.context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }
}
