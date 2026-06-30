import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';

class ProfilePageController extends GetxController {
  var name = ''.obs;
  var username = ''.obs;
  var role = ''.obs;
  var schoolid = ''.obs;
  var seassion = ''.obs;

  @override
  void onInit() async {
    // Fetching stored data and setting them in the controller
    name.value = await PrefManager().readValue(key: PrefConst.Name);
    role.value = await PrefManager().readValue(key: PrefConst.RName);
    username.value = await PrefManager().readValue(key: PrefConst.username);
    schoolid.value = (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ?? '';
    seassion.value = await PrefManager().readValue(key: PrefConst.session);

    super.onInit();
  }

  // Method to save roleName to PrefManager
  Future<void> saveRoleName(String roleName) async {
    await PrefManager().writeValue(key: PrefConst.RName, value: roleName);
    role.value = roleName;  // Update the controller with the new value
  }
}
