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

class ResultViewController extends GetxController {
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
        selectedWidget = Get.toNamed(RouteName.foundationalskills);
        break; // Added break here
      case 1:
        selectedWidget = Get.toNamed(RouteName.descriptors);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.mapdescriptor);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.mapfoundationaldescriptioskills);
        break;
      case 4:
        selectedWidget = Get.toNamed(RouteName.termsresult);
        break;
       case 5:
         selectedWidget = Get.toNamed(RouteName.Resultadd);
         break;
       case 6:
         selectedWidget = Get.toNamed(RouteName.ResultReportcard);
         break;
    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      DhashboardItemsModel("FoundationalSkills", Icons.school_rounded, const Color.fromARGB(255, 143, 243, 30)),
      DhashboardItemsModel("Descriptors", Icons.description_rounded, Colors.brown),
      DhashboardItemsModel("MapDescriptors", Icons.map_rounded, const Color.fromARGB(255, 34, 215, 173)),
      DhashboardItemsModel("Map Foundational Skills", Icons.account_tree_rounded, const Color.fromARGB(255, 26, 86, 175)),
      DhashboardItemsModel("Add Term", Icons.calendar_month_rounded, const Color.fromARGB(255, 156, 194, 17)),
      DhashboardItemsModel(
        "Add Result",
        Icons.fact_check_rounded,
        const Color.fromARGB(255, 34, 197, 94), // fresh green
      ),

      DhashboardItemsModel(
        "RePortCard",
        Icons.school_rounded,
        const Color.fromARGB(255, 59, 130, 246), // clean academic blue
      ),
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
