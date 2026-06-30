import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classwisestudent.dart';
import '../models/daycareaddstudentmodel.dart';
import '../models/totalstudentmodel.dart';
import '../res/app_url.dart';

class Totalstudentcontroller extends GetxController {
  var session = "".obs;
  var schoolid = "".obs;

  RxList<tcData> vehicleDocumentList = List<tcData>.empty().obs;
  var totalDaycareCount = 0.obs;

  @override
  void onInit() async {
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";
    schoolid.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    await totalamount();
    await fetchDaycareCount();
  }

  Future<void> totalamount() async {
    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/StudentApp/GetClassWiseTotalStudentAsynsApp");

      final body = {
        "currentSession": session.value,
        "schoolId": schoolid.value,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        totalclasswisestudent classWiseStudent =
        totalclasswisestudent.fromJson(json);
        vehicleDocumentList.assignAll(classWiseStudent.data ?? []);
      } else {
        Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ERROR fetching student count: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> fetchDaycareCount() async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetAllDaycareStudentsAsyncApp'
            '?schoolId=${schoolid.value}&currentSession=${session.value}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final students = DaycareStudentResponse.fromJson(jsonResponse);
        totalDaycareCount.value = students.data.length;
      }
    } catch (e) {
      print("❌ ERROR fetching daycare count: $e");
    }
  }
}