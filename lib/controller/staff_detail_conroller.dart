import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/staff_detail_model.dart';
import '../res/app_url.dart';

class StaffDetailController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMsg = ''.obs;
  final staffDetail = Rxn<StaffDetailModel>();

  int staffId = 0;
  String schoolId = '';
  String currentSession = '';

  @override
  void onInit() async {
    super.onInit();

    // Arguments passed via Get.toNamed(RouteName.staffdetailview, arguments: {...})
    final args = Get.arguments;
    if (args != null && args is Map) {
      staffId = (args['staffId'] as int?) ?? 0;
      schoolId = (args['schoolId'] as String?) ?? '';
      currentSession = (args['currentSession'] as String?) ?? '';
    }

    // Fallback: read schoolId from local storage if not passed
    if (schoolId.trim().isEmpty) {
      schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    }

    if (staffId == 0) {
      hasError(true);
      errorMsg('Invalid Staff ID');
      isLoading(false);
      return;
    }

    await fetchStaffDetail();
  }

  Future<void> fetchStaffDetail() async {
    try {
      isLoading(true);
      hasError(false);
      errorMsg('');


      final uri = Uri.parse(
        '${AppUrl.base_url}api/StaffApp/GetStaffDetailsApp',
      );

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'schoolId': schoolId,
          'staffId': staffId,
          'currentSession': currentSession,
        }),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is Map<String, dynamic>) {
          final isSuccess = decoded['isSuccess'] == true;

          if (!isSuccess) {
            hasError(true);
            errorMsg(decoded['messages']?.toString() ?? 'Failed to load details');
            return;
          }

          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            staffDetail.value = StaffDetailModel.fromJson(data);
          } else {
            hasError(true);
            errorMsg('No data found in response');
          }
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

  String formatDate(DateTime? dt) {
    if (dt == null) return '-';
    const mm = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day.toString().padLeft(2, '0')}-${mm[dt.month - 1]}-${dt.year}';
  }
}