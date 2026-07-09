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
import 'home_page_controller.dart';

class _TileSpec {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String route;
  final List<String> activityNames;
  const _TileSpec(this.name, this.icon, this.color, this.bgColor, this.route, this.activityNames);
}

// Matched against the "Student" module's accessible children (see
// accessibleChildNames in home_page_controller.dart).
const List<_TileSpec> _tileSpecs = [
  _TileSpec("Pre School Students", Icons.person_add_alt_1_rounded, Color(0xFF3949AB),
      Color(0xFFE8EAF6), RouteName.student_screen, ['AddStudent', 'ViewStudent']),
  _TileSpec("View Parent ID", Icons.manage_search_rounded, Color(0xFF8E24AA),
      Color(0xFFF3E5F5), RouteName.parentsidscreens, ['ShowParentId']),
  _TileSpec("Take Attendance", Icons.how_to_reg_rounded, Color(0xFF2E7D32),
      Color(0xFFE8F5E9), RouteName.attendance_screen, ['StudentAttendance']),
  _TileSpec("View Attendance", Icons.bar_chart_rounded, Color(0xFF00897B),
      Color(0xFFE0F2F1), RouteName.view_attendance_screen, ['ViewAttendance']),
  _TileSpec("Day Care Students", Icons.child_care_rounded, Color(0xFFD81B60),
      Color(0xFFFCE4EC), RouteName.adddaycarestudent, ['AddDaycareStudent', 'ViewDaycareStudent']),
  _TileSpec("Take Daycare Attendance", Icons.alarm_on_rounded, Color(0xFFF4511E),
      Color(0xFFFBE9E7), RouteName.daycaretakeattendanceview, ['DaycareAttendance']),
  _TileSpec("View Daycare Attendance ", Icons.fact_check_rounded, Color(0xFF00ACC1),
      Color(0xFFE0F7FA), RouteName.viewdaycareattendance, ['ViewDaycareAttendance']),
  _TileSpec("Daycare Attendance Detail", Icons.assignment_turned_in_rounded, Color(0xFF1E88E5),
      Color(0xFFE3F2FD), RouteName.attendancedetailsdaycareview, ['DaycareAttendanceDetail']),
];

class Addstudentcontrollermaster extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  List<_TileSpec> get _visibleTiles {
    final accessible = accessibleChildNames('Student');
    return _tileSpecs.where((s) => s.activityNames.any(accessible.contains)).toList();
  }

  List<DhashboardItemsModel> get vehicleDocumentList => _visibleTiles
      .map((s) => DhashboardItemsModel(s.name, s.icon, s.color, s.bgColor))
      .toList();

  @override
  void onInit() {
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
    final tiles = _visibleTiles;
    if (index < 0 || index >= tiles.length) return;
    selectedWidget = Get.toNamed(tiles[index].route);
  }
}

class DhashboardItemsModel {
  String name;
  IconData image;
  Color color;    // icon color
  Color bgColor;  // circle background color

  DhashboardItemsModel(this.name, this.image, this.color, this.bgColor);
}