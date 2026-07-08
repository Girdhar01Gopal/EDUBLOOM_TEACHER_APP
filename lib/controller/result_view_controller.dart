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

class _ResultChildMeta {
  final IconData icon;
  final Color color;
  final String route;
  const _ResultChildMeta(this.icon, this.color, this.route);
}

// Icon/color/route for each child of the "Result" module, keyed by the
// API's activityName so tiles stay in sync with per-user access.
const Map<String, _ResultChildMeta> _resultChildMeta = {
  'FoundationalSkills': _ResultChildMeta(
      Icons.school_rounded, Color.fromARGB(255, 143, 243, 30), RouteName.foundationalskills),
  'SubjectProgress': _ResultChildMeta(
      Icons.description_rounded, Colors.brown, RouteName.descriptors),
  'MapDescriptors': _ResultChildMeta(
      Icons.map_rounded, Color.fromARGB(255, 34, 215, 173), RouteName.mapdescriptor),
  'MapFoundationalSkills': _ResultChildMeta(
      Icons.account_tree_rounded, Color.fromARGB(255, 26, 86, 175), RouteName.mapfoundationaldescriptioskills),
  'AddTerm': _ResultChildMeta(
      Icons.calendar_month_rounded, Color.fromARGB(255, 156, 194, 17), RouteName.termsresult),
  'AddResult': _ResultChildMeta(
      Icons.fact_check_rounded, Color.fromARGB(255, 34, 197, 94), RouteName.Resultadd),
  'PrintRePortCard': _ResultChildMeta(
      Icons.school_rounded, Color.fromARGB(255, 59, 130, 246), RouteName.ResultReportcard),
};

class ResultViewController extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  // Only the children of the "Result" module the current user has access
  // to (DashboardScreenController.accessibleModuleList already trims each
  // parent's childActivity down to access:true entries).
  List<DhashboardItemsModel> get vehicleDocumentList {
    final resultModule = getDashboardController()
        .accessibleModuleList
        .where((m) => m['activityName'] == 'Result')
        .toList();
    final children = resultModule.isEmpty
        ? <dynamic>[]
        : (resultModule.first['childActivity'] as List? ?? []);
    return children.map((raw) {
      final child = Map<String, dynamic>.from(raw as Map);
      final key = (child['activityName'] ?? '').toString();
      final meta = _resultChildMeta[key];
      final label = (child['displayName'] ?? child['activityName'] ?? '').toString().trim();
      return DhashboardItemsModel(
        label,
        key,
        meta?.icon ?? Icons.apps_rounded,
        meta?.color ?? Colors.blueGrey,
      );
    }).toList();
  }

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
    final items = vehicleDocumentList;
    if (index < 0 || index >= items.length) return;
    final route = _resultChildMeta[items[index].moduleKey]?.route;
    if (route != null) {
      selectedWidget = Get.toNamed(route);
    }
  }
}

class DhashboardItemsModel {
  String name;
  String moduleKey;
  IconData icons;
  Color color;
  DhashboardItemsModel(this.name, this.moduleKey, this.icons, this.color);
}
