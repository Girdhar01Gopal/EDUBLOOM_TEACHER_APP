import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/login_model.dart';
import '../repo/repo.dart';
import '../utils/module_display.dart';
import '../view_model/login_view_model.dart';
import 'home_page_controller.dart';

class Appdrawercontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  var schoolname = "".obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  // Built live from the logged-in user's module access (see
  // DashboardScreenController.accessibleModuleList), so the drawer only
  // ever shows modules the user actually has access to.
  List<DhashboardItemsModel> get vehicleDocumentList =>
      getDashboardController().accessibleModuleList
          .where((module) => !displayMetaFor((module['activityName'] ?? '').toString()).hidden)
          .map((module) {
        final key = (module['activityName'] ?? '').toString();
        final meta = displayMetaFor(key);
        final label = meta.label ?? (module['displayName'] ?? module['activityName'] ?? '').toString();
        return DhashboardItemsModel(label, key, meta.icon, meta.color, meta.bgColor);
      }).toList();

  @override
  void onInit() async {
    schoolname.value = await PrefManager().readValue(key: PrefConst.Name) ?? "";
    fetchtoken();
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
    final items = vehicleDocumentList;
    if (index < 0 || index >= items.length) return;
    final route = displayMetaFor(items[index].moduleKey).route;
    if (route != null) {
      selectedWidget = Get.toNamed(route);
    }
  }
}

class DhashboardItemsModel {
  String name;
  String moduleKey;
  IconData? image;
  Color color; // icon color
  Color bgColor; // circle background color

  DhashboardItemsModel(this.name, this.moduleKey, this.image, this.color, this.bgColor);
}