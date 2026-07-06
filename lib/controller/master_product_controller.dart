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

class ProductMasterViewController extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  RxList<ProductMasterDashboardItemsModel> vehicleDocumentList =
      List<ProductMasterDashboardItemsModel>.empty().obs;

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
      isToday.value =
          DateFormat('dd-mm-yyyy').format(lastDate) ==
              DateFormat('dd-mm-yyyy').format(DateTime.now());

      if (isToday.isTrue) {
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
        PrefManager().writeValue(
          key: PrefConst.token,
          value: data.data!.accessToker!.token.toString(),
        );
      } else if (data.statusCode == 400) {
        debugPrint("API error");
      }
    }).onError((error, stackTrace) {});
  }

  void onSelectedBottom(int index) {
    selectedIndex = index;
    switch (index) {
      case 0:
        selectedWidget = Get.toNamed(RouteName.addproducts);
        break;
      case 1:
        selectedWidget = Get.toNamed(RouteName.productquantity);
        break;
      case 2:
        selectedWidget = Get.toNamed(RouteName.stationaryfee);
        break;
      case 3:
        selectedWidget = Get.toNamed(RouteName.stationaryinventory);
        break;
    }
  }

  void dashboardCategory() {
    var dashboardItems = [
      ProductMasterDashboardItemsModel(
        "Add Product",
        Icons.add_box_rounded,
        const Color.fromARGB(255, 143, 243, 30),
      ),
      ProductMasterDashboardItemsModel(
        "Product Quantity",
        Icons.view_list_rounded,
        Colors.brown,
      ),
      //Color.fromARGB(255, 125, 8, 108))
      //Color.fromARGB(255, 26, 86, 175))
      ProductMasterDashboardItemsModel(
        "Stationary Fee",
        Icons.add_box_rounded,
        const Color.fromARGB(255,  125, 8, 108),

      ),
      ProductMasterDashboardItemsModel(
        "Stationary Inventory",
        Icons.view_list_rounded,
        const Color.fromARGB(255,  26, 86, 175),
      ),
    ];

    vehicleDocumentList.value = dashboardItems;
  }
}

class ProductMasterDashboardItemsModel {
  String name;
  IconData icons;
  Color color;

  ProductMasterDashboardItemsModel(this.name, this.icons, this.color);
}