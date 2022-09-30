import 'package:get/get.dart';
import 'package:home_services_provider/app/models/campaign_model.dart';
import 'package:home_services_provider/common/ui.dart';

import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../providers/laravel_provider.dart';

class NotificationRepository {
  LaravelApiClient _laravelApiClient;

  NotificationRepository() {
    this._laravelApiClient = Get.find<LaravelApiClient>();
  }

  Future<List<Notification>> getAll() {
    return _laravelApiClient.getNotifications();
  }

  Future<int> getCount() {
    return _laravelApiClient.getNotificationsCount();
  }

  Future<Notification> remove(Notification notification) {
    return _laravelApiClient.removeNotification(notification);
  }

  Future<Notification> markAsRead(Notification notification) {
    return _laravelApiClient.markAsReadNotification(notification);
  }

  Future<bool> sendNotification(List<User> users, User from, String type,
      String text, String msg_id, String uId) {
    // _laravelApiClient.sendNotification2(users, from, type, text,msg_id,uId);
    return _laravelApiClient.sendNotification(
        users, from, type, text, msg_id, uId);
  }

  Future<List<Campaign>> getCampigns() {
    return _laravelApiClient.getCampigns();
  }
}
