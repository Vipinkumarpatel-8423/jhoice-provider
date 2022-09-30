import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

import '../../common/ui.dart';
import '../modules/messages/controllers/messages_controller.dart';
import '../modules/root/controllers/root_controller.dart';
import '../routes/app_routes.dart';
import 'auth_service.dart';

class FireBaseMessagingService extends GetxService {
  Future<FireBaseMessagingService> init() async {
    firebaseCloudMessagingListeners();
    return this;
  }

  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('app open notification');
      print(message.data['id']);
      if(message.data['id']=='App\\Notifications\\NewBooking'){
        FlutterRingtonePlayer.play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.bell,
        looping: true, // Android only - API >= 28
        volume: 0.9, // Android only - API >= 28
        asAlarm: false, // Android only - all APIs
        );
      }
      if (Get.isRegistered<RootController>()) {
        Get.find<RootController>().getNotificationsCount();
      }
      if (message.data['id'] == "App\\Notifications\\NewMessage") {
        _newMessageNotification(message);
      } else {
        _defaultNotification(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      if (Get.isRegistered<RootController>()) {
        Get.find<RootController>().getNotificationsCount();
      }
      if (message.data['id'] == "App\\Notifications\\NewMessage") {
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().changePage(2);
        }
      } else {
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().changePage(0);
        }
      }
    });
  }

  Future<void> setDeviceToken() async {
    Get.find<AuthService>().user.value.deviceToken = await FirebaseMessaging.instance.getToken();
  }

  void _defaultNotification(RemoteMessage message) {
    RemoteNotification notification = message.notification;
    Get.showSnackbar(Ui.notificationSnackBar(
      title: notification.title,
      message: notification.body,
    ));
  }

  void _newMessageNotification(RemoteMessage message) {
    print('happy biriyani');

    RemoteNotification notification = message.notification;
    print(message.data);
    if (Get.find<MessagesController>().initialized) {
      Get.find<MessagesController>().refreshMessages();
    }
    if (Get.currentRoute != Routes.CHAT) {
      Get.showSnackbar(Ui.notificationSnackBar(
        title: notification.title,
        message: notification.body,
      ));
    }
  }
}
