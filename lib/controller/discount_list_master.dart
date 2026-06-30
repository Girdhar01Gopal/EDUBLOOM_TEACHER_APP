import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/session_model.dart' as session_model; // ✅ fixed: relative import, only one import of this file

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/FeeDetailsModel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused the type-mismatch errors
import '../res/app_url.dart';

class DiscountListMasterController extends GetxController {
  RxList<FeeDetailsDiscount> discountList = <FeeDetailsDiscount>[].obs;

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type
  var session = ''.obs;

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rxn<ListDatta>();

  var isLoading = false.obs;

  String token = "";
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    await fetchSessions();
    await fetchClasses();
    await fetchSections();
  }

  Future<void> fetchDiscountData() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedSection.value == null) {
      Get.snackbar('Error', 'Please select session, class and section');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/DiscountApp/ViewStudentDiscountApp';

    try {
      isLoading(true);
      discountList.clear();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "schoolId": schoolId,
          "classId": selectedClass.value!.classId,
          "sectionId": selectedSection.value!.sectionId,
          "session": selectedSession.value!.session,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = FeeDetailsDiscountModel.fromJson(decoded);
        discountList.value = model.listData1 ?? [];

        if (discountList.isEmpty) {
          Get.snackbar('Info', 'No data found');
        } else {
          Get.snackbar('Success', 'Data fetched successfully');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSections() async {
    final String url = '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = decoded['listData'] ?? decoded['data'] ?? [];

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      } else {
        Get.snackbar('Error', 'Failed to load sections');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception loading sections: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));

        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];

        selectedClass.value = null;
      } else {
        Get.snackbar('Error', 'Failed to load classes');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching classes: $e');
    } finally {
      isLoading(false);
    }
  }

  // ✅ old session api logic same as before
  Future<void> fetchSessions() async {
    final String apiUrl = '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // Purana sessionList ko clear karte hain
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);

          // Default session ko select kar rahe hain
          selectedSession.value = cs;
          session.value = cs.session ?? ''; // Ye line ensure karegi ki session default select ho
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ListDataa? value) {
    selectedClass.value = value;
  }

  void setSelectedSection(ListDatta? value) {
    selectedSection.value = value;
  }

  void setSelectedSession(session_model.sListDdata? value) { // ✅ fixed type
    selectedSession.value = value;
    session.value = value?.session ?? '';
  }
}