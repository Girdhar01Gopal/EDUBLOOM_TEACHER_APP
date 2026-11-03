import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/login_model.dart';
import '../repo/repo.dart';
import '../utils/app_snackbar.dart'; // ✅ common top snackbar
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
  _TileSpec("Add & View Staff", Icons.person_add_rounded, Color.fromARGB(255, 143, 243, 30),
      RouteName.addstaff, ['AddStaff', 'ViewStaff']),
  _TileSpec("Staff Type", Icons.badge_rounded, Color.fromARGB(225, 199, 99, 22),
      RouteName.stafftype, ['StaffType']),
  _TileSpec("Staff Attendance", Icons.how_to_reg_rounded, Color.fromARGB(255, 88, 14, 14),
      RouteName.staffattendance, ['StaffAttendance']),
  _TileSpec("View Attendance", Icons.fact_check_rounded, Color.fromARGB(255, 17, 5, 58),
      RouteName.viewstaffattendance, ['ViewAttendance']),
  // _TileSpec("Staff Details", Icons.manage_accounts_rounded, Color.fromARGB(255, 143, 243, 30),
  //     RouteName.staffdetails, ['StaffDetails']),
];

class Staffcontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!, listen: false);
  final RxBool isToday = RxBool(false);

  static final DateFormat _dayFmt = DateFormat('dd-MM-yyyy');

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
    final expireDate = await PrefManager().readValue(key: PrefConst.expireDate);
    if (expireDate == null) return;

    try {
      final lastDate = DateTime.parse(expireDate);
      isToday.value = _dayFmt.format(lastDate) == _dayFmt.format(DateTime.now());
    } catch (e) {
      debugPrint("Expire date parse error: $e");
      return;
    }

    if (isToday.isTrue) {
      final username = await PrefManager().readValue(key: PrefConst.username);
      final password = await PrefManager().readValue(key: PrefConst.password);
      final Map data = {
        "userName": username.toString(),
        "password": password.toString(),
        "rememberMe": true
      };
      await loginApi(data);
    }
  }

  Future<void> loginApi(dynamic data) async {
    try {
      final value = await myRepo.loginApi(data: data);
      final res = Login_Model.fromJson(value);

      if (res.data != null) {
        await PrefManager().writeValue(
            key: PrefConst.token, value: res.data!.accessToker!.token.toString());
      } else if (res.statusCode == 400) {
        debugPrint("API error");
        // ✅ raw API message nahi, sirf friendly line
        AppSnackbar.error(AppSnackbar.friendlyMessage(null, statusCode: 400));
      }
    } catch (e) {
      debugPrint("Login API error: $e");
      AppSnackbar.error(AppSnackbar.friendlyMessage(e));
    }
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