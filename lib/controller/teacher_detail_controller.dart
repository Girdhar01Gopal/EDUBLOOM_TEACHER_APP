import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/teacher_detail_model.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart';

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
      _fail('Invalid Teacher ID');
      isLoading(false);
      return;
    }

    await fetchTeacherDetail();
  }

  void _fail(String message) {
    hasError(true);
    errorMsg(message);
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

      if (res.statusCode != 200) {
        // Raw "Server error: 500" nahi — friendly line.
        _fail(AppSnackbar.friendlyMessage(null, statusCode: res.statusCode));
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        _fail(AppSnackbar.friendlyMessage(const FormatException()));
        return;
      }

      // Case 1: { isSuccess: true, data: { ... } }
      // Case 2: { isSuccess: true, ...fields directly }
      // Case 3: direct object (no wrapper)
      final hasDataMap = decoded['data'] is Map<String, dynamic>;
      if ((hasDataMap || decoded.containsKey('isSuccess')) &&
          decoded['isSuccess'] != true) {
        // API ka raw message nahi dikhana.
        _fail('Failed to load details. Please try again.');
        return;
      }

      final data = hasDataMap ? decoded['data'] as Map<String, dynamic> : decoded;
      teacherDetail.value = TeacherDetailView.fromJson(data);
    } catch (e) {
      // Raw "Error: $e" nahi — friendly line.
      _fail(AppSnackbar.friendlyMessage(e));
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