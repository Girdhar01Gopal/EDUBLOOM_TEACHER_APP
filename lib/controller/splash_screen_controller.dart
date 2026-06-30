import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';


class SplashScreenController extends GetxController {
  
  var waitingTime = 3;

  //NotificationServices notificationServices = NotificationServices();
  @override
  void onInit() {
    // TODO: implement onInit




    nextPage();
    super.onInit();
  }

// void initLocalNotification(BuildContext context, RemoteMessage message)async{
//     var androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
//     var initializationSettings = InitializationSettings(
//       android: androidInitializationSettings
//     );
//    await _notificationsPlugin.initialize(
//       initializationSettings,
// onDidReceiveNotificationResponse: (payload){

// }
//    );

// }
  nextPage() {
    Future.delayed(Duration(seconds: waitingTime), () async {
      var isLogged =
          await PrefManager().readValue(key: PrefConst.isLoggedIn) ?? "";
      var isFirst =
          await PrefManager().readValue(key: PrefConst.isIntroFirst) ?? "";
      if (isLogged == "Yes") {
        Get.offAndToNamed(
          RouteName.dashboard_screen,
        );
      } else {
        Get.offAndToNamed(
          RouteName.login_screen,
        );
      }
    });
  }

  // getting notification token to send push notification
  Future<void> getDeviceTokenToSendNotification() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
    await messaging.getToken().then((value) {
      print('FCM Token :==>\n$value');
      PrefManager()
          .writeValue(key: PrefConst.fcmToken, value: value.toString());
    });
  }

  // firebase init
  // firebaseInit() {
  //   FirebaseMessaging.instance.getInitialMessage().then((message) {
  //     if (message != null) {
  //       if (message.notification!.body!.isNotEmpty) {
  //         print("message notification body is 1 ===${message}");
  //         LocalNotificationService.createanddisplaynotification(message);
  //       }
  //     }
  //   });
  //   // listening firebase Messaging
  //   FirebaseMessaging.onMessage.listen(
  //     (message) {
  //       if (message.notification!.body!.isNotEmpty) {
  //         LocalNotificationService.createanddisplaynotification(message);
  //         print("message notification body is 2 ===${message.notification}");
  //       }
  //     },
  //   );
  //   FirebaseMessaging.onMessageOpenedApp.listen(
  //     (message) {
  //       if (message.notification!.body!.isNotEmpty) {
  //         LocalNotificationService.createanddisplaynotification(message);
  //         print("message notification body is 3 ===${message}");
  //       }
  //     },
  //   );
  // }
}
