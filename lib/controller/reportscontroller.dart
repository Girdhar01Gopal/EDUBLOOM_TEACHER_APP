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

class Reportscontroller extends GetxController {
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
        selectedWidget = Get.toNamed(RouteName.feedailycollection);
        break; // Added break here
      case 1:
        selectedWidget = Get.toNamed(RouteName.DailyCollectionclassWise);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.ClassWiseFee);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.DailyCollectionHeadWise);
        break;
      case 4:
        selectedWidget = Get.toNamed(RouteName.FeeStudentreports);
        break;
      case 5:
        selectedWidget = Get.toNamed(RouteName.feetypereport);
        break;
      case 6:
        selectedWidget = Get.toNamed(RouteName.ViewGirlsBoysReport);
        break;
      case 7:
        selectedWidget = Get.toNamed(RouteName.feePaymentDetailsReports);
        break;
      // case 8:
      //   selectedWidget = Get.toNamed(RouteName.allFeeReportmonths);
      //   break;
      case 8:
        selectedWidget = Get.toNamed(RouteName.studentwiseyearlyreport);
        break;
        // Added break here
    }
  }

  void dashboardCategory() {
    var dhashboardItems = [
      DhashboardItemsModel("All Daily Collection", Icons.payments_rounded, const Color.fromARGB(255, 143, 243, 30)),
      DhashboardItemsModel("Daily Collection Class Wise", Icons.class_rounded, Colors.brown),
      DhashboardItemsModel("Class Wise Fee Structure", Icons.account_balance_rounded, const Color.fromARGB(255, 34, 215, 173)),
      DhashboardItemsModel("Daily Collection Fee Head Wise", Icons.summarize_rounded, const Color.fromARGB(255, 26, 86, 175)),
      DhashboardItemsModel("Student Fees", Icons.school_rounded, const Color.fromARGB(255, 156, 194, 17)),
      DhashboardItemsModel("Fee Type Report", Icons.category_rounded, const Color.fromARGB(255, 125, 8, 108)),
      DhashboardItemsModel("View Girls Boys Report", Icons.people_alt_rounded, const Color.fromARGB(255, 17, 5, 58)),
      DhashboardItemsModel("Fee Payment Detail Reports", Icons.receipt_long_rounded, const Color.fromARGB(255, 88, 14, 14)),
      //DhashboardItemsModel("ALL Payment Months Reports", Icons.calendar_month_rounded, const Color.fromARGB(255, 199, 99, 22)),
      DhashboardItemsModel("Yearly Reports Students", Icons.account_balance_rounded, const Color.fromARGB(255, 156, 194, 17)),

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
