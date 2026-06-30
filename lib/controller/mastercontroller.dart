import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/login_model.dart';
import '../repo/repo.dart';
import '../view_model/login_view_model.dart';

class Mastercontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);
  RxList<DhashboardItemsModel> vehicleDocumentList =
      List<DhashboardItemsModel>.empty().obs;

  @override
  void onInit() {
    fetchtoken();
    dashboardCategory();
    super.onInit();
  }

  Future<void> fetchtoken() async {
    var expireDate = await PrefManager().readValue(key: PrefConst.expireDate);

    if (expireDate != null) {
      DateTime lastDate = DateTime.parse(expireDate);
      isToday.value = DateFormat('yyyy-MM-dd').format(lastDate) ==
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (isToday.isTrue) {
        var username =
        await PrefManager().readValue(key: PrefConst.username);
        var password =
        await PrefManager().readValue(key: PrefConst.password);
        Map data = {
          "userName": username.toString(),
          "password": password.toString(),
          "rememberMe": true
        };
        loginApi(data);
      }
    }
  }

  Future<void> loginApi(dynamic data) async {
    myRepo.loginApi(data: data).then((value) async {
      var data = Login_Model.fromJson(value);

      if (data.data != null) {
        PrefManager().writeValue(
            key: PrefConst.token,
            value: data.data!.accessToker!.token.toString());
      } else if (data.statusCode == 400) {
        debugPrint("API error");
      }
    }).onError((error, stackTrace) {});
  }

  void onSelectedBottom(int index) {
    selectedIndex = index;
    switch (index) {
      case 0:
        selectedWidget = Get.toNamed(RouteName.session_screen);
        break;
      case 1:
        selectedWidget = Get.toNamed(RouteName.subject_screen);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.class_screen);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.section);
        break;
      case 4:
        selectedWidget = Get.toNamed(RouteName.feetypemaster);
        break;
      case 5:
        selectedWidget = Get.toNamed(RouteName.feedurationmaster);
        break;
      case 6:
        selectedWidget = Get.toNamed(RouteName.addroutemaster);
        break;
      case 7:
        selectedWidget = Get.toNamed(RouteName.routepointmaster);
        break;
      case 8:
        selectedWidget = Get.toNamed(RouteName.feeheadmaster);
        break;
      case 9:
        selectedWidget = Get.toNamed(RouteName.daycarefeemaster);
        break;
      case 10:
        selectedWidget = Get.toNamed(RouteName.paymentmaster);
        break;
      case 11:
        selectedWidget = Get.toNamed(RouteName.subjectclassassign);
        break;
      case 12:
        selectedWidget = Get.toNamed(RouteName.transportFee);
        break;
      case 13:
        selectedWidget = Get.toNamed(RouteName.grademaster);
        break;
    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      // Session — calendar/time feel → teal
      DhashboardItemsModel(
        "Session",
        Icons.calendar_today_rounded,
        const Color(0xFF00897B), // teal 600
        const Color(0xFFE0F2F1), // teal 50
      ),

      // Subject — book/study → indigo
      DhashboardItemsModel(
        "Subject",
        Icons.menu_book_rounded,
        const Color(0xFF3949AB), // indigo 600
        const Color(0xFFE8EAF6), // indigo 50
      ),

      // Class — school building → orange
      DhashboardItemsModel(
        "Class",
        Icons.school_rounded,
        const Color(0xFFF4511E), // deep orange 600
        const Color(0xFFFBE9E7), // deep orange 50
      ),

      // Section — layers/groups → purple
      DhashboardItemsModel(
        "Section",
        Icons.layers_rounded,
        const Color(0xFF8E24AA), // purple 600
        const Color(0xFFF3E5F5), // purple 50
      ),

      // Fee Type — label/tag → amber
      DhashboardItemsModel(
        "Fee Type",
        Icons.label_rounded,
        const Color(0xFFFFB300), // amber 600
        const Color(0xFFFFF8E1), // amber 50
      ),

      // Fee Duration — hourglass/time → cyan
      DhashboardItemsModel(
        "Fee Duration",
        Icons.hourglass_top_rounded,
        const Color(0xFF00ACC1), // cyan 600
        const Color(0xFFE0F7FA), // cyan 50
      ),

      // Add Route — route/map → green
      DhashboardItemsModel(
        "Add Route",
        Icons.alt_route_rounded,
        const Color(0xFF43A047), // green 600
        const Color(0xFFE8F5E9), // green 50
      ),

      // Route Point — pin/location → red
      DhashboardItemsModel(
        "Route Point",
        Icons.place_rounded,
        const Color(0xFFE53935), // red 600
        const Color(0xFFFFEBEE), // red 50
      ),

      // Fee Head Master — account balance → blue
      DhashboardItemsModel(
        "Fee Head Master",
        Icons.account_balance_rounded,
        const Color(0xFF1E88E5), // blue 600
        const Color(0xFFE3F2FD), // blue 50
      ),

      // Day Care Fee — child care → pink
      DhashboardItemsModel(
        "Day Care Fee Master",
        Icons.child_care_rounded,
        const Color(0xFFD81B60), // pink 600
        const Color(0xFFFCE4EC), // pink 50
      ),

      // Payment Master — payments/wallet → light green
      DhashboardItemsModel(
        "Payment Master",
        Icons.account_balance_wallet_rounded,
        const Color(0xFF7CB342), // light green 600
        const Color(0xFFF1F8E9), // light green 50
      ),

      // Class Subject Assign — assignment → brown
      DhashboardItemsModel(
        "Class Subject Assign",
        Icons.assignment_rounded,
        const Color(0xFF6D4C41), // brown 600
        const Color(0xFFEFEBE9), // brown 50
      ),

      // Transport Fee — bus → blue grey
      DhashboardItemsModel(
        "Transport Fee",
        Icons.directions_bus_rounded,
        const Color(0xFF546E7A), // blue grey 600
        const Color(0xFFECEFF1), // blue grey 50
      ),

      DhashboardItemsModel(
        "Add Grade",
        Icons.menu_book_rounded,
        const Color(0xFFFFB300), // indigo 600
        const Color(0xFFE8EAF6), // indigo 50
      ),
    ];


    vehicleDocumentList.value = dhashboardItems;
  }
}

class DhashboardItemsModel {
  String name;
  IconData icon;      // ← ab IconData use ho raha hai (image ki jagah)
  Color iconColor;    // icon / foreground color
  Color bgColor;      // card background color

  DhashboardItemsModel(this.name, this.icon, this.iconColor, this.bgColor);
}