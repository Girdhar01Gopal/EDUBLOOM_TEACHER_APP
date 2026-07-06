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
//
class Feescontrollermaster extends GetxController {
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
      isToday.value = DateFormat('yyyy-MM-dd').format(lastDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
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
        
    
      
    // Added break here
     
      case 0:
        selectedWidget = Get.toNamed(RouteName.fees_screen);
        break; // Added break here
      case 1:
        selectedWidget = Get.toNamed(RouteName.day_care);
        break; // Added break here
      case 2:
        selectedWidget = Get.toNamed(RouteName.discountfeelist);
        break; // Added break here
   
    }
  }
  void dashboardCategory() {
    var dhashboardItems = [
      DhashboardItemsModel(
        "Fee Payment",
        CupertinoIcons.money_dollar_circle_fill,
        const Color(0xFF6C63FF),
      ),

      DhashboardItemsModel(
        "FeePayment Daycare",
        CupertinoIcons.sun_max_fill,
        const Color(0xFFFF9F43),
      ),

      DhashboardItemsModel(
        "Discount List",
        CupertinoIcons.tag_fill,
        const Color(0xFF9C27B0),
      ),
    ];

    vehicleDocumentList.value = dhashboardItems;
  }

}

class DhashboardItemsModel {
  String name;
  IconData image;
  Color color;
  DhashboardItemsModel(this.name, this.image, this.color);
}
