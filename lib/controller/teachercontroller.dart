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

class Teachercontroller extends GetxController {
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
      isToday.value = DateFormat('dd-mm-yyyy').format(lastDate) ==
          DateFormat('dd-mm-yyyy').format(DateTime.now());
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
        selectedWidget = Get.toNamed(RouteName.addteachers);
        break;
      case 1:
        selectedWidget = Get.toNamed(RouteName.teacherdesignation);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.teacherattendance);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.viewteacherattendance);
        break;
      case 4:
        selectedWidget = Get.toNamed(RouteName.teachersubject);
        break;
      case 5:
        selectedWidget = Get.toNamed(RouteName.classteacher);
        break;
    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      // Add & View Teacher — person add → indigo
      DhashboardItemsModel(
        "Add & View Teacher",
        Icons.person_add_alt_1_rounded,
        const Color(0xFF3949AB), // indigo 600
        const Color(0xFFE8EAF6), // indigo 50
      ),

      // Teacher Designation — badge/id → purple
      DhashboardItemsModel(
        "Teacher Designation",
        Icons.badge_rounded,
        const Color(0xFF8E24AA), // purple 600
        const Color(0xFFF3E5F5), // purple 50
      ),

      // Teacher Attendance — how to reg → green
      DhashboardItemsModel(
        "Teacher Attendance",
        Icons.how_to_reg_rounded,
        const Color(0xFF2E7D32), // green 800
        const Color(0xFFE8F5E9), // green 50
      ),

      // View Attendance — bar chart → teal
      DhashboardItemsModel(
        "View Attendance",
        Icons.bar_chart_rounded,
        const Color(0xFF00897B), // teal 600
        const Color(0xFFE0F2F1), // teal 50
      ),

      // Assign Subject — assignment → orange
      DhashboardItemsModel(
        "Assign Subject",
        Icons.assignment_rounded,
        const Color(0xFFF4511E), // deep orange 600
        const Color(0xFFFBE9E7), // deep orange 50
      ),

      // Class Teacher — school → blue
      DhashboardItemsModel(
        "Class Teacher",
        Icons.school_rounded,
        const Color(0xFF1E88E5), // blue 600
        const Color(0xFFE3F2FD), // blue 50
      ),
    ];

    vehicleDocumentList.value = dhashboardItems;
  }
}

class DhashboardItemsModel {
  String name;
  IconData icons;
  Color color;   // icon color
  Color bgColor; // circle background color

  DhashboardItemsModel(this.name, this.icons, this.color, this.bgColor);
}