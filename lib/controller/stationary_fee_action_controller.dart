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
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class StationaryItem {
  final int id;
  final String stationaryName;
  final int totalQuantity;
  final int pmasterId;
  final int unitPrice; // ← NEW: pAmount from API, per-unit price for auto-calc
  final TextEditingController quantityController;
  final TextEditingController payAmountController;

  StationaryItem({
    required this.id,
    required this.stationaryName,
    required this.totalQuantity,
    required this.pmasterId,
    required this.unitPrice, // ← NEW
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
      AppSnackbar.error('StudentId, SchoolId or Session is missing');
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
          AppSnackbar.error(model.messages ?? 'Student details not found');
        }
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          'Failed to load student details. Status: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
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
            final unitPrice = apiItem.pAmount ?? 0; // ← NEW: per-unit price

            final quantityController = TextEditingController();
            final payAmountController = TextEditingController();

            // ← NEW: auto-calculate Pay Amount = entered quantity * unitPrice
            quantityController.addListener(() {
              final enteredQty =
                  int.tryParse(quantityController.text.trim()) ?? 0;
              final calculatedAmount = enteredQty > 0
                  ? (enteredQty * unitPrice).toString()
                  : '';
              if (payAmountController.text != calculatedAmount) {
                payAmountController.text = calculatedAmount;
              }
            });

            items.add(StationaryItem(
              id: i + 1,
              pmasterId: apiItem.pmasterId ?? 0,
              stationaryName: apiItem.product?.trim() ?? '',
              totalQuantity: apiItem.quantity ?? 0,
              unitPrice: unitPrice, // ← NEW
              quantityController: quantityController,
              payAmountController: payAmountController,
            ));
          }
          stationaryItems.assignAll(items);
        } else {
          stationaryItems.clear();
          AppSnackbar.error('No stationary items found', title: 'Info');
        }
      } else {
        AppSnackbar.apiError(
          'Failed to load stationary items. Status: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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
          AppSnackbar.error('No payment modes available.', title: 'Info');
        }
      } else {
        AppSnackbar.apiError(
          'Failed to load payment modes. Status: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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
        AppSnackbar.apiError(
          'Failed to load payment history. Status: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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
      AppSnackbar.error('Please select payment mode', title: 'Validation');
      return;
    }
    if (registrationNo.value.trim().isEmpty ||
        session.value.trim().isEmpty ||
        schoolId.value.trim().isEmpty) {
      AppSnackbar.error('Registration No, Session or SchoolId missing',
          title: 'Validation');
      return;
    }
    if (classId.value <= 0 || sectionId.value <= 0) {
      AppSnackbar.error('ClassId or SectionId missing', title: 'Validation');
      return;
    }
    if (studentId.value <= 0) {
      AppSnackbar.error('StudentId missing', title: 'Validation');
      return;
    }

    final String payDateStr = _getPayDateFormatted();
    final List<Map<String, dynamic>> validRows = [];

    for (final item in stationaryItems) {
      final quantityText  = item.quantityController.text.trim();
      final payAmountText = item.payAmountController.text.trim();

      if ((quantityText.isNotEmpty && payAmountText.isEmpty) ||
          (quantityText.isEmpty && payAmountText.isNotEmpty)) {
        AppSnackbar.error(
            'every selected row Quantity and Pay Amount must be filled ',
            title: 'Validation');
        return;
      }
      if (quantityText.isEmpty && payAmountText.isEmpty) continue;

      final int enteredQty    = int.tryParse(quantityText)  ?? 0;
      final int enteredAmount = int.tryParse(payAmountText) ?? 0;

      if (enteredQty <= 0) {
        AppSnackbar.error('Quantity will be greater than 0',
            title: 'Validation');
        return;
      }
      if (enteredAmount <= 0) {
        AppSnackbar.error('Pay Amount will be greater than 0',
            title: 'Validation');
        return;
      }
      if (enteredQty > item.totalQuantity) {
        AppSnackbar.error(
            '${item.stationaryName} ki quantity available stock se zyada ',
            title: 'Validation');
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
      AppSnackbar.error('Please enter at least one valid row',
          title: 'Validation');
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
          // Server ka simple message dikhega, technical ho to Something went wrong
          AppSnackbar.error(_extractErrorMessage(response.body));
          return;
        }

        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData['isSuccess'] != true) {
            AppSnackbar.error(_extractErrorMessage(response.body));
            return;
          }
        } catch (_) {
          AppSnackbar.apiError('Invalid server response');
          return;
        }
      }

      AppSnackbar.success('Payment processed successfully');

      for (final item in stationaryItems) {
        item.quantityController.clear();
        item.payAmountController.clear();
      }
      await fetchStationaryItems();
      await fetchPaymentHistory();
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
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