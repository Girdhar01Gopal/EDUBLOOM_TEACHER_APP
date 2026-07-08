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
  final String route;
  // Which top-level module this tile's access lives under — this screen
  // mixes tiles from two different modules (Gallery, DailyActivity).
  final String parentActivityName;
  final List<String> activityNames;
  const _TileSpec(this.name, this.icon, this.color, this.route, this.parentActivityName, this.activityNames);
}

const List<_TileSpec> _tileSpecs = [
  _TileSpec("Upload Picture", CupertinoIcons.cloud_upload_fill, Color(0xFF2196F3),
      RouteName.galeryvideo, 'Gallery', ['UploadPicture']),
  _TileSpec("View video", CupertinoIcons.photo_on_rectangle, Color(0xFF9C27B0),
      RouteName.mapcategory, 'Gallery', ['Video', 'Viewvideo']),
  _TileSpec("Activity", CupertinoIcons.sportscourt_fill, Color(0xFF4CAF50),
      RouteName.activity, 'DailyActivity', ['Activity']),
  _TileSpec("Meal Activity", CupertinoIcons.flame_fill, Color(0xFFFF5722),
      RouteName.mealactivity, 'DailyActivity', ['Meal']),
  _TileSpec("Behaviour Activity", CupertinoIcons.person_crop_circle_badge_checkmark, Color(0xFF00BCD4),
      RouteName.behaviour, 'DailyActivity', ['Behaviour']),
];

class Activitymastercontroller extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  List<_TileSpec> get _visibleTiles {
    final accessibleByParent = <String, Set<String>>{};
    return _tileSpecs.where((s) {
      final accessible = accessibleByParent.putIfAbsent(
          s.parentActivityName, () => accessibleChildNames(s.parentActivityName));
      return s.activityNames.any(accessible.contains);
    }).toList();
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
    final tiles = _visibleTiles;
    if (index < 0 || index >= tiles.length) return;
    selectedWidget = Get.toNamed(tiles[index].route);
  }
}

class DhashboardItemsModel {
  String name;
  IconData? image;
  Color color;
  DhashboardItemsModel(this.name, this.image, this.color);
}
