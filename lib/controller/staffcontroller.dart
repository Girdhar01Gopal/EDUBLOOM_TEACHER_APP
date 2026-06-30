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

class Staffcontroller extends GetxController {
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
      isToday.value = DateFormat('dd-mm-yyyy').format(lastDate) == DateFormat('dd-mm-yyyy').format(DateTime.now());
      if(isToday.isTrue){
        var username = await PrefManager().readValue(key: PrefConst.username);
        var password = await PrefManager().readValue(key: PrefConst.password);
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
        PrefManager().writeValue(key: PrefConst.token, value: data.data!.accessToker!.token.toString());
      } else if (data.statusCode == 400) {
        debugPrint("API error");
      }
    }).onError((error, stackTrace) {});
  }

  void onSelectedBottom(int index) {
    selectedIndex = index;
    switch (index) {
      case 0:
        selectedWidget = Get.toNamed(RouteName.addstaff);
        break; // Added break here
      case 1:
        selectedWidget = Get.toNamed(RouteName.stafftype);
        break; // Added break here
      case 2:
        selectedWidget = Get.toNamed(RouteName.staffattendance);
        break; // Added break here
      case 3:
        selectedWidget = Get.toNamed(RouteName.viewstaffattendance);
        break; // Added break here
       case 4:
         selectedWidget = Get.toNamed(RouteName.staffdetails);
        break; // Added break here
      // case 5:
      //   selectedWidget = Get.toNamed(RouteName.classteacher);
      //   break; // Added break here
    //
    }
  }
//
  void dashboardCategory() {
    var dhashboardItems = [
      DhashboardItemsModel("Add & View Staff", Icons.person_add_rounded, const Color.fromARGB(255, 143, 243, 30)),
      DhashboardItemsModel("Staff Type", Icons.badge_rounded, const Color.fromARGB(225, 199, 99, 22)),
      DhashboardItemsModel("Staff Attendance", Icons.how_to_reg_rounded, const Color.fromARGB(255, 88, 14, 14)),
      DhashboardItemsModel("View Attendance", Icons.fact_check_rounded, const Color.fromARGB(255, 17, 5, 58)),
      DhashboardItemsModel("Staff Details", Icons.manage_accounts_rounded, const Color.fromARGB(255, 143, 243, 30)),
    ];
    vehicleDocumentList.value = dhashboardItems;
  }
}

  class DhashboardItemsModel {
    String name;
    IconData icons;
    Color color;
    DhashboardItemsModel(this.name, this.icons, this.color);
  }
