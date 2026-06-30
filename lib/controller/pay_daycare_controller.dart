import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/daycaredueandtotal.dart';
import '../models/detaildaycaremodel.dart';
import '../models/paymentmodel.dart';
import '../models/session_model.dart'; // ✅ ADD
import '../res/app_url.dart';
import 'package:http/http.dart' as http;

class PayDayCController extends GetxController {
  final filteredFeeDataList = <detailDaycareStudentModel>[].obs;
  final filteredFeeDataListA = <detailDaycareStudentModel>[].obs;
  final dueandtotal = <duefeesandtotal>[].obs;
  final selectedRows = <detailDaycareStudentModel>[].obs;
  final feeDataList = <detailDaycareStudentModel>[].obs;

  final paymentModes = <PaymentData>[].obs;
  final selectedPaymentMode = ''.obs;

  final session = ''.obs;
  final schoolId = ''.obs;
  var registerationNo = 0.obs;

  // ✅ CHANGE 1: sessionList add karo
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  final bankNameController = TextEditingController();
  final chequeNoController = TextEditingController();
  final chequeDateController = TextEditingController();
  final upiTxnController = TextEditingController();
  final orderNumberController = TextEditingController();
  final onlineRefController = TextEditingController();
  final discountAmountController = TextEditingController();
  final totalPayController = TextEditingController();
  final RxInt totalPay = 0.obs;

  final maxPayable = 0.obs;
  final enteredPay = 0.obs;
  final discountValue = 0.obs;

  bool _updatingText = false;

  @override
  Future<void> onInit() async {
    super.onInit();

    schoolId.value = (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ?? '';

    // ✅ CHANGE 2: hardcoded line hatao, fetchSessionList add karo
    await fetchSessionList();

    await fetchPaymentModes();

    final args = Get.arguments;
    if (args != null) {
      if (args is List<detailDaycareStudentModel>) {
        filteredFeeDataList.assignAll(args);
      } else if (args is detailDaycareStudentModel) {
        filteredFeeDataList.assignAll([args]);
      } else if (args is List) {
        try {
          filteredFeeDataList.assignAll(args.cast<detailDaycareStudentModel>());
        } catch (_) {
          debugPrint("Error casting arguments to detailDaycareStudentModel");
        }
      }
    }

    if (filteredFeeDataList.isNotEmpty) {
      registerationNo.value = filteredFeeDataList.first.studentId ?? 0;
    }
    filteredFeeDataListA.assignAll(filteredFeeDataList);

    discountAmountController.addListener(() {
      if (_updatingText) return;
      recalcMaxAndClampPay(setDefaultToMax: false);
    });

    totalPayController.addListener(() {
      if (_updatingText) return;

      final v = _readInt(totalPayController);
      if (v > maxPayable.value) {
        _setPay(maxPayable.value);
        enteredPay.value = maxPayable.value;
      } else {
        enteredPay.value = v;
      }
    });

    recalcMaxAndClampPay(setDefaultToMax: true);
  }

  // ✅ CHANGE 3: naya method add karo
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}${schoolId.value}",
      );
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final model = SessionModel.fromJson(data);
        final list = model.listData ?? [];

        sessionList.value = list
            .map((s) => s.session ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        final current = model.currentSession?.session?.trim();
        if (current != null && current.isNotEmpty) {
          session.value = current;
        } else if (sessionList.isNotEmpty) {
          session.value = sessionList.first;
        }
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  // ══════════════════════════════════════════
  // BAAKI SAB EXACT SAME — EK LINE NAHI BADI
  // ══════════════════════════════════════════

  Future<void> fetchFees() async {
    try {
      await fetchPaymentModes();
    } catch (_) {}

    filteredFeeDataList.assignAll(filteredFeeDataListA);

    selectedRows.clear();
    discountAmountController.clear();
    totalPayController.clear();
    totalPay.value = 0;

    recalcMaxAndClampPay(setDefaultToMax: true);
  }

  int _readInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  int _baseAmount() {
    final due = getTotalDueAmount();
    final total = getTotalAmount();
    return due != 0 ? due : total;
  }

  void recalcMaxAndClampPay({bool setDefaultToMax = false}) {
    final base = _baseAmount();

    final discTyped = _readInt(discountAmountController);
    final disc = discTyped.clamp(0, base);

    if (disc != discTyped) {
      _setDiscount(disc);
    }

    discountValue.value = disc;

    final payable = base - disc;
    maxPayable.value = payable < 0 ? 0 : payable;

    final currentPayText = totalPayController.text.trim();
    final currentPay = _readInt(totalPayController);

    if (setDefaultToMax && (currentPayText.isEmpty)) {
      _setPay(maxPayable.value);
      enteredPay.value = maxPayable.value;
      return;
    }

    if (currentPay > maxPayable.value) {
      _setPay(maxPayable.value);
      enteredPay.value = maxPayable.value;
    } else {
      enteredPay.value = currentPay;
    }
  }

  void _setPay(int v) {
    _updatingText = true;
    totalPayController.text = v.toString();
    totalPayController.selection =
        TextSelection.collapsed(offset: totalPayController.text.length);
    _updatingText = false;
  }

  void _setDiscount(int v) {
    _updatingText = true;
    discountAmountController.text = v.toString();
    discountAmountController.selection =
        TextSelection.collapsed(offset: discountAmountController.text.length);
    _updatingText = false;
  }

  Future<void> fetchPaymentModes() async {
    final url = Uri.parse(
      '${AppUrl.base_url}api/FeeMasterApp/ViewPaymentModeApp/${schoolId.value}',
    );

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        paymentModes.value = PaymentModel.fromJson(jsonResponse).listData ?? [];
      } else {
        Get.snackbar('Error', 'Failed to load payment modes');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching payment modes: $e');
    }
  }

  bool isPaymentStatusPaid(detailDaycareStudentModel data) {
    final totalAmount = _parseInt(data.totalAmount) ?? 0;
    final paid = _parseInt(data.payAmount) ?? 0;
    final discount = _parseInt(data.discount) ?? 0;

    return (paid + discount) >= totalAmount && totalAmount > 0;
  }

  bool isRowSelectable(detailDaycareStudentModel data) {
    if (isPaymentStatusPaid(data)) return false;
    if (data.paidaction == "paid") return false;
    return true;
  }

  void toggleRowSelection(detailDaycareStudentModel data, bool isSelected) {
    if (isPaymentStatusPaid(data)) {
      Get.snackbar('Warning', 'This payment is already marked as Paid',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return;
    }

    if (!isRowSelectable(data)) {
      Get.snackbar('Warning', 'This row cannot be selected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return;
    }

    // Enforce single-selection: when a row is selected, clear any previous
    // selections and keep only the newly selected row.
    if (isSelected) {
      selectedRows.clear();
      if ((data.fromTime ?? '').isNotEmpty && (data.toTime ?? '').isNotEmpty) {
        final h = calculateHoursFromLoginLogout(data.fromTime!, data.toTime!);
        data.totalHour = _formatHours(h);
      }
      selectedRows.add(data);
    } else {
      selectedRows.remove(data);
    }

    recalcMaxAndClampPay(setDefaultToMax: true);
  }

  int calculateRowTotalPay(detailDaycareStudentModel data) {
    return (_parseInt(data.totalAmount) ?? 0);
  }

  int calculatediscount(detailDaycareStudentModel data) {
    return (data.discount != 0 ? (_parseInt(data.discount) ?? 0) : 0);
  }

  int getTotalDueAmount() {
    return selectedRows.fold(
      0,
      (sum, item) => sum + (_parseInt(item.dueAmount?.toString() ?? '0') ?? 0),
    );
  }

  int getTotalAmount() {
    return selectedRows.fold(
        0, (sum, item) => sum + calculateRowTotalPay(item));
  }

  int getdiscount() {
    return selectedRows.fold(0, (sum, item) => sum + calculatediscount(item));
  }

  double calculateHoursFromLoginLogout(String fromTime, String toTime) {
    try {
      DateTime from = _parseTime(fromTime);
      DateTime to = _parseTime(toTime);

      if (to.isBefore(from)) {
        to = to.add(const Duration(days: 1));
      }

      final difference = to.difference(from);
      return difference.inMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final raw = timeStr.trim();

    final reg =
        RegExp(r'^(\d{1,2})\s*:\s*(\d{2})(?:\s*:\s*(\d{2}))?\s*([aApP][mM])?$');
    final m = reg.firstMatch(raw);

    if (m == null) {
      return DateTime(now.year, now.month, now.day, 0, 0, 0);
    }

    int hh = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ss = m.group(3) == null ? 0 : int.parse(m.group(3)!);
    final ampm = m.group(4)?.toUpperCase();

    if (ampm != null) {
      if (hh == 12) hh = 0;
      if (ampm == "PM") hh += 12;
    }

    hh = hh.clamp(0, 23);

    return DateTime(
      now.year,
      now.month,
      now.day,
      hh,
      mm.clamp(0, 59),
      ss.clamp(0, 59),
    );
  }

  String _formatHours(double hours) {
    final whole = hours.floor();
    final mins = ((hours - whole) * 60).round();
    return "${whole.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}";
  }

  String getCalculatedTotalHours(detailDaycareStudentModel data) {
    if ((data.fromTime ?? '').isNotEmpty && (data.toTime ?? '').isNotEmpty) {
      final hours = calculateHoursFromLoginLogout(data.fromTime!, data.toTime!);
      return _formatHours(hours);
    }
    return data.totalHour ?? '0:00';
  }

  String getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  String now() => DateTime.now().toUtc().toIso8601String();

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> addFees() async {
    final String apiUrl =
        "${AppUrl.base_url}api/DaycareFeePaymentApp/SubmitDaycareFeeInstallsMentApp";

    final String paymentMode = selectedPaymentMode.value.trim().isEmpty
        ? "Cash"
        : selectedPaymentMode.value.trim();
    final String modeUpper = paymentMode.toUpperCase();

    final int totalDiscount = _parseInt(discountAmountController.text) ?? 0;

    final int rowCount = selectedRows.length;
    if (rowCount == 0) {
      Get.snackbar('Error', 'Please select at least one row',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final int payPerRowBase = totalPay.value ~/ rowCount;
    final int payRemainder = totalPay.value % rowCount;

    final int discPerRowBase = totalDiscount ~/ rowCount;
    final int discRemainder = totalDiscount % rowCount;

    List<Map<String, dynamic>> requestBody =
        selectedRows.asMap().entries.map((entry) {
      final idx = entry.key;
      final row = entry.value;

      final int hourlyAmount = calculateRowTotalPay(row);

      final int perRowPayment = payPerRowBase + (idx < payRemainder ? 1 : 0);
      final int perRowDiscount = discPerRowBase + (idx < discRemainder ? 1 : 0);

      int apiDueAmount = getTotalDueAmount();

      final int totalAmount = dueandtotal.isNotEmpty &&
              dueandtotal.first.listData != null &&
              dueandtotal.first.listData!.isNotEmpty
          ? apiDueAmount
          : hourlyAmount;

      final int remainingDue = getTotalDueAmount();

      String calculatedHours = row.totalHour ?? '00:00';
      if ((row.fromTime ?? '').isNotEmpty && (row.toTime ?? '').isNotEmpty) {
        final hours = calculateHoursFromLoginLogout(row.fromTime!, row.toTime!);
        calculatedHours = _formatHours(hours);
      }

      String bankName = "";
      String utrOrChequeNo = "";
      String chequeDate = "";
      String transactionId = "";
      String orderNumber = "";
      String modePaymentOnline = "";

      if (modeUpper == "NEFT" || modeUpper == "RTGS" || modeUpper == "IMPS") {
        bankName = bankNameController.text.trim();
        utrOrChequeNo = chequeNoController.text.trim();
        chequeDate = chequeDateController.text.trim();
      } else if (modeUpper == "UPI") {
        transactionId = upiTxnController.text.trim();
      } else if (modeUpper == "ONLINE" ||
          modeUpper == "CARD" ||
          modeUpper == "NETBANKING") {
        transactionId = upiTxnController.text.trim();
        orderNumber = orderNumberController.text.trim();
        modePaymentOnline = onlineRefController.text.trim();
      }

      return {
        "sadId": row.sadid ?? "",
        "paymentId": 0,
        "studentId": row.studentId ?? "",
        "registrationNo": row.registrationNo ?? "",
        "studentName": row.studentName ?? "",
        "session": (row.session ?? ""),
        "payDate": now(),
        "feetype": row.feeTypeName ?? "daycare",
        "totalAmount": totalAmount,
        "totalHourlyAmount": totalAmount,
        "payAmount": perRowPayment,
        "totalPay": perRowPayment,
        "discount": perRowDiscount,
        "dueAmount": remainingDue,
        "receiptno": "",
        "paymentReceiptNo": "",
        "action": "1",
        "paymentMode": paymentMode,
        "remarks": "Calculated Hours: $calculatedHours",
        "bankName": bankName,
        "chequeNo": utrOrChequeNo,
        "chequeDate": chequeDate,
        "transactionid": transactionId,
        "orderNumber": orderNumber,
        "modePaymentOnline": modePaymentOnline,
        "createDate": now(),
        "createBy": "Admin",
        "schoolId": row.schoolId ?? "",
        "paidAction": "paid",
        "feeMonth": getMonthName(DateTime.now().month),
        "invid": 0,
        "createBy1": ""
      };
    }).toList();

    final headers = {"Content-Type": "application/json"};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("Add Fees API URL: $apiUrl");
      print("Add Fees Request Body: ${jsonEncode(requestBody)}");
      print("Add Fees Response: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
            "Success", "Daycare fee installment submitted successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);

        selectedRows.clear();
        discountAmountController.clear();
        totalPayController.clear();
        totalPay.value = 0;

        Get.offAllNamed(RouteName.dashboard_screen);
      } else {
        print("Error: ${response.body}");
        Get.snackbar(
            "Error", "Failed to submit. Status code: ${response.statusCode}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Exception in addFees: $e");
      Get.snackbar("Error", "An error occurred: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void cancel() => Get.back();

  @override
  void onClose() {
    bankNameController.dispose();
    chequeNoController.dispose();
    chequeDateController.dispose();
    upiTxnController.dispose();
    orderNumberController.dispose();
    onlineRefController.dispose();
    discountAmountController.dispose();
    totalPayController.dispose();
    super.onClose();
  }

  String getSelectedFeeTypeMonth() {
    if (selectedRows.isEmpty) return "--";
    final types = selectedRows
        .map((row) => "${row.feeTypeName ?? ''} (${row.feeMonth1 ?? ''})")
        .toSet()
        .toList();
    return types.join(", ");
  }
}
