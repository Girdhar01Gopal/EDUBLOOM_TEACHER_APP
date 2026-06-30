import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../models/paymentmodel.dart';
import '../models/student_fee_model.dart';
import '../res/app_url.dart';
import '../models/duefeesmodel.dart';

class SubmitFeeController extends GetxController {
  final feeItems = <ListData>[].obs;
  final checkboxStates = <bool>[].obs;
  final selectedRows = <ListData>[].obs;
  

  /// ✅ maps "AUG-Tuition Fee" -> dueAmount
  final dueAmounts = <String, int>{}.obs;

  /// ✅ maps "AUG-Tuition Fee" -> paidAmount
  final paidAmounts = <String, dynamic>{}.obs;

  final discountedAmounts = <String, int>{}.obs;

  final paymentModes = <PaymentData>[].obs;
  final selectedPaymentMode = ''.obs;
  final selectedDate = ''.obs;
  final totalPayAmount = 0.obs;
  final totalDiscount = 0.obs;
  final selectedFeeMonth = ''.obs;
  var status = ''.obs;

  final isLoading = false.obs;

  final remarksController = TextEditingController();

  final schoolId = ''.obs;
  final token = ''.obs;
  final session = ''.obs;
  final selectedStudentId = 0.obs;

  final bankName = ''.obs;
  final chequeDate = ''.obs;
  final chequeNo = ''.obs;
  final upiId = ''.obs;

  // ✅ normalize so key mismatch never happens
  String _norm(String s) => s.trim().toUpperCase();

double get totalAmount {
  double sum = 0;
  for (final row in selectedRows) {
    // Use dueAmount if it exists, otherwise use the base amount
    final due = dueAmounts['${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}'] ?? 0;
    final amount = int.tryParse(row.amount) ?? 0;

    // Prioritize dueAmount over baseAmount (row.amount)
    sum += (due > 0) ? due : amount;
  }
  return sum;
}

int getSelectedDueTotal() {
  int sum = 0;

  for (final row in selectedRows) {
    final key =
        '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';

    final due = dueAmounts[key] ?? (row.dueAmount ?? 0);
    sum += due;
  }

  return sum;
}


  double get totalDueAmount {
    double sum = 0;
    for (final row in selectedRows) {
      final key = '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';
      final due = dueAmounts[key] ?? (row.dueAmount ?? 0);
      sum += due.toDouble();
    }
    return sum;
  }

  @override
  Future<void> onInit() async {
    super.onInit();

   // token.value = await PrefManager().readValue(key: PrefConst.token);
    session.value = await PrefManager().readValue(key: PrefConst.session);
    schoolId.value = (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ?? '';

    // ✅ Take args FIRST
    final args = Get.arguments;
    if (args is Map) {
      final dynamic rows = args['feeItems'];
      final dynamic sid = args['studentId'];

      if (rows is List<ListData>) {
        feeItems.assignAll(rows);
      } else if (rows is List) {
        feeItems.assignAll(rows.whereType<ListData>().toList());
      } else {
        feeItems.clear();
      }

      selectedStudentId.value = sid is int ? sid : int.tryParse('$sid') ?? 0;
    } else if (args is List<ListData>) {
      feeItems.assignAll(args);
      selectedStudentId.value = feeItems.isNotEmpty ? feeItems.first.studentId : 0;
    } else {
      feeItems.clear();
      selectedStudentId.value = 0;
    }

    checkboxStates.assignAll(List<bool>.filled(feeItems.length, false));

    // ✅ Now call APIs (after feeItems exists)
    await refreshData();
  }

  /// Public method to refresh data when returning to this screen
  Future<void> refreshData() async {
    if (feeItems.isEmpty) return;
    
    // Priority: explicitly passed studentId -> fee item studentId -> parsed registrationNo
    final int studentIdOrRegNo = (selectedStudentId.value != 0)
      ? selectedStudentId.value
      : (feeItems.first.studentId != 0)
        ? feeItems.first.studentId
        : (int.tryParse(feeItems.first.registrationNo ?? '') ?? 0);

    await Future.wait([
      fetchPaymentModes(),
      fetchStudentFeePaidAndUnpaid(
        registrationNo: studentIdOrRegNo,
        session: session.value,
        schoolCode: schoolId.value,
      ),
      fetchDiscount(studentIdOrRegNo),
    ]);
    
    // Reset checkbox states after refresh
    checkboxStates.assignAll(List<bool>.filled(feeItems.length, false));
    selectedRows.clear();
  }

  /// ✅ NEW API
  Future<void> fetchStudentFeePaidAndUnpaid({
    required int registrationNo,
    required String session,
    required String schoolCode,
  }) async {
    if (session.isEmpty || schoolCode.isEmpty) return;

    isLoading.value = true;

    final encodedSchoolCode = Uri.encodeComponent(schoolCode);
    final url = Uri.parse(
      "https://playschool.edubloom.in/api/FeePaymentApp/studentFeePaidAndUpaid/$registrationNo/$session/$encodedSchoolCode",
    );
    print('Fetching studentFeePaidAndUpaid from $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final dueResponse = DueResponse.fromJson(decoded as Map<String, dynamic>);
        final list = dueResponse.listData;

        dueAmounts.clear();
        paidAmounts.clear();

        if (list != null) {
          for (final row in list) {
          final feeType = _norm(row.feeTypeDisplay ?? row.feeType ?? '');
          final feeMonth = _norm(row.feeMonth ?? ''); // should match feesDuration
           status.value = row.paidaction ?? '';

          // ✅ KEY EXACTLY like UI expects
          final key = '$feeMonth-$feeType';

          final due = row.dueAmount ?? 0;
          final paid = row.totalPay ?? 0;

          dueAmounts[key] = due;
          paidAmounts[key] = paid;
          print('Fetched for key=$key: due=$due, paid=$paid');
          }
        }
      } else {
        debugPrint("studentFeePaidAndUpaid Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e) {
      debugPrint("fetchStudentFeePaidAndUnpaid error: $e");
    } finally {
      isLoading.value = false;
    }
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
      Get.snackbar('Error', 'Failed to load payment modes');
    }
  }

  Future<void> fetchDiscount(int registrationNo) async {
    if (registrationNo == null) return;

    isLoading.value = true;
    final url = Uri.parse(
      "${AppUrl.base_url}api/FeePaymentApp/GetDiscountdetailsApp/${session.value}/${schoolId.value}?registrationNo=$registrationNo",
    );

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        // keep your existing logic
      } else {
       // Get.snackbar("Error", "Failed to load discount details.");
      }
    } catch (e) {
      Get.snackbar("Error", "Error occurred while fetching discount details.");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCheckbox(int index, bool? value) {
    checkboxStates[index] = value ?? false;
    final row = feeItems[index];

    if (checkboxStates[index]) {
      selectedRows.add(row);
      if (selectedFeeMonth.value.isEmpty) {
        selectedFeeMonth.value = row.feesDuration ?? '';
      }
    } else {
      selectedRows.remove(row);
      if (selectedRows.isEmpty) {
        selectedFeeMonth.value = '';
      } else {
        selectedFeeMonth.value = selectedRows.first.feesDuration ?? '';
      }
    }
  }

  /// Select all unpaid fees
  void selectAllUnpaidFees() {
    for (int i = 0; i < feeItems.length; i++) {
      final row = feeItems[i];
      final key = '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';
      final paid = paidAmounts[key] ?? 0;
      final baseAmount = int.tryParse(row.amount) ?? 0;

      // Only select if not fully paid
      if (baseAmount != paid) {
        checkboxStates[i] = true;
        if (!selectedRows.contains(row)) {
          selectedRows.add(row);
        }
      }
    }
    
    if (selectedRows.isNotEmpty && selectedFeeMonth.value.isEmpty) {
      selectedFeeMonth.value = selectedRows.first.feesDuration ?? '';
    }
    
    checkboxStates.refresh();
    selectedRows.refresh();
  }

  /// Clear all selections
  void clearAllSelections() {
    for (int i = 0; i < checkboxStates.length; i++) {
      checkboxStates[i] = false;
    }
    selectedRows.clear();
    selectedFeeMonth.value = '';
    checkboxStates.refresh();
    selectedRows.refresh();
  }

    /// Called when discount screen returns a discount amount
  void applyDiscountToSelectedFees(int discountAmount) {
    if (discountAmount <= 0) return;

    int remainingDiscount = discountAmount;

    for (int i = 0; i < feeItems.length; i++) {
      if (!checkboxStates[i] || remainingDiscount <= 0) continue;

      final row = feeItems[i];
      final key = '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';

      // Get current due amount from the map
      int currentDue = dueAmounts[key] ?? (row.dueAmount ?? 0);
      int baseAmount = int.tryParse(row.amount) ?? 0;

      // Apply discount to due amount first
      if (currentDue > 0) {
        final applied = remainingDiscount > currentDue ? currentDue : remainingDiscount;
        currentDue -= applied;
        remainingDiscount -= applied;
        dueAmounts[key] = currentDue;
        row.dueAmount = currentDue;
      }

      // If still have discount and no due, apply to base amount
      if (remainingDiscount > 0 && currentDue == 0) {
        final applied = remainingDiscount > baseAmount ? baseAmount : remainingDiscount;
        baseAmount -= applied;
        remainingDiscount -= applied;
        row.amount = baseAmount.toString();
        // Update discount field
        row.discount = (row.discount ?? 0) + applied;
      }

      discountedAmounts[key] = baseAmount + currentDue;
    }

    feeItems.refresh();
    checkboxStates.refresh();
    dueAmounts.refresh();
    
    if (remainingDiscount > 0) {
      Get.snackbar(
        'Info',
        'Discount of ₹${discountAmount - remainingDiscount} applied. Remaining ₹$remainingDiscount not used.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Success',
        'Discount of ₹$discountAmount applied successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(RouteName.dashboard_screen);
    }
  }
  
void showPaymentDetailsDialog({
  required String studentname,
  required String feesmonth,
  required String feetype,
  required var due,
}) {
  // Check if all selected fees are already paid
  if (totalDueAmount == 0 && totalAmount == 0) {
    Get.snackbar(
      'Info',
      'All selected fees are already paid',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    return;
  }

  final bool hasDueAmount = totalDueAmount > 0;
  final int maxPaymentAmount =
      hasDueAmount ? totalDueAmount.toInt() : totalAmount.toInt();

  // Prefill amount
  totalPayAmount.value = maxPaymentAmount;

  final payAmountController =
      TextEditingController(text: totalPayAmount.value.toString());
  final paymentDateController = TextEditingController(text: selectedDate.value);
  final int selectedDue = getSelectedDueTotal();

  Get.defaultDialog(
    title: 'Payment Details',
    contentPadding: EdgeInsets.zero,
    barrierDismissible: false,
    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.5, // Adjusted max height to allow scrolling
        maxWidth: Get.width * 0.92,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16, // Adjusted for keyboard
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected Fees Breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Selected Fees (${selectedRows.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 14),
                  ...selectedRows.map((row) {
                    final key = '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';
                    final dueForFee = dueAmounts[key] ?? 0;
                    final baseAmount = int.tryParse(row.amount) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${row.feeType}/${row.feesDuration}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            dueForFee > 0 ? '₹$dueForFee (Due)' : '₹$baseAmount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dueForFee > 0 ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Obx(() => Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 8),

            // Total Due
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Due Amount:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Obx(() => Text(
                      '₹${totalDueAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 14),

            TextField(
              controller: selectedRows.length > 1
                  ? TextEditingController(text: selectedDue > totalAmount ? selectedDue.toString() : totalAmount.toStringAsFixed(0))
                  : payAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: selectedRows.length > 1
                    ? "Pay ₹${selectedDue > totalAmount ? selectedDue : totalAmount.toStringAsFixed(0)}"
                    : "Pay ₹${selectedDue > 0 ? selectedDue : totalAmount.toStringAsFixed(0)}",
                helperStyle: const TextStyle(color: Colors.orange),
              ),
              onChanged: (value) {
                final enteredAmount = int.tryParse(value) ?? 0;

                if (enteredAmount > maxPaymentAmount) {
                  Get.snackbar(
                    'Warning',
                    'Payment amount cannot exceed ₹$maxPaymentAmount',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );

                  totalPayAmount.value = maxPaymentAmount;
                  payAmountController.text = maxPaymentAmount.toString();
                  payAmountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: payAmountController.text.length),
                  );
                } else {
                  totalPayAmount.value = enteredAmount;
                }
              },
              // Disable editing if more than 1 row is selected
              enabled: selectedRows.length == 1,
              // Show total amount and disable editing if multiple rows are selected
              readOnly: selectedRows.length > 1,
            ),

            const SizedBox(height: 14),

            // Payment Date
            Obx(() {
              // keep controller in sync
              if (paymentDateController.text != selectedDate.value) {
                paymentDateController.text = selectedDate.value;
              }

              return TextField(
                controller: paymentDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Payment Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            selectedDate.value =
                                date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                    ],
                  ),
                ),
                style: const TextStyle(fontSize: 12),
              );
            }),

            const SizedBox(height: 16),

            // Payment Mode
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedPaymentMode.value.isEmpty
                      ? null
                      : selectedPaymentMode.value,
                  decoration: InputDecoration(
                    labelText: 'Select Payment Mode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: paymentModes
                      .map((mode) => DropdownMenuItem(
                            value: mode.paymentMode,
                            child: Text(mode.paymentMode ?? 'N/A', style: TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (value) => selectedPaymentMode.value = value ?? '',
                )),

            const SizedBox(height: 16),

            /// Conditional Fields
            Obx(() {
              if (selectedPaymentMode.value == 'NEFT' ||
                  selectedPaymentMode.value == 'Cheque') {
                return Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => bankName.value = v.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cheque Date',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => chequeDate.value = v.trim(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cheque No',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => chequeNo.value = v.trim(),
                    ),
                  ],
                );
              }

              if (selectedPaymentMode.value == 'UPI') {
                return TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => upiId.value = v.trim(),
                );
              }

              return const SizedBox(height: 10);
            }),

          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          final mode = selectedPaymentMode.value;

          final invalid = selectedDate.value.isEmpty ||
              mode.isEmpty ||
              totalPayAmount.value <= 0 ||
              ((mode == 'NEFT') && bankName.value.isEmpty) ||
              ((mode == 'Cheque') &&
                  (chequeDate.value.isEmpty || chequeNo.value.isEmpty)) ||
              ((mode == 'UPI') && upiId.value.isEmpty);

          if (invalid) {
            Get.snackbar(
              'Error',
              'Please fill in all fields',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          submitFeeInstallment(fesmonth: feesmonth, studentn: studentname, feetype: feetype, dueamount: due, paydatee: paymentDateController.text );

          payAmountController.dispose();
          paymentDateController.dispose();
          Get.back();
        },
        child: const Text('Pay Now'),
      ),
    ],
  );
}

Future<void> submitFeeInstallment(
  {
    required String studentn,
    required String fesmonth,
    required var feetype,
    required var dueamount,
    required var paydatee,
  }
) async {
  final url = Uri.parse(
      "${AppUrl.base_url}api/FeePaymentApp/SubmitFeeInstallsMentApp");

  String utcNow() => DateTime.now().toUtc().toIso8601String();
  // Calculate total due for selected fees
  final int totalDueValue = totalDueAmount.toInt();
  final int totalPayValue = totalPayAmount.value.toInt();
  
  // Distribute payment proportionally across selected fees
  int remainingPayment = totalPayValue;
  
  final List<Map<String, dynamic>> paymentItems = [];

  for (final row in selectedRows) {
    if (remainingPayment <= 0) break;

    final key = '${_norm(row.feesDuration ?? '')}-${_norm(row.feeType ?? '')}';
    final dueForThisFee = dueAmounts[key] ?? (row.dueAmount ?? 0);
    final baseAmount = int.tryParse(row.amount) ?? 0;
    final discountForThisFee = row.discount ?? 0;

    // Priority: pay due amount first, then base amount
    int payForThisFee = 0;
    int newDueAmount = dueForThisFee;

    if (dueForThisFee > 0) {
      // Pay towards due
      payForThisFee = remainingPayment > dueForThisFee ? dueForThisFee : remainingPayment;
      newDueAmount = dueForThisFee - payForThisFee;
      remainingPayment -= payForThisFee;
    } else if (remainingPayment > 0) {
      // No due, pay towards base amount
      payForThisFee = remainingPayment > baseAmount ? baseAmount : remainingPayment;
      remainingPayment -= payForThisFee;
    }

    if (payForThisFee <= 0) continue;

    // Convert date-only string "2026-05-12" to full ISO 8601 UTC format
    final String payDateIso = paydatee.isNotEmpty
        ? DateTime.tryParse(paydatee)?.toUtc().toIso8601String() ?? utcNow()
        : utcNow();

    final item = {
      "paymentId": 0,
      "studentId": selectedStudentId.value,
      "registrationNo": row.registrationNo ?? "",
      "studentName": studentn,
      "session": session.value,
      "payDate": payDateIso,
      "feetype": row.feeType ?? "",
      "totalAmount": baseAmount,
      "payAmount": payForThisFee,
      "dueAmount": newDueAmount,
      "totalPay": payForThisFee,
      "discount": discountForThisFee,
      "receiptno": "string",
      "paymentReceiptNo": "string",
      "action": "1",
      "paymentMode": selectedPaymentMode.value,
      "remarks": remarksController.text.trim(),
      "bankName": bankName.value.isNotEmpty ? bankName.value : "string",
      "chequeDate": chequeDate.value.isNotEmpty ? chequeDate.value : "string",
      "chequeNo": chequeNo.value.isNotEmpty ? chequeNo.value : "string",
      "createDate": utcNow(),
      "createBy": "string",
      "schoolId": schoolId.value,
      "paidAmount": payForThisFee.toString(),
      "paidaction": newDueAmount == 0 && payForThisFee == baseAmount ? "Paid" : "Partial",
      "classid": row.classId,
      "feeMonth": row.feesDuration ?? "",
      "approveDate": utcNow(),
      "modePaymentOnline": selectedPaymentMode.value == 'UPI' ? upiId.value : "string",
      "orderNumber": "string",
      "transactionid": "string",
      "invid": 0,
      "createBy1": "string",
      "quarterFee": "string",
    };
    
    paymentItems.add(item);
  }

  if (paymentItems.isEmpty) {
    Get.snackbar("Error", "No valid payment items to submit");
    return;
  }

  print("Prepared ${paymentItems.length} payment items");
  print("REQUEST BODY => ${jsonEncode(paymentItems)}");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(paymentItems),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Get.snackbar(
        "Success",
        "Payment of ₹$totalPayValue submitted successfully for ${paymentItems.length} fee(s)!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Clear selections and refresh
      clearAllSelections();
      await refreshData();
    } else {
      print("ERROR => ${response.body}");
      Get.snackbar("Error", "Submission failed (${response.statusCode})");
    }
  } catch (e) {
    print("Exception => $e");
    Get.snackbar("Error", "$e");
  }
}

}
 