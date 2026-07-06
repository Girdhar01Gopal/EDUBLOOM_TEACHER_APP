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

class Activitymastercontroller extends GetxController {
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
      
    
        
      
        case 0:
        selectedWidget = Get.toNamed(RouteName.galeryvideo);
         break;
         case 1:
        selectedWidget = Get.toNamed(RouteName.mapcategory);
        break;
         case 2:
        selectedWidget = Get.toNamed(RouteName.activity);
        break; /// Added break here
         case 3:
        selectedWidget = Get.toNamed(RouteName.mealactivity);
        break; 
         case 4:
        selectedWidget = Get.toNamed(RouteName.behaviour);
        break;

      // case 5:
      //   selectedWidget = Get.toNamed(RouteName.DailyActivity);
      //   break;
    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      DhashboardItemsModel(
        "Upload Picture",
        CupertinoIcons.cloud_upload_fill,
        const Color(0xFF2196F3), // Blue - upload/cloud action
      ),
      DhashboardItemsModel(
        "View video",
        CupertinoIcons.photo_on_rectangle,
        const Color(0xFF9C27B0), // Purple - media viewing
      ),
      DhashboardItemsModel(
        "Activity",
        CupertinoIcons.sportscourt_fill,
        const Color(0xFF4CAF50), // Green - activity/sports
      ),
      DhashboardItemsModel(
        "Meal Activity",
        CupertinoIcons.flame_fill,
        const Color(0xFFFF5722), // Deep Orange - food/meal
      ),
      DhashboardItemsModel(
        "Behaviour Activity",
        CupertinoIcons.person_crop_circle_badge_checkmark,
        const Color(0xFF00BCD4), // Cyan - behaviour/person
      ),

      // DhashboardItemsModel(
      //   "Daily Activity",
      //   CupertinoIcons.person_crop_circle_badge_checkmark,
      //   const Color(0xFF9C27B0), // Cyan - behaviour/person
      // ),
    ];

    vehicleDocumentList.value = dhashboardItems;
  }

}

class DhashboardItemsModel {
  String name;
  IconData? image;
  Color color;
  DhashboardItemsModel(this.name, this.image, this.color);
}
