import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../models/school_users_all_user_model.dart';

class UserDetailsController extends GetxController {
  RxList<SchoolUser> userList = <SchoolUser>[].obs;
  RxBool isLoading = false.obs;

  var schoolId = "".obs;

  @override
  void onInit() async {
    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      if (schoolId.value.isEmpty) {
        Get.snackbar('Error', 'School ID not found',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final response = await http.get(
        Uri.parse('https://playschool.edubloom.in/api/SchoolApp/SchoolUsersApp/${schoolId.value}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final SchoolUsersModel result =
        SchoolUsersModel.fromJson(jsonDecode(response.body));
        if (result.isSuccess) {
          userList.value = result.data;
        } else {
          Get.snackbar('Error', result.messages,
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void goToUserAccess(int userId) {
    Get.toNamed(RouteName.useraccess, arguments: userId);
  }
}