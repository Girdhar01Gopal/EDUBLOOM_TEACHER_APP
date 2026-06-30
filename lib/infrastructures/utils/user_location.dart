// // ignore_for_file: prefer_typing_uninitialized_variables, unnecessary_null_comparison
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';
// import 'package:logger/logger.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pikkar_driver/controller/user_location_controller.dart';
// import 'package:pikkar_driver/infrastructures/utils/utils.dart';
//
// class UserLocation {
//   ReceivePort port = ReceivePort();
//   Stream<ReceivePort>? receivePort;
//   StreamController<ReceivePort> streamController = StreamController();
//   var isDeviceMocked = false.obs;
//   String logStr = '';
//   bool? isRunning;
//
//   Future<bool> getLocationPermission() async {
//     print('location permission');
//     var status =await Permission.location.request().isGranted;
//     print("status ${status}");
//     if (status == true) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//
//   getLatLng() async {
//     var permission = await getLocationPermission();
//     print("permission value  ${permission}");
//
//     if (permission == true) {
//       print("permission value 1  ${permission}");
//       var res = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       if (res.longitude != null) {
//         print("permission value 2  ${res.longitude}");
//         getAddress(lat: res.latitude, lng: res.longitude);
//       }
//     }
//   }
//   getAddress({required double lat, required double lng}) async {
//     List<Placemark> addresses = await placemarkFromCoordinates(lat, lng);
//     var decodedAddress = addresses[0];
//     Get.put(LocationController()).changeCurrentLocation(
//       decodedAddress.street!,
//       decodedAddress.administrativeArea!,
//       decodedAddress.subLocality!,
//       decodedAddress.locality!,
//       decodedAddress.postalCode!,
//       lat,
//       lng,
//     );
//     // getDistanceBetween();
//   }
//
// }
