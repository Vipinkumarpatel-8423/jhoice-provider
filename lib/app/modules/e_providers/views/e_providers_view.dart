import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/modules/coupons/controllers/coupons_controller.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_controller.dart';
import 'package:home_services_provider/app/routes/app_routes.dart';

import '../../../../common/ui.dart';
import '../../../providers/laravel_provider.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/circular_loading_widget.dart';
import 'package:html/parser.dart';

class EProvidersView extends GetView<EProvidersController> {
  final bool hideAppBar;

  EProvidersView({this.hideAppBar = false});

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
                "My Providers".tr,
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
          await controller.refreshEProviders();
        },
        child: Obx(() {
          return ListView(
            primary: true,
            children: [
              if (controller.eProviders.isEmpty && controller.loading.isTrue)
                CircularLoadingWidget(height: 300),
              if (controller.eProviders.isEmpty && controller.loading.isFalse)
                Ui.dataNotFound()
              else if (controller.eProviders.isNotEmpty &&
                  controller.loading.isFalse)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: Ui.getBoxDecoration(),
                  child: Column(
                    children:
                        List.generate(controller.eProviders.length, (index) {
                      var _coupons = controller.eProviders.elementAt(index);
                      return ListTile(
                        dense: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.E_PROVIDER_FORM,
                                    arguments: controller.eProviders[index]);
                              },
                              child: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        title: Text(controller.eProviders[index].name,
                            style: Get.textTheme.bodyText2),
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
        onPressed: () => {Get.toNamed(Routes.E_PROVIDER_FORM)},
        backgroundColor: Get.theme.accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
