import 'dart:ui';
import 'package:flutter/cupertino.dart';
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

class Appdrawercontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  var schoolname = "".obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);
  RxList<DhashboardItemsModel> vehicleDocumentList =
      List<DhashboardItemsModel>.empty().obs;

  List<DhashboardItemsModel> get filteredList =>
      vehicleDocumentList.where((item) => item.name != "Master's" && item.name != "Dashboard").toList();

  @override
  void onInit() async {
    schoolname.value = await PrefManager().readValue(key: PrefConst.Name) ?? "";
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
        selectedWidget = Get.toNamed(RouteName.dashboard_screen);
        break;
      case 1:
        selectedWidget = Get.toNamed(RouteName.master);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.addstudentmaster);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.communicationview);
        break;
      case 4:
        selectedWidget = Get.toNamed(RouteName.activitymaster);
        break;
      case 5:
        selectedWidget = Get.toNamed(RouteName.reports);
        break;

      case 6:
        selectedWidget = Get.toNamed(RouteName.results);
        break;
      case 7:
        selectedWidget = Get.toNamed(RouteName.products);
        break;
      case 8:
        selectedWidget = Get.toNamed(RouteName.masterexpenses);
        break;


      case 9:
        selectedWidget = Get.toNamed(RouteName.mastercertificate);
        break;

    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      // Dashboard — home → teal
      DhashboardItemsModel(
        "Dashboard",
        Icons.dashboard_rounded,
        const Color(0xFF00897B), // teal 600
        const Color(0xFFE0F2F1), // teal 50
      ),

      // Masters's — settings/tune → indigo
      DhashboardItemsModel(
        "Masters's",
        Icons.tune_rounded,
        const Color(0xFF3949AB), // indigo 600
        const Color(0xFFE8EAF6), // indigo 50
      ),

      // Student's — school/students → blue
      DhashboardItemsModel(
        "Student's",
        Icons.groups_rounded,
        const Color(0xFF1E88E5), // blue 600
        const Color(0xFFE3F2FD), // blue 50
      ),

      // Communication's — chat bubble → purple
      DhashboardItemsModel(
        "Communication's",
        Icons.forum_rounded,
        const Color(0xFF8E24AA), // purple 600
        const Color(0xFFF3E5F5), // purple 50
      ),

      // Activity's — paintbrush/art → cyan
      DhashboardItemsModel(
        "Activity's",
        Icons.palette_rounded,
        const Color(0xFF00ACC1), // cyan 600
        const Color(0xFFE0F7FA), // cyan 50
      ),

      // Report's — bar chart → red
      DhashboardItemsModel(
        "Report's",
        Icons.insert_chart_rounded,
        const Color(0xFFE53935), // red 600
        const Color(0xFFFFEBEE), // red 50
      ),


      // Results — star/grade → orange
      DhashboardItemsModel(
        "Results",
        Icons.grade_rounded,
        const Color(0xFFF4511E), // deep orange 600
        const Color(0xFFFBE9E7), // deep orange 50
      ),

      // Products — inventory/box → blue grey
      DhashboardItemsModel(
        "Products",
        Icons.inventory_2_rounded,
        const Color(0xFF546E7A), // blue grey 600
        const Color(0xFFECEFF1), // blue grey 50
      ),

      // Expenses — money off / receipt → pink
      DhashboardItemsModel(
        "Expenses",
        Icons.receipt_long_rounded,
        const Color(0xFFD81B60), // pink 600
        const Color(0xFFFCE4EC), // pink 50
      ),



      DhashboardItemsModel(
        "Certificates",
        Icons.person_pin_rounded,
        const Color(0xFF6D4C41), // brown 600
        const Color(0xFFEFEBE9), // brown 50 // blue grey 50
      ),


    ];

    vehicleDocumentList.value = dhashboardItems;
  }
}

class DhashboardItemsModel {
  String name;
  IconData? image;
  Color color;   // icon color
  Color bgColor; // circle background color

  DhashboardItemsModel(this.name, this.image, this.color, this.bgColor);
}