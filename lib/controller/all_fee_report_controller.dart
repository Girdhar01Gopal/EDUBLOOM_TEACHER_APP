import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/session_model.dart' as session_model;
import '../models/fee_type_model.dart';
import '../models/classmodel.dart';
import '../models/all_fee_report_model.dart'; // Import model for fee report data
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';

class AllFeeReportController extends GetxController {
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  final classList = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final isPageLoading = false.obs;
  final rows = <AllFeesReport>[].obs; // List to hold fee report rows

  var schoolId = ''.obs;
  var session = ''.obs;
  String token = '';

@override
void onInit() async {
  super.onInit();
  schoolId.value = (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ?? '';
  session.value = await PrefManager().readValue(key: PrefConst.session) ?? '';
 

  await Future.wait([
    fetchSessions(),
    fetchFeeType(),
    fetchClasses(),
    Fetchfeereport(),
  ]);
  
  // Set default values if null
  selectedClass.value ??= classList.isNotEmpty ? classList.first : null;
  selectedFeeType.value ??= feeTypeList.isNotEmpty ? feeTypeList.first : null;
}

  // Fetching session data
  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse('https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        sessionList.clear();
        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }
      } else {
        Get.snackbar('Error', 'Session API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Session API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  // Fetching fee type data
  Future<void> fetchFeeType() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse('https://playschool.edubloom.in/api/FeeMasterApp/ViewFeeTypeApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = FeeTypeModel.fromJson(jsonDecode(response.body));
        feeTypeList.assignAll(model.listData ?? []);
        selectedFeeType.value ??= (feeTypeList.isNotEmpty ? feeTypeList.first : null);
      } else {
        Get.snackbar('Error', 'FeeType API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'FeeType API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  // Fetching class data
  Future<void> fetchClasses() async {
    try {
      isPageLoading(true);
      final res = await http.get(
        Uri.parse('https://playschool.edubloom.in/api/MasterApp/ViewClass/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        final active = parsed.listData?.where((e) => e.action == "1").toList() ?? [];
        classList.assignAll(active);
        selectedClass.value ??= (classList.isNotEmpty ? classList.first : null);
      } else {
        Get.snackbar('Error', 'Class API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Class API error: $e');
    } finally {
      isPageLoading(false);
    }
  }
// Inside your AllFeeReportController
Future<void> Fetchfeereport() async {
  try {
    isPageLoading(true);

    // Check if selectedClass or selectedFeeType are null
    if (selectedClass.value == null || selectedFeeType.value == null) {
      Get.snackbar('Error', 'Please select both class and fee type before proceeding.');
      return; // Prevent further execution if data is missing
    }

    final res = await http.get(
      Uri.parse(
          'https://playschool.edubloom.in/api/ReportApp/SearchFeetypeClassWiseTuitionandTransportApp/${session.value}/${selectedClass.value?.classId ?? ''}/${selectedFeeType.value?.feeType ?? ''}/${schoolId.value}'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Fee Report API URL: https://playschool.edubloom.in/api/ReportApp/SearchFeetypeClassWiseTuitionandTransportApp/${session.value}/${selectedClass.value?.classId ?? ''}/${selectedFeeType.value?.feeTypeId ?? ''}/${schoolId.value}');

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (jsonData is List) {
        rows.assignAll(jsonData.map((e) => AllFeesReport.fromJson(e)).toList());
      } else if (jsonData is Map && jsonData['listData'] != null) {
        rows.assignAll((jsonData['listData'] as List)
            .map((e) => AllFeesReport.fromJson(e))
            .toList());
      }
    } else {
      Get.snackbar('Error', 'Fee Report API failed: ${res.statusCode}');
    }
  } catch (e) {
    Get.snackbar('Error', 'Fee Report API error: $e');
  } finally {
    isPageLoading(false);
  }
}

  // Set selected session
  void setSelectedSession(session_model.sListDdata? val) => selectedSession.value = val;

  // Set selected fee type
  void setSelectedFeeType(fData? val) => selectedFeeType.value = val;

  // Set selected class
  void setSelectedClass(ListDataa? val) => selectedClass.value = val;


}
