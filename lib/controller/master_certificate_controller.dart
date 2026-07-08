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

// Matched against the "Certification" module's accessible children (see
// accessibleChildNames in home_page_controller.dart).
const List<_TileSpec> _tileSpecs = [
  _TileSpec("DOB Certification", Icons.view_list_rounded, Colors.brown,
      RouteName.dobcertificate, ['DOBCertification']),
  _TileSpec("Transfer Certificate", Icons.add_box_rounded, Color.fromARGB(255, 125, 8, 108),
      RouteName.tc, ['TransferCertificate']),
];

class MastercertificateController extends GetxController {
  final myRepo = LoginRepository();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);

  List<_TileSpec> get _visibleTiles {
    final accessible = accessibleChildNames('Certification');
    return _tileSpecs.where((s) => s.activityNames.any(accessible.contains)).toList();
  }

  List<ProductMasterDashboardItemsModel> get vehicleDocumentList => _visibleTiles
      .map((s) => ProductMasterDashboardItemsModel(s.name, s.icon, s.color))
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
      // FIX 1: 'MM' for month (was 'mm' which is minutes)
      isToday.value =
          DateFormat('dd-MM-yyyy').format(lastDate) ==
              DateFormat('dd-MM-yyyy').format(DateTime.now());

      if (isToday.isTrue) {
        var username = await PrefManager().readValue(key: PrefConst.username);
        var password = await PrefManager().readValue(key: PrefConst.password);

        Map loginData = {
          "userName": username.toString(),
          "password": password.toString(),
          "rememberMe": true
        };

        loginApi(loginData);
      }
    }
  }

  Future<void> loginApi(dynamic data) async {
    myRepo.loginApi(data: data).then((value) async {
      // FIX 2: renamed inner variable to avoid shadowing outer 'data'
      var responseData = Login_Model.fromJson(value);

      if (responseData.data != null) {
        PrefManager().writeValue(
          key: PrefConst.token,
          value: responseData.data!.accessToker!.token.toString(),
        );
      } else if (responseData.statusCode == 400) {
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

class ProductMasterDashboardItemsModel {
  String name;
  IconData icons;
  Color color;

  ProductMasterDashboardItemsModel(this.name, this.icons, this.color);
}