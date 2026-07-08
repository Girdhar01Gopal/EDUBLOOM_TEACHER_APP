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
import 'home_page_controller.dart';

class _TileSpec {
  final String name;
  final IconData icon;
  final Color color;
  final String route;
  final List<String> activityNames;
  const _TileSpec(this.name, this.icon, this.color, this.route, this.activityNames);
}

// Matched against the "Staff" module's accessible children (see
// accessibleChildNames in home_page_controller.dart).
const List<_TileSpec> _tileSpecs = [
  _TileSpec("Add Staff & View Staff", Icons.person_add_rounded, Color.fromARGB(255, 143, 243, 30),
      RouteName.addstaff, ['AddStaff', 'ViewStaff']),
  _TileSpec("Staff Type", Icons.badge_rounded, Color.fromARGB(225, 199, 99, 22),
      RouteName.stafftype, ['StaffType']),
  _TileSpec("Staff Attendance", Icons.how_to_reg_rounded, Color.fromARGB(255, 88, 14, 14),
      RouteName.staffattendance, ['StaffAttendance']),
  _TileSpec("View Attendance", Icons.fact_check_rounded, Color.fromARGB(255, 17, 5, 58),
      RouteName.viewstaffattendance, ['ViewAttendance']),
  _TileSpec("Staff Details", Icons.manage_accounts_rounded, Color.fromARGB(255, 143, 243, 30),
      RouteName.staffdetails, ['StaffDetails']),
];

class Staffcontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  List<_TileSpec> get _visibleTiles {
    final accessible = accessibleChildNames('Staff');
    return _tileSpecs.where((s) => s.activityNames.any(accessible.contains)).toList();
  }

  List<DhashboardItemsModel> get vehicleDocumentList =>
      _visibleTiles.map((s) => DhashboardItemsModel(s.name, s.icon, s.color)).toList();

  @override
  void onInit() {
    fetchtoken();
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
    final tiles = _visibleTiles;
    if (index < 0 || index >= tiles.length) return;
    selectedWidget = Get.toNamed(tiles[index].route);
  }
}

  class DhashboardItemsModel {
    String name;
    IconData icons;
    Color color;
    DhashboardItemsModel(this.name, this.icons, this.color);
  }
