import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/common/ui.dart';

import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/home_controller.dart';
import 'bookings_list_item_widget.dart';

class BookingsListWidget extends GetView<HomeController> {
  BookingsListWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bookings.isEmpty && controller.isLoading.isTrue)
        return CircularLoadingWidget(height: 200);
      else if (controller.bookings.length == 0 && controller.isLoading.isFalse)
        return Ui.dataNotFound();
      else if (controller.bookings.isNotEmpty)
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          primary: false,
          shrinkWrap: true,
          itemCount: controller.bookings.length + 1,
          itemBuilder: ((_, index) {
            if (index == controller.bookings.length) {
              return Obx(() {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Center(
                    child: new Opacity(
                      opacity: controller.isLoading.value ? 1 : 0,
                      child: new CircularProgressIndicator(),
                    ),
                  ),
                );
              });
            } else {
              var _booking = controller.bookings.elementAt(index);
              return BookingsListItemWidget(booking: _booking);
            }
          }),
        );
      else
        return SizedBox();
    });
  }
}
