//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//
//
//   // initializing notification
//   static void initialize(BuildContext context) {
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: AndroidInitializationSettings("@mipmap/ic_launcher"));
//     _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse? notificationResponse) async {
//         print(
//             "onDidReceiveNotificationResponse :==>${notificationResponse.toString()}");
//         if (notificationResponse!.id != null) {
//           // print(
//           //     "onDidReceiveNotificationResponse :==>${notificationResponse.toString()}");
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //     builder: (context) => DemoScreen(
//           //       id: id,
//           //     ),
//           //   ),
//           // );
//         }
//       },
//     );
//   }
//   // method to display notification
//   static void createanddisplaynotification(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//             "eduAgentAppId",
//             "eduAgentAppId",
//             importance: Importance.max,
//             priority: Priority.high,
//             // sound: RawResourceAndroidNotificationSound("alarm")
//         ),
//       );
//       await _notificationsPlugin.show(id, message.notification!.title,
//           message.notification!.body, notificationDetails,
//           payload: message.data['image']);
//       // notificationController.incrementNotification(message: message);
//     } on Exception catch (e) {
//       Logger().e(e);
//     }
//   }
//   // show number of notification on badge
//   // static Widget badgesWidget({required Color color}) {
//   //   return badges.Badge(
//   //       position: badges.BadgePosition.topEnd(top: 4, end: 13),
//   //       badgeStyle: badges.BadgeStyle(
//   //           shape: badges.BadgeShape.circle,
//   //           badgeColor: color,
//   //           padding: EdgeInsets.all(5),
//   //           elevation: 0),
//   //       badgeContent: Obx(() => CustomText(
//   //           data: notificationController.notificationList.length.toString(),
//   //           fontSize: 13.px,
//   //           color: Colors.white)),
//   //       child: Padding(
//   //           padding: EdgeInsets.only(top: 13, right: 20),
//   //           child: GestureDetector(
//   //               onTap: () => {
//   //                 Get.toNamed(RoutesName.notificationPage),
//   //                 print('clicked'),
//   //                 // Get.to(() => NotificationPage()),
//   //               },
//   //               child: Icon(Icons.notifications))));
//   // }
// }

// import 'dart:math';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NotificationServices {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void requestNotificationPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       announcement: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: true,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print("User granted permission");
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print("User granted provisional permission");
//     } else {
//       openAppSettings();
//       print("Permission Denied");
//     }
//   }

//   void initLocalNotifications(
//       BuildContext context, RemoteMessage message) async {
//     var androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//     );
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: (payload) {});
//   }

//   void firebaseInit() {
//     FirebaseMessaging.onMessage.listen((message) {
//       print(message.notification!.title.toString());
//       print(message.notification!.body.toString());
//       print(message.data.toString());
//       showNotification(message);
//     });
//   }

//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       Random.secure().nextInt(100).toString(),
//       'High Importance Notifications',
//       importance: Importance.max,
//     );

//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       channel.id.toString(),
//       channel.name.toString(),
//       channelDescription: 'your channel description',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//     );

//     Future.delayed(Duration.zero, () {
//       _flutterLocalNotificationsPlugin.show(
//           0,
//           message.notification!.title.toString(),
//           message.notification!.body.toString(),
//           notificationDetails);
//     });
//   }

//   Future<String> getDeviceToken() async {
//     String? token = await messaging.getToken();
//     return token!;
//   }

//   void isTokenRefresh() async {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//       print("refresh");
//     });
//   }
// }
