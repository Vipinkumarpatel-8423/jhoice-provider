import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:home_services_provider/app/models/campaign_model.dart';
import 'package:home_services_provider/app/modules/e_providers/controllers/e_providers_form_controller.dart';
import 'package:home_services_provider/app/modules/e_services/controllers/e_service_form_controller.dart';
import 'package:home_services_provider/app/repositories/notification_repository.dart';
import 'package:home_services_provider/app/repositories/user_repository.dart';
import 'package:home_services_provider/app/routes/app_routes.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/ui.dart';
import '../../../models/booking_model.dart';
import '../../../models/booking_status_model.dart';
import '../../../models/statistic.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/statistic_repository.dart';
import '../../../services/global_service.dart';
import '../../../services/auth_service.dart';
import '../../root/controllers/root_controller.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  StatisticRepository _statisticRepository;
  BookingRepository _bookingsRepository;
  NotificationRepository _notificationRepository;
  VideoPlayerController _videoPlayerController;

  final statistics = <Statistic>[].obs;
  final bookings = <Booking>[].obs;
  final bookingStatuses = <BookingStatus>[].obs;
  final page = 0.obs;
  final isLoading = true.obs;
  final isDone = false.obs;
  final currentStatus = '1'.obs;
  final campaign = <Campaign>[].obs;
  var redirectNum = 0;

  ScrollController scrollController;

  HomeController() {
    _statisticRepository = new StatisticRepository();
    _bookingsRepository = new BookingRepository();
    _notificationRepository = new NotificationRepository();
  }

  @override
  Future<void> onInit() async {
    await refreshHome();

    if (Get.find<AuthService>().isAuth) {
      saveToken();
    }
    print('njan vannu');

    super.onInit();
  }

  Future getCampaign() async {
    try {
      campaign.assignAll(await _notificationRepository.getCampigns());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  void showCampaign() async {
    if (_videoPlayerController == null) if (Get.find<AuthService>().isAuth) {
      await getCampaign();
      if (await Get.find<AuthService>().isTodaysFirstLogin()) {
        bool firstLogin = !await Get.find<AuthService>().isFirstLogin();
        var numService =
            statistics.where((val) => val.description == 'total_e_services');
        bool isServiceEmpty = numService.length == 0;
        if (campaign.length > 0) {
          Ui.campaignAds(campaign.elementAt(0), 0, campaign,
              _videoPlayerController, firstLogin, isServiceEmpty);
        }
      }

      // if (await Get.find<AuthService>().isFirstLogin()) {
      //   if (campaign.length > 0) {
      //     Ui.campaignAds(
      //         campaign.elementAt(0), 0, campaign, _videoPlayerController);
      //   } else {
      //     var numService =
      //         statistics.where((val) => val.description == 'total_e_services');
      //     if (numService.length == 0) {
      //       if (int.parse(numService.elementAt(0).value) > 0 &&
      //           campaign.length > 0)
      //         Ui.campaignAds(
      //             campaign.elementAt(0), 0, campaign, _videoPlayerController);
      // }

      Get.find<AuthService>().saveLastLoginTime();
      Get.find<AuthService>().saveFirstLoginCampaign();
    }
  }

  void saveToken() async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('GET', Uri.parse('https://jhoice.com/api/save_token'));
    request.body = json.encode({
      "userId": Get.find<AuthService>().user.value.id,
      "device_token": await FirebaseMessaging.instance.getToken(),
      "table": "provider"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("api call");
      print(await response.stream.bytesToString());
    } else {
      print("api call");
      print(response.reasonPhrase);
    }
  }

  @override
  void onClose() {
    scrollController?.dispose();
  }

  Future refreshHome({bool showMessage = false, String statusId}) async {
    await getBookingStatuses();
    await getStatistics();
    Get.find<RootController>().getNotificationsCount();
    changeTab(statusId);
    if (showMessage) {
      Get.showSnackbar(
          Ui.SuccessSnackBar(message: "Home page refreshed successfully".tr));
    }
    if (redirectNum == 0) redirectToProviderOrService();

    showCampaign();
  }

  void redirectToProviderOrService() {
    redirectNum += 1;
    var numProvider =
        statistics.where((val) => val.description == 'total_e_providers');
    var numService =
        statistics.where((val) => val.description == 'total_e_services');

    bool isEProviderEmpty = numProvider.first.value == '0';
    bool isServiceEmpty = numService.first.value == '0';
    print('njan thanne ${!Get.isRegistered<EServiceFormController>()}');
    if (isEProviderEmpty) {
      if (!Get.isRegistered<EProviderFormController>())
        Get.toNamed(Routes.E_PROVIDER_FORM,
            parameters: {'isFirstProvider': 'true'});
    } else if (isServiceEmpty) {
      if (!Get.isRegistered<EServiceFormController>())
        Get.toNamed(Routes.E_SERVICE_FORM,
            parameters: {'isFirstProvider': 'true'});
    }
    print('Home super');
  }

  void initScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isDone.value) {
        loadBookingsOfStatus(statusId: currentStatus.value);
      }
    });
  }

  void changeTab(String statusId) async {
    isLoading.value = true;
    this.bookings.clear();
    currentStatus.value = statusId ?? currentStatus.value;
    page.value = 0;
    await loadBookingsOfStatus(statusId: currentStatus.value);
    isLoading.value = false;
  }

  Future getStatistics() async {
    try {
      statistics.assignAll(await _statisticRepository.getHomeStatistics());
    } catch (e) {
      print(e);
      //Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getBookingStatuses() async {
    try {
      bookingStatuses.assignAll(await _bookingsRepository.getStatuses());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  BookingStatus getStatusByOrder(int order) =>
      bookingStatuses.firstWhere((s) => s.order == order, orElse: () {
        Get.showSnackbar(
            Ui.ErrorSnackBar(message: "Booking status not found".tr));
        return BookingStatus();
      });

  Future loadBookingsOfStatus({String statusId}) async {
    try {
      isLoading.value = true;
      isDone.value = false;
      page.value++;
      List<Booking> _bookings = [];
      if (bookingStatuses.isNotEmpty) {
        _bookings = await _bookingsRepository.all(statusId, page: page.value);
      }
      if (_bookings.isNotEmpty) {
        bookings.addAll(_bookings);
      } else {
        isDone.value = true;
      }
    } catch (e) {
      isDone.value = true;
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeBookingStatus(
      Booking booking, BookingStatus bookingStatus) async {
    try {
      final _booking = new Booking(id: booking.id, status: bookingStatus);
      await _bookingsRepository.update(_booking);
      bookings.removeWhere((element) => element.id == booking.id);
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future<void> stopAudio() async {
    IsolateNameServer.lookupPortByName('RingTone')?.send("stop");
    await FlutterRingtonePlayer.stop();
  }

  Future<void> acceptBookingService(Booking booking) async {
    stopAudio();
    final _status = Get.find<HomeController>()
        .getStatusByOrder(Get.find<GlobalService>().global.value.accepted);
    await changeBookingStatus(booking, _status);
    Get.showSnackbar(Ui.SuccessSnackBar(
        title: "Status Changed".tr, message: "Booking has been accepted".tr));
  }

  Future<void> declineBookingService(Booking booking) async {
    try {
      stopAudio();
      if (booking.status.order <
          Get.find<GlobalService>().global.value.onTheWay) {
        final _status =
            getStatusByOrder(Get.find<GlobalService>().global.value.failed);
        final _booking =
            new Booking(id: booking.id, cancel: true, status: _status);
        await _bookingsRepository.update(_booking);
        bookings.removeWhere((element) => element.id == booking.id);
        Get.showSnackbar(Ui.defaultSnackBar(
            title: "Status Changed".tr,
            message: "Booking has been declined".tr));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }
}
