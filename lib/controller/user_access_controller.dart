import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../models/user_access_model.dart';
import '../models/user_access_updated_model.dart';

class UserAccessPermission {
  final String name;
  final int activityId;
  final int schoolAccessId;
  final int? recordId;
  bool isChecked;

  UserAccessPermission({
    required this.name,
    required this.activityId,
    required this.schoolAccessId,
    this.recordId,
    this.isChecked = false,
  });
}

class UserAccessModule {
  final String moduleName;
  final int activityId;
  final List<UserAccessPermission> permissions;

  UserAccessModule({
    required this.moduleName,
    required this.activityId,
    required this.permissions,
  });
}

class UserAccessController extends GetxController {
  RxList<UserAccessModule> modules = <UserAccessModule>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  var staffTypeName = ''.obs;
  int userId = 0;
  String schoolId = '';

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments ?? 0;
    _init();
  }

  Future<void> _init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    await fetchUserAccess();
  }

  Future<void> fetchUserAccess() async {
    if (userId == 0 || schoolId.isEmpty) {
      Get.snackbar('Error', 'Missing userId or schoolId',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      final uri = Uri.parse(
        'https://playschool.edubloom.in/api/SchoolApp/GetUserAccessApp'
            '?userId=$userId&schoolId=$schoolId',
      );
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawList;
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          rawList = decoded['data'] as List<dynamic>;
          if (decoded['staffTypeName'] != null) {
            staffTypeName.value = decoded['staffTypeName'].toString();
          }
        } else {
          rawList = [];
        }
        _mapToUIModules(userAccessModelListFromJson(rawList));
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

  void _mapToUIModules(List<UserAccessModel> apiModels) {
    final List<UserAccessModule> result = [];
    for (final parent in apiModels) {
      if (!parent.isActive || parent.isDelete) continue;

      if (parent.childActivity != null && parent.childActivity!.isNotEmpty) {
        final perms = parent.childActivity!
            .where((c) => c.isActive && !c.isDelete)
            .map((c) => UserAccessPermission(
          name: c.displayName,
          activityId: c.activityId,
          schoolAccessId: c.schoolAccessId,
          recordId: c.id,
          isChecked: c.access,
        ))
            .toList();
        if (perms.isNotEmpty) {
          result.add(UserAccessModule(
            moduleName: parent.displayName,
            activityId: parent.activityId,
            permissions: perms,
          ));
        }
      } else {
        result.add(UserAccessModule(
          moduleName: parent.displayName,
          activityId: parent.activityId,
          permissions: [
            UserAccessPermission(
              name: parent.displayName,
              activityId: parent.activityId,
              schoolAccessId: parent.schoolAccessId,
              recordId: parent.id,
              isChecked: parent.access,
            ),
          ],
        ));
      }
    }
    modules.value = result;
  }

  void toggleModule(int moduleIndex, bool value) {
    for (var perm in modules[moduleIndex].permissions) {
      perm.isChecked = value;
    }
    modules.refresh();
  }

  void togglePermission(int moduleIndex, int permIndex, bool value) {
    modules[moduleIndex].permissions[permIndex].isChecked = value;
    modules.refresh();
  }

  /// Refresh: reload data from server
  Future<void> refreshAccess() async {
    await fetchUserAccess();
    Get.snackbar('Refreshed', 'Access data reloaded!',
        backgroundColor: const Color(0xFF1A2847),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveAccess() async {
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      // Save each permission one by one using the new API:
      // POST /api/SchoolApp/School/{schoolId}/User/{userId}/Access
      final uri = Uri.parse(
        'https://playschool.edubloom.in/api/SchoolApp/School/$schoolId/User/$userId/Access',
      );

      bool allSuccess = true;
      String? errorMessage;

      for (final module in modules) {
        for (final perm in module.permissions) {
          final body = {
            'id': perm.recordId,
            'activityId': perm.activityId,
            'activityName': perm.name,
            'displayName': perm.name,
            'isActive': perm.isChecked,
            'parentActivityId': module.activityId,
            'displayOnMenuFlag': perm.isChecked,
            'sequence': 1,
            'createBy': 'admin',
          };

          final response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final bool success =
            decoded is Map ? (decoded['isSuccess'] ?? true) as bool : true;
            if (!success) {
              allSuccess = false;
              errorMessage =
                  decoded['messages']?.toString() ?? 'Save failed for ${perm.name}';
              break;
            }
          } else {
            allSuccess = false;
            errorMessage = 'Server error: ${response.statusCode}';
            break;
          }
        }
        if (!allSuccess) break;
      }

      if (allSuccess) {
        Get.snackbar('Saved ✅', 'Access permissions updated!',
            backgroundColor: const Color(0xFF00897B),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        // Refresh screen data immediately after save
        await fetchUserAccess();
      } else {
        Get.snackbar('Error', errorMessage ?? 'Save failed',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Save failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}