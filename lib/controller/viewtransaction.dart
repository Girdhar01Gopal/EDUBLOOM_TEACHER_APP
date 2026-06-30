import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/viewfeesmodel.dart'; // ✅ FIXED: same model jo view use kar raha hai
import '../res/app_url.dart';

class Viewtransactioncontroller extends GetxController {
  var transactionItems = <fListData>[].obs;

  int studentId = 0;
  String session = '';
  String schoolId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final registrationNo = args['registrationNo'] ?? '';
      session = args['session'] ?? '';
      schoolId = args['schoolId'] ?? '';
      final classid = args['classId'] ?? 0;
      final sectionId = args['sectionId'] ?? 0;
      studentId = args['studentId'] ?? 0;

      print(
          "Arguments received: registrationNo=$registrationNo, session=$session, schoolId=$schoolId, classid=$classid, sectionId=$sectionId, studentId=$studentId");

      fetchTransactionDetails(
          registrationNo.toString(), session, schoolId, studentId);
    }
  }

  Future<void> fetchTransactionDetails(
      String registrationNo, String session, String schoolId, int studentid) async {
    final url = Uri.parse(
        "${AppUrl.base_url}api/FeePaymentApp/GetPaymentDetailsnewtableApp");

    final body = jsonEncode({
      "studentId": studentid,
      "registrationNo": registrationNo,
      "session": session,
      "schoolId": schoolId
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("Request URL: $url");
      print("Request Body: $body");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey("listData")) {
          final list = jsonResponse["listData"] as List;
          transactionItems.assignAll(
            list.map<fListData>((e) => fListData.fromJson(e)).toList(),
          );
        } else {
          Get.snackbar("Error", "Invalid data format: listData not found");
        }
      } else {
        Get.snackbar("Error", "Failed to load transaction details");
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "An error occurred while fetching data");
    }
  }
}