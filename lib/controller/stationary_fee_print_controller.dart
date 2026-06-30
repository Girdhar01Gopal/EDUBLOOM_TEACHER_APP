import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/StationaryFeePrint_model.dart';

class StationaryFeePrintController extends GetxController {
  // ── args ──────────────────────────────────────────────────
  final RxString receiptNo = ''.obs;
  final RxInt    studentId = 0.obs;   // ← int (API integer field)
  final RxString session   = ''.obs;
  final RxString schoolId  = ''.obs;

  // ── state ─────────────────────────────────────────────────
  final Rx<SchoolDetailModel?>     schoolDetails = Rx(null);
  final RxList<StationaryFeePrint> printItems    = <StationaryFeePrint>[].obs;

  final RxBool isLoadingSchool   = false.obs;
  final RxBool isLoadingPayment  = false.obs;

  bool get isLoading => isLoadingSchool.value || isLoadingPayment.value;

  // ── lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _fetchAll();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is Map) {
      receiptNo.value = '${args['receiptNo'] ?? ''}'.trim();
      // studentId int ya string dono handle karo
      studentId.value = int.tryParse('${args['studentId'] ?? ''}') ?? 0;
      session.value   = '${args['session']   ?? ''}'.trim();
      schoolId.value  = '${args['schoolId']  ?? ''}'.trim();
    }
  }

  void _fetchAll() {
    if (schoolId.value.isNotEmpty) fetchSchoolDetails();

    if (receiptNo.value.isNotEmpty &&
        studentId.value > 0 &&
        session.value.isNotEmpty) {
      fetchPaymentDetails();
    } else {
      Get.snackbar(
        'Error',
        'Receipt No, Student ID ya Session missing hai',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── API 1 : school details ─────────────────────────────────
  Future<void> fetchSchoolDetails() async {
    try {
      isLoadingSchool.value = true;

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/Receipt/GetSchoolDeatils',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'schoolId1': schoolId.value}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          schoolDetails.value = SchoolDetailModel.fromJson(decoded);
        }
      } else {
        Get.snackbar(
          'Error',
          'School details load failed (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'School details error: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSchool.value = false;
    }
  }

  // ── API 2 : payment details ────────────────────────────────
  Future<void> fetchPaymentDetails() async {
    try {
      isLoadingPayment.value = true;
      printItems.clear();

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/Receipt/GetPaymentDetailsStationary',
      );

      final body = {
        'studentId': studentId.value,   // ← int send hoga
        'session':   session.value,
        'receiptNo': receiptNo.value,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model   = StationaryFeePrintResponse.fromJson(decoded);
        printItems.assignAll(model.listData);
      } else {
        Get.snackbar(
          'Error',
          'Payment details load failed (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment details error: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingPayment.value = false;
    }
  }

  // ── computed helpers ───────────────────────────────────────
  String get displayPayDate {
    if (printItems.isEmpty) return '-';
    final raw = printItems.first.payDate.trim();
    if (raw.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String get studentName     => printItems.isEmpty ? '-' : printItems.first.studentName;
  String get fatherName      => printItems.isEmpty ? '-' : printItems.first.fatherName;
  String get academicYear    => printItems.isEmpty ? '-' : printItems.first.session;
  String get paymentMode     => printItems.isEmpty ? '-' : printItems.first.paymentMode;
  String get registrationNum => printItems.isEmpty ? '-' : printItems.first.registrationNo;
  String get receiptNumber   => printItems.isEmpty ? '-' : printItems.first.receiptno;

  String get classSection {
    if (printItems.isEmpty) return '-';
    final cls = printItems.first.className.trim();
    final sec = printItems.first.section.trim();
    if (cls.isNotEmpty && sec.isNotEmpty) return '$cls / $sec';
    if (cls.isNotEmpty) return cls;
    return '-';
  }

  int get totalAmount =>
      printItems.fold(0, (sum, item) => sum + item.amount);
}