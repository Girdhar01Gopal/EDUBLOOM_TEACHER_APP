import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../infrastructures/routes/page_constants.dart';
import '../models/paymentmodel.dart';
import '../models/stationary_action1.dart';
import '../models/stationary_action2_.dart';
import '../models/stationary_action3_.dart';
import '../models/stationary_student_fee_list.dart';
import '../res/app_url.dart';

class StationaryItem {
  final int id;
  final String stationaryName;
  final int totalQuantity;
  final int pmasterId;
  final TextEditingController quantityController;
  final TextEditingController payAmountController;

  StationaryItem({
    required this.id,
    required this.stationaryName,
    required this.totalQuantity,
    required this.pmasterId,
    required this.quantityController,
    required this.payAmountController,
  });
}

class PaymentHistoryItem {
  final int actualStudentId; // ← real int studentId for print API
  final String studentId;    // registrationNo (display only)
  final String studentName;
  final String classSection;
  final String product;
  final String payDate;
  final String paymentMode;
  final String payAmount;
  final String receiptNo;
  final String session;      // ← session for print

  PaymentHistoryItem({
    this.actualStudentId = 0,  // ← default 0, hot reload crash fix
    required this.studentId,
    required this.studentName,
    required this.classSection,
    required this.product,
    required this.payDate,
    required this.paymentMode,
    required this.payAmount,
    required this.receiptNo,
    required this.session,
  });
}

class StationaryFeeActionController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final RxString selectedDate =
      DateFormat('dd/MM/yyyy').format(DateTime.now()).obs;
  final RxString selectedPaymentMode = ''.obs;

  final RxString studentName    = ''.obs;
  final RxString classSection   = ''.obs;
  final RxString session        = ''.obs;
  final RxString schoolId       = ''.obs;
  final RxString registrationNo = ''.obs;

  final RxInt studentId  = 0.obs;
  final RxInt classId    = 0.obs;
  final RxInt sectionId  = 0.obs;

  final RxBool isLoadingStudent        = false.obs;
  final RxBool isLoadingStationary     = false.obs;
  final RxBool isLoadingPaymentModes   = false.obs;
  final RxBool isLoadingPaymentHistory = false.obs;
  final RxBool isSubmittingPayment     = false.obs;

  final RxList<StationaryItem>     stationaryItems = <StationaryItem>[].obs;
  final RxList<PaymentHistoryItem> paymentHistory  = <PaymentHistoryItem>[].obs;
  final RxList<dynamic>            paymentModes    = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _readArguments();

    if (studentId.value > 0 &&
        schoolId.value.trim().isNotEmpty &&
        session.value.trim().isNotEmpty) {
      fetchStudentDetails();
      fetchStationaryItems();
      fetchPaymentModes();
      fetchPaymentHistory();
    } else {
      Get.snackbar(
        'Error',
        'StudentId, SchoolId or Session is missing',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _readArguments() {
    final args = Get.arguments;

    if (args is Map) {
      studentId.value      = int.tryParse('${args['studentId']      ?? ''}') ?? 0;
      schoolId.value       = '${args['schoolId']       ?? ''}'.trim();
      session.value        = '${args['currentSession'] ?? args['session'] ?? ''}'.trim();
      registrationNo.value = '${args['registrationNo'] ?? ''}'.trim();
      classId.value        = int.tryParse('${args['classId']    ?? ''}') ?? 0;
      sectionId.value      = int.tryParse('${args['sectionId']  ?? ''}') ?? 0;

      if ((args['studentName'] ?? '').toString().trim().isNotEmpty) {
        studentName.value = args['studentName'].toString().trim();
      }

      final className   = '${args['className']   ?? ''}'.trim();
      final sectionName = '${args['sectionName'] ?? ''}'.trim();

      if (className.isNotEmpty && sectionName.isNotEmpty) {
        classSection.value = '$className/$sectionName';
      } else if (className.isNotEmpty) {
        classSection.value = className;
      }
      return;
    }

    if (args is StudentListData) {
      studentId.value      = args.studentID ?? 0;
      schoolId.value       = args.schoolId?.toString().trim()        ?? '';
      session.value        = args.session?.toString().trim()         ?? '';
      registrationNo.value = args.registrationNo?.toString().trim()  ?? '';
      studentName.value    = args.studentName?.toString().trim()     ?? '';
      classId.value        = args.classId   ?? 0;
      sectionId.value      = args.sectionId ?? 0;

      final className   = args.className?.toString().trim()   ?? '';
      final sectionName = args.sectionName?.toString().trim() ?? '';

      if (className.isNotEmpty && sectionName.isNotEmpty) {
        classSection.value = '$className/$sectionName';
      } else if (className.isNotEmpty) {
        classSection.value = className;
      }
      return;
    }

    studentId.value      = 0;
    schoolId.value       = '';
    session.value        = '';
    registrationNo.value = '';
    classId.value        = 0;
    sectionId.value      = 0;
  }

  Future<void> fetchStudentDetails() async {
    try {
      isLoadingStudent.value = true;
      final url = Uri.parse(
        'https://playschool.edubloom.in/api/StudentApp/GetStudentDetailsApp/${studentId.value}?currentSession=${session.value}&schoolId=${schoolId.value}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final model = stationaryAction1ModelFromJson(response.body);
        if (model.isSuccess == true && model.data != null) {
          final data = model.data!;
          studentName.value = data.studentName?.trim() ?? '';
          final className   = data.className?.trim()   ?? '';
          final sectionName = data.sectionName?.trim() ?? '';
          if (className.isNotEmpty && sectionName.isNotEmpty) {
            classSection.value = '$className/$sectionName';
          } else if (className.isNotEmpty) {
            classSection.value = className;
          } else {
            classSection.value = '';
          }
          if ((data.session    ?? '').trim().isNotEmpty) session.value   = data.session!.trim();
          if ((data.schoolId   ?? '').trim().isNotEmpty) schoolId.value  = data.schoolId!.trim();
          if (data.classId   != null) classId.value   = data.classId!;
          if (data.sectionId != null) sectionId.value = data.sectionId!;
          if ((data.registrationNo ?? '').trim().isNotEmpty) {
            registrationNo.value = data.registrationNo!.trim();
          }
        } else {
          Get.snackbar('Error', model.messages ?? 'Student details not found',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Error',
            'Failed to load student details. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingStudent.value = false;
    }
  }

  Future<void> fetchStationaryItems() async {
    try {
      isLoadingStationary.value = true;
      stationaryItems.clear();
      final url = Uri.parse(
        'https://playschool.edubloom.in/api/ProductApp/GetStationaryShowdataApp',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'schoolId': schoolId.value}),
      );
      if (response.statusCode == 200) {
        final model = stationaryAction2ModelFromJson(response.body);
        if (model.listData != null && model.listData!.isNotEmpty) {
          final items = <StationaryItem>[];
          for (int i = 0; i < model.listData!.length; i++) {
            final apiItem = model.listData![i];
            items.add(StationaryItem(
              id: i + 1,
              pmasterId: apiItem.pmasterId ?? 0,
              stationaryName: apiItem.product?.trim() ?? '',
              totalQuantity: apiItem.quantity ?? 0,
              quantityController: TextEditingController(),
              payAmountController: TextEditingController(),
            ));
          }
          stationaryItems.assignAll(items);
        } else {
          stationaryItems.clear();
          Get.snackbar('Info', 'No stationary items found',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Error',
            'Failed to load stationary items. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Stationary API error: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingStationary.value = false;
    }
  }

  Future<void> fetchPaymentModes() async {
    final url = Uri.parse(
      '${AppUrl.base_url}api/FeeMasterApp/ViewPaymentModeApp/${schoolId.value}',
    );
    try {
      isLoadingPaymentModes.value = true;
      selectedPaymentMode.value  = '';
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final paymentData  = PaymentModel.fromJson(jsonResponse);
        if (paymentData.listData != null && paymentData.listData.isNotEmpty) {
          paymentModes.value = paymentData.listData
              .map((item) => item.paymentMode ?? '')
              .where((pm) => pm.isNotEmpty)
              .toList();
        } else {
          Get.snackbar('Info', 'No payment modes available.',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Error',
            'Failed to load payment modes. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching payment modes: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPaymentModes.value = false;
    }
  }

  void onPaymentModeChanged(String? value) {
    if (value == null) return;
    selectedPaymentMode.value = value;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(selectedDate.value);
    } catch (_) {}
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDate.value = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  Future<void> fetchPaymentHistory() async {
    if (studentId.value <= 0 ||
        session.value.trim().isEmpty ||
        schoolId.value.trim().isEmpty) return;
    try {
      isLoadingPaymentHistory.value = true;
      paymentHistory.clear();
      final url = Uri.parse(
        'https://playschool.edubloom.in/api/ProductApp/GetPaymentDetailstableApp',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId.value,
          'session':   session.value,
          'schoolId':  schoolId.value,
        }),
      );
      if (response.statusCode == 200) {
        final model = stationaryAction3ModelFromJson(response.body);
        if (model.listData != null && model.listData!.isNotEmpty) {
          final rows = model.listData!.map((apiItem) {
            final cls = apiItem.className?.trim() ?? '';
            final sec = apiItem.section?.trim()   ?? '';
            final classSec = cls.isNotEmpty && sec.isNotEmpty
                ? '$cls/$sec'
                : cls.isNotEmpty ? cls : '-';
            String formattedPayDate = '-';
            if ((apiItem.payDate ?? '').trim().isNotEmpty) {
              try {
                formattedPayDate = DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(apiItem.payDate!));
              } catch (_) {
                formattedPayDate = apiItem.payDate!;
              }
            }
            return PaymentHistoryItem(
              actualStudentId: studentId.value,         // ← real int studentId
              studentId:    apiItem.registrationNo?.trim() ?? '-',
              studentName:  apiItem.studentName?.trim()    ?? '-',
              classSection: classSec,
              product:      apiItem.product?.trim()        ?? '-',
              payDate:      formattedPayDate,
              paymentMode:  apiItem.paymentMode?.trim()    ?? '-',
              payAmount:    (apiItem.amount ?? 0).toString(),
              receiptNo:    apiItem.receiptno?.trim()      ?? '-',
              session:      apiItem.session?.trim()        ?? session.value,
            );
          }).toList();
          paymentHistory.assignAll(rows);
        } else {
          paymentHistory.clear();
        }
      } else {
        Get.snackbar('Error',
            'Failed to load payment history. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment history API error: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPaymentHistory.value = false;
    }
  }

  String _getPayDateFormatted() {
    try {
      final localDate = DateFormat('dd/MM/yyyy').parseStrict(selectedDate.value);
      return DateFormat('yyyy-MM-dd').format(localDate);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['popupMessage', 'messages', 'title']) {
          if (decoded[key] != null &&
              decoded[key].toString().trim().isNotEmpty) {
            return decoded[key].toString();
          }
        }
        if (decoded['detail'] != null &&
            decoded['detail'].toString().trim().isNotEmpty) {
          final d = decoded['detail'].toString();
          return d.length > 180 ? d.substring(0, 180) : d;
        }
      }
    } catch (_) {}
    return 'Payment failed';
  }

  Future<void> payNow() async {
    if (selectedPaymentMode.value.trim().isEmpty) {
      Get.snackbar('Validation', 'Please select payment mode',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (registrationNo.value.trim().isEmpty ||
        session.value.trim().isEmpty ||
        schoolId.value.trim().isEmpty) {
      Get.snackbar('Validation',
          'Registration No, Session or SchoolId missing',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (classId.value <= 0 || sectionId.value <= 0) {
      Get.snackbar('Validation', 'ClassId or SectionId missing',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (studentId.value <= 0) {
      Get.snackbar('Validation', 'StudentId missing',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final String payDateStr = _getPayDateFormatted();
    final List<Map<String, dynamic>> validRows = [];

    for (final item in stationaryItems) {
      final quantityText  = item.quantityController.text.trim();
      final payAmountText = item.payAmountController.text.trim();

      if ((quantityText.isNotEmpty && payAmountText.isEmpty) ||
          (quantityText.isEmpty && payAmountText.isNotEmpty)) {
        Get.snackbar('Validation',
            'every selected row Quantity and Pay Amount must be filled ',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (quantityText.isEmpty && payAmountText.isEmpty) continue;

      final int enteredQty    = int.tryParse(quantityText)  ?? 0;
      final int enteredAmount = int.tryParse(payAmountText) ?? 0;

      if (enteredQty <= 0) {
        Get.snackbar('Validation', 'Quantity will be greater than 0',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (enteredAmount <= 0) {
        Get.snackbar('Validation', 'Pay Amount will be greater than 0',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (enteredQty > item.totalQuantity) {
        Get.snackbar('Validation',
            '${item.stationaryName} ki quantity available stock se zyada ',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      validRows.add({
        'sfeeId':         0,
        'studentId':      studentId.value,
        'pmasterId':      item.pmasterId,
        'createBy':       'admin',
        'updateBy':       'string',
        'schoolId':       schoolId.value.trim(),
        'updateDate':     payDateStr,
        'createDate':     payDateStr,
        'action':         1,
        'quantity':       item.totalQuantity - enteredQty,
        'quantity1':      enteredQty,
        'amount':         enteredAmount,
        'registrationNo': registrationNo.value.trim(),
        'session':        session.value.trim(),
        'classId':        classId.value,
        'sectionId':      sectionId.value,
        'receiptno':      'string',
        'cquantity':      0,
        'paymentMode':    selectedPaymentMode.value.trim(),
        'payDate':        payDateStr,
      });
    }

    if (validRows.isEmpty) {
      Get.snackbar('Validation', 'Please enter at least one valid row',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSubmittingPayment.value = true;
      final url = Uri.parse(
        'https://playschool.edubloom.in/api/ProductApp/InsertStationaryFeeApp',
      );

      for (final row in validRows) {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'accept': '*/*'},
          body: jsonEncode(row),
        );

        if (response.statusCode != 200) {
          Get.snackbar('Error', _extractErrorMessage(response.body),
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 4));
          return;
        }

        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData['isSuccess'] != true) {
            Get.snackbar('Error', _extractErrorMessage(response.body),
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 4));
            return;
          }
        } catch (_) {
          Get.snackbar('Error', 'Invalid server response',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      Get.snackbar('Success', 'Payment processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));

      for (final item in stationaryItems) {
        item.quantityController.clear();
        item.payAmountController.clear();
      }
      await fetchStationaryItems();
      await fetchPaymentHistory();
    } catch (e) {
      Get.snackbar('Error', 'Error while processing payment: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } finally {
      isSubmittingPayment.value = false;
    }
  }

  // ── FIXED onPrint: actualStudentId (int) pass karo ──────────
  void onPrint(PaymentHistoryItem item) {
    Get.toNamed(
      RouteName.stationaryfeePrint,
      arguments: {
        'receiptNo': item.receiptNo,
        'studentId': item.actualStudentId,   // ← int value, 400 fix
        'session':   item.session,           // ← item ka session
        'schoolId':  schoolId.value,
      },
    );
  }

  @override
  void onClose() {
    for (final item in stationaryItems) {
      item.quantityController.dispose();
      item.payAmountController.dispose();
    }
    super.onClose();
  }
}