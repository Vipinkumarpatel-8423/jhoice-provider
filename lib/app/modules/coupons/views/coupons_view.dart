import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/coupons/controllers/coupons_controller.dart';
import 'package:home_services_provider/app/routes/app_routes.dart';

import '../../../../common/ui.dart';
import '../../../providers/laravel_provider.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/circular_loading_widget.dart';
import 'package:html/parser.dart';

class CouponsView extends GetView<CouponsController> {
  final bool hideAppBar;

  CouponsView({this.hideAppBar = false});

  //here goes the function
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              title: Text(
                "My Coupons".tr,
                style: context.textTheme.headline6,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: new IconButton(
                icon:
                    new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
                onPressed: () => Get.back(),
              ),
              elevation: 0,
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh List
          await controller.refreshCoupons();
        },
        child: Obx(() {
          print("Render");
          return ListView(
            primary: true,
            children: [
              if (controller.coupons.isEmpty && controller.loading.isTrue)
                CircularLoadingWidget(height: 300)
              else if (controller.coupons.isEmpty && controller.loading.isFalse)
                Ui.dataNotFound(),
              if (controller.coupons.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: Ui.getBoxDecoration(),
                  child: Column(
                    children: List.generate(controller.coupons.length, (index) {
                      var _coupons = controller.coupons.elementAt(index);
                      return ListTile(
                        dense: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.COUPON_FORM,
                                    arguments: _coupons["coupon"]);
                              },
                              child: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        title: Text(_coupons["coupon"]["code"],
                            style: Get.textTheme.bodyText2),
                        subtitle: Text(
                          (!(_coupons["coupon"]["description"] is String)) &&
                                  _coupons["coupon"]["description"]
                                      .containsKey('en')
                              ? _parseHtmlString(
                                  _coupons["coupon"]["description"]["en"])
                              : _parseHtmlString(
                                  _coupons["coupon"]["description"]),
                          style: Get.textTheme.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).paddingSymmetric(vertical: 10);
                    }).toList(),
                  ),
                )
            ],
          );
        }),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add, size: 32, color: Get.theme.primaryColor),
        onPressed: () => {Get.toNamed(Routes.COUPON_FORM)},
        backgroundColor: Get.theme.accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
