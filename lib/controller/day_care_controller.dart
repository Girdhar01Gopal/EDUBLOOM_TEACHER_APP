import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/Daycaremodel.dart';
import '../models/detaildaycaremodel.dart';
import '../res/app_url.dart';

class DayCareController extends GetxController {
  var sessionList = <session_model.sListDdata>[].obs;
  var selectedSession = Rx<session_model.sListDdata?>(null);
  var isLoading = true.obs;
  var session = ''.obs;
  var isloading = false.obs;

  // Changed from ddListData to detailDaycareStudentModel
  var feeDataList = <detailDaycareStudentModel>[].obs;
  var filteredFeeDataList = <detailDaycareStudentModel>[].obs;

  var token = "";
  var schoolId = "";
  var studentList = <ListdData>[].obs;

  @override
  onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    await fetchSessions();
    super.onInit();
  }

  Future<void> refreshData() async {
    if (feeDataList.isEmpty) return; // If there's no data, don't proceed

    // Set loading state
    isloading(true);

    try {
      // Fetch the fee data again
      await fetchDaycareFeeData(
        feeDataList.first.registrationNo ?? '',
        feeDataList.first.studentId ?? '',
      );

      // Reset checkbox states after refresh (if applicable)
      // checkboxStates.assignAll(List<bool>.filled(feeDataList.length, false));
      // selectedRows.clear();

      // Optionally, re-filter fee data based on session or other criteria
      filterFeeDataByRegistrationNo(feeDataList.first.registrationNo ?? '');

    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh data: $e');
    } finally {
      isloading(false); // Stop loading indicator
    }
  }

  Future<void> fetchDaycareStudents() async {
    isloading(true);
    final url = Uri.parse(
        '${AppUrl.base_url}api/DaycareFeePaymentApp/ViewDaycareFeeStudentApp');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "session": session.value,
      "schoolId": schoolId,
    });

    print('Request Body: $body');
    print('Request URL: $url');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        DaycareStudentModel daycareData = DaycareStudentModel.fromJson(data);

        studentList.value = daycareData.listData ?? [];
        print("Fetched ${studentList.length} students.");

        if (studentList.isEmpty) {
          Get.snackbar('No students found',
              'No students were found for the selected session.');
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        print("Response body: ${response.body}");
        Get.snackbar('Error', 'Failed to fetch daycare students');
      }
    } catch (e) {
      print("Error fetching data: $e");
      Get.snackbar('Error', 'Error fetching daycare students: $e');
    } finally {
      isloading(false);
    }
  }

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

        // ✅ poori list daalo (pehle sirf currentSession add ho rahi thi)
        if (jsonData['listData'] != null) {
          final List<dynamic> listRaw = jsonData['listData'];
          sessionList.addAll(
            listRaw.map((e) => session_model.sListDdata.fromJson(e)).toList(),
          );
        }

        if (jsonData['currentSession'] != null) {
          final currentId = jsonData['currentSession']['currentSessionId'];

          // ✅ list mein se match karke select karo (default session)
          session_model.sListDdata? matched;
          for (final s in sessionList) {
            if (s.sessionId == currentId) {
              matched = s;
              break;
            }
          }

          selectedSession.value = matched;
          session.value = matched?.session ?? ''; // Ye line ensure karegi ki session default select ho
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata sessionData) {
    selectedSession.value = sessionData;
    session.value = sessionData.session ?? '';
    print("Selected session: ${session.value}");
  }

  Future<void> fetchDaycareFeeData(var studentid, var registrationno) async {
    isloading(true);
    final url =
    Uri.parse('${AppUrl.base_url}api/FeePayment/GetDaycareShowdata');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'studentId': studentid,
      "session": session.value,
      "schoolId": schoolId,

    });

    print('Request Body: $body');
    print('Request URL: $url');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        final jsonResponse = jsonDecode(response.body);

        // Handle both List and Map responses
        List<dynamic> dataList = [];

        if (jsonResponse is List) {
          dataList = jsonResponse;
        } else if (jsonResponse is Map) {
          // If API returns {data: [...]} format
          if (jsonResponse['data'] != null) {
            dataList = jsonResponse['data'] is List
                ? jsonResponse['data']
                : [jsonResponse['data']];
          }
        }

        // Parse list with error handling
        feeDataList.value = dataList
            .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return detailDaycareStudentModel.fromJson(item);
            }
          } catch (e) {
            print('Error parsing item: $item, Error: $e');
          }
          return null;
        })
            .whereType<detailDaycareStudentModel>()
            .toList();

        if (feeDataList.isEmpty) {
          Get.snackbar('No data', 'No fee data found for this student');
          isloading(false);
          return;
        }

        print("Fetched ${feeDataList.length} fee records.");

        // Filter by registration number
        filterFeeDataByRegistrationNo(registrationno);
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to fetch fee data');
      }
    } catch (e) {
      print("Error fetching data: $e");
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isloading(false);
    }
  }

  void filterFeeDataByRegistrationNo(String registrationNo) {
    filteredFeeDataList.assignAll(
      feeDataList.where(
            (data) => data.registrationNo == registrationNo,
      ),
    );

    if (filteredFeeDataList.isEmpty) {
      Get.snackbar(
        'No data',
        'No records found for registration: $registrationNo',
      );
      return;
    }

    print(
        "Filtered ${filteredFeeDataList.length} records for registration: $registrationNo");

    // Navigate to payment page with filtered data
    Get.toNamed(
      RouteName.pay_day_care,
      arguments: filteredFeeDataList.toList(),
    );
  }

  // Check if payment is fully paid (totalAmount == payAmount)
  bool isFullyPaid(detailDaycareStudentModel data) {
    int totalAmount = _parseInt(data.totalAmount?.toString() ?? '0') ?? 0;
    int payAmount = _parseInt(data.payAmount?.toString() ?? '0') ?? 0;

    // If totalAmount and payAmount both exist and are equal, it's fully paid
    if (totalAmount > 0 && payAmount > 0 && totalAmount == payAmount) {
      return true;
    }

    // Also check paymentStatus as fallback
    final status = data.paymentStatus?.toLowerCase() ?? '';
    return status == 'paid' || status == 'p';
  }

  // Check if row can be selected for payment
  bool isRowSelectable(detailDaycareStudentModel data) {
    // Hide checkbox if fully paid
    if (isFullyPaid(data)) {
      return false;
    }

    // Hide if paidaction is already marked
    if (data.paidaction == "paid") {
      return false;
    }

    // If dueAmount is 0 or null, can't select
    int dueAmount = _parseInt(data.dueAmount?.toString() ?? '0') ?? 0;
    if (dueAmount <= 0) {
      return false;
    }

    return true;
  }

  // Get payment status badge
  String getPaymentStatusBadge(detailDaycareStudentModel data) {
    int totalAmount = _parseInt(data.totalAmount?.toString() ?? '0') ?? 0;
    int payAmount = _parseInt(data.payAmount?.toString() ?? '0') ?? 0;
    int dueAmount = _parseInt(data.dueAmount?.toString() ?? '0') ?? 0;

    // Fully paid
    if (totalAmount > 0 && payAmount > 0 && totalAmount == payAmount) {
      return 'PAID';
    }

    // Partial payment
    if (payAmount > 0 && payAmount < totalAmount) {
      return 'PARTIAL';
    }

    // Pending
    return 'PENDING';
  }

  // Helper method to get total due amount
  double getTotalDueAmount() {
    return filteredFeeDataList.fold<double>(0, (sum, item) {
      int dueAmount = _parseInt(item.dueAmount?.toString() ?? '0') ?? 0;
      return sum + dueAmount.toDouble();
    });
  }

  // Helper method to get total pay amount
  double getTotalPayAmount() {
    return filteredFeeDataList.fold<double>(0, (sum, item) {
      int payAmount = _parseInt(item.payAmount?.toString() ?? '0') ?? 0;
      return sum + payAmount.toDouble();
    });
  }

  // Helper method to get total amount
  double getTotalAmount() {
    return filteredFeeDataList.fold<double>(0, (sum, item) {
      int totalAmount = _parseInt(item.totalAmount?.toString() ?? '0') ?? 0;
      return sum + totalAmount.toDouble();
    });
  }

  // Safe type conversion helper
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  // Clear data when navigating away
  void clearFeeData() {
    feeDataList.clear();
    filteredFeeDataList.clear();
  }

  @override
  void onClose() {
    clearFeeData();
    super.onClose();
  }
}