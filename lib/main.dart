import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/providers/laravel_provider.dart';
import 'app/routes/theme1_app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/firebase_messaging_service.dart';
import 'app/services/global_service.dart';
import 'app/services/settings_service.dart';
import 'app/services/translation_service.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print(message.data['id']);
  if (message.data['id'] == 'App\\Notifications\\NewBooking') {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.bell,
      looping: true, // Android only - API >= 28
      volume: 0.9, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
    final String portName = 'RingTone';
    ReceivePort receiver = ReceivePort();
    IsolateNameServer.registerPortWithName(receiver.sendPort, portName);

    receiver.listen((message) async {
      if (message == "stop") {
        await FlutterRingtonePlayer.stop();
      }
    });
  }
  print('background message1 ${message.data}');
}

void initServices() async {
  Get.log('starting services ...');
  await GetStorage.init();
  await Get.putAsync(() => TranslationService().init());
  await Get.putAsync(() => GlobalService().init());
  await Firebase.initializeApp();
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => FireBaseMessagingService().init());
  await Get.putAsync(() => LaravelApiClient().init());
  await Get.putAsync(() => SettingsService().init());
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  Get.log('All services started...');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(
    GetMaterialApp(
      title: Get.find<SettingsService>().setting.value.appName,
      initialRoute: Theme1AppPages.INITIAL,
      getPages: Theme1AppPages.routes,
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: Get.find<TranslationService>().supportedLocales(),
      translationsKeys: Get.find<TranslationService>().translations,
      locale: Get.find<SettingsService>().getLocale(),
      fallbackLocale: Get.find<TranslationService>().fallbackLocale,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      themeMode: Get.find<SettingsService>().getThemeMode(),
      theme: Get.find<SettingsService>().getLightTheme(),
      //Get.find<SettingsService>().getLightTheme.value,
      darkTheme: Get.find<SettingsService>().getDarkTheme(),
      builder: EasyLoading.init(),
    ),
  );
}
