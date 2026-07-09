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
  final Color iconColor;
  final Color bgColor;
  final String route;
  final List<String> activityNames;
  const _TileSpec(this.name, this.icon, this.iconColor, this.bgColor, this.route, this.activityNames);
}

// Matched against the "Master" module's accessible children (see
// accessibleChildNames in home_page_controller.dart). "Transport Fee" and
// "Add Grade" aren't in the sample access tree this was built from — the
// activityNames below are a best guess and should be checked against a
// real account if either tile unexpectedly stays hidden.
const List<_TileSpec> _tileSpecs = [
  _TileSpec("Session", Icons.calendar_today_rounded, Color(0xFF00897B), Color(0xFFE0F2F1),
      RouteName.session_screen, ['Session']),
  _TileSpec("Subject", Icons.menu_book_rounded, Color(0xFF3949AB), Color(0xFFE8EAF6),
      RouteName.subject_screen, ['Subject']),
  _TileSpec("Class", Icons.school_rounded, Color(0xFFF4511E), Color(0xFFFBE9E7),
      RouteName.class_screen, ['Class']),
  _TileSpec("Section", Icons.layers_rounded, Color(0xFF8E24AA), Color(0xFFF3E5F5),
      RouteName.section, ['Section']),
  _TileSpec("Fee Type", Icons.label_rounded, Color(0xFFFFB300), Color(0xFFFFF8E1),
      RouteName.feetypemaster, ['FeeType']),
  _TileSpec("Fee Duration", Icons.hourglass_top_rounded, Color(0xFF00ACC1), Color(0xFFE0F7FA),
      RouteName.feedurationmaster, ['FeeDuration']),
  _TileSpec("Add Route", Icons.alt_route_rounded, Color(0xFF43A047), Color(0xFFE8F5E9),
      RouteName.addroutemaster, ['AddRoute']),
  _TileSpec("Route Point", Icons.place_rounded, Color(0xFFE53935), Color(0xFFFFEBEE),
      RouteName.routepointmaster, ['RoutePoint']),
  _TileSpec("Fee Head Master", Icons.account_balance_rounded, Color(0xFF1E88E5), Color(0xFFE3F2FD),
      RouteName.feeheadmaster, ['AddFee']),
  _TileSpec("Day Care Fee Master", Icons.child_care_rounded, Color(0xFFD81B60), Color(0xFFFCE4EC),
      RouteName.daycarefeemaster, ['DayCareFee']),
  _TileSpec("Payment Master", Icons.account_balance_wallet_rounded, Color(0xFF7CB342), Color(0xFFF1F8E9),
      RouteName.paymentmaster, ['PaymentMode']),
  _TileSpec("Class Subject Assign", Icons.assignment_rounded, Color(0xFF6D4C41), Color(0xFFEFEBE9),
      RouteName.subjectclassassign, ['SubjectAssignClass']),
  _TileSpec("Transport Fee", Icons.directions_bus_rounded, Color(0xFF546E7A), Color(0xFFECEFF1),
      RouteName.transportFee, ['TransportFee']),
  _TileSpec("Add Grade", Icons.menu_book_rounded, Color(0xFFFFB300), Color(0xFFE8EAF6),
      RouteName.grademaster, ['GradeMaster', 'Grade', 'AddGrade']),
];

class Mastercontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  List<_TileSpec> get _visibleTiles {
    final accessible = accessibleChildNames('Master');
    return _tileSpecs.where((s) => s.activityNames.any(accessible.contains)).toList();
  }

  List<DhashboardItemsModel> get vehicleDocumentList => _visibleTiles
      .map((s) => DhashboardItemsModel(s.name, s.icon, s.iconColor, s.bgColor))
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
  IconData icon;      // ← ab IconData use ho raha hai (image ki jagah)
  Color iconColor;    // icon / foreground color
  Color bgColor;      // card background color

  DhashboardItemsModel(this.name, this.icon, this.iconColor, this.bgColor);
}