import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/teacher_detail_model.dart';
import '../res/app_url.dart';

class TeacherDetailController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMsg = ''.obs;
  final teacherDetail = Rxn<TeacherDetailView>();

  int teacherId = 0;
  String schoolId = '';
  String currentSession = '';

  @override
  void onInit() async {
    super.onInit();

    // Arguments passed via Get.toNamed('/teacher-detail', arguments: {...})
    final args = Get.arguments;
    if (args != null && args is Map) {
      teacherId = (args['teacherId'] as int?) ?? 0;
      schoolId = (args['schoolId'] as String?) ?? '';
      currentSession = (args['currentSession'] as String?) ?? '';
    }

    // Fallback: read schoolId from local storage if not passed
    if (schoolId.trim().isEmpty) {
      schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    }

    if (teacherId == 0) {
      hasError(true);
      errorMsg('Invalid Teacher ID');
      isLoading(false);
      return;
    }

    await fetchTeacherDetail();
  }

  Future<void> fetchTeacherDetail() async {
    try {
      isLoading(true);
      hasError(false);
      errorMsg('');

      // API: GET /api/TeacherApp/GetTeacherDetailsApp/{id}?schoolId=...&currentSession=...
      final uri = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetTeacherDetailsApp/$teacherId'
            '?schoolId=$schoolId&currentSession=$currentSession',
      );

      final res = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is Map<String, dynamic>) {
          Map<String, dynamic> data;

          // Case 1: { isSuccess: true, data: { ... } }
          if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
            final isSuccess = decoded['isSuccess'] == true;
            if (!isSuccess) {
              hasError(true);
              errorMsg(decoded['messages']?.toString() ?? 'Failed to load details');
              return;
            }
            data = decoded['data'] as Map<String, dynamic>;
          }
          // Case 2: { isSuccess: true, ...fields directly }
          else if (decoded.containsKey('isSuccess')) {
            if (decoded['isSuccess'] != true) {
              hasError(true);
              errorMsg(decoded['messages']?.toString() ?? 'Failed to load details');
              return;
            }
            data = decoded;
          }
          // Case 3: direct object (no wrapper)
          else {
            data = decoded;
          }

          teacherDetail.value = TeacherDetailView.fromJson(data);
        } else {
          hasError(true);
          errorMsg('Unexpected response format');
        }
      } else {
        hasError(true);
        errorMsg('Server error: ${res.statusCode}');
      }
    } catch (e) {
      hasError(true);
      errorMsg('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Converts relative image path from API to full URL
  String? imageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = AppUrl.base_url.endsWith('/')
        ? AppUrl.base_url.substring(0, AppUrl.base_url.length - 1)
        : AppUrl.base_url;
    final rel = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$rel';
  }
}