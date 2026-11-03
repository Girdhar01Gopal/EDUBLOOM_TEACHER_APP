import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/add_expenses_model.dart';
import '../models/expenses_add_category_model.dart';
import '../models/paymentmodel.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../utils/app_snackbar.dart'; // 🆕 ADDED: common snackbar

class AddExpenseController extends GetxController {
  // ─── Text Controllers ──────────────────────────────────────────────────────
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // ─── Loading States ────────────────────────────────────────────────────────
  final RxBool isPosting = false.obs;
  final RxBool isLoadingExpenses = false.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingPaymentModes = false.obs;

  // ─── Category Dropdown ─────────────────────────────────────────────────────
  final RxList<AddCategory> categoryItems = <AddCategory>[].obs;
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final RxString selectedCategoryName = ''.obs;

  // ─── Payment Mode Dropdown ─────────────────────────────────────────────────
  final RxList<PaymentData> paymentModeItems = <PaymentData>[].obs;
  final Rx<int?> selectedPaymentModeId = Rx<int?>(null);
  final RxString selectedPaymentModeName = ''.obs;

  // ─── Expenses List ─────────────────────────────────────────────────────────
  final RxList<AddExpensesOnly> expensesList = <AddExpensesOnly>[].obs;

  // ─── Dynamic schoolId & session ───────────────────────────────────────────
  String schoolId = '';
  String currentSession = '';

  // ─── Selected Date ─────────────────────────────────────────────────────────
  DateTime? selectedDate;

  @override
  void onInit() async {
    super.onInit();

    // ── PrefManager se dynamic fetch — same as TransferCertificateReportsController ──
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    currentSession = await PrefManager().readValue(key: PrefConst.session);

    fetchCategories();
    fetchPaymentModes();
    fetchExpenses();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.onClose();
  }

  // ─── 1. GET Expenses List ──────────────────────────────────────────────────
  Future<void> fetchExpenses() async {
    try {
      isLoadingExpenses.value = true;
      expensesList.clear();

      final Map<String, dynamic> requestBody = {
        'schoolId': schoolId,
        'currentSession': currentSession,
      };

      final response = await http.post(
        Uri.parse(
          'https://playschool.edubloom.in/api/ExpensesApp/GetAddExpensesAsyncApp',
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          final List dataList = jsonResponse['data'] ?? [];
          final List<AddExpensesOnly> list = dataList
              .map((item) => AddExpensesOnly.fromJson(item))
              .toList();
          expensesList.assignAll(list);
        } else {
          // 🆕 CHANGED: Get.snackbar -> AppSnackbar.error
          // (technical / lamba text apne aap hide ho jata hai)
          AppSnackbar.error(
            jsonResponse['messages']?.toString() ??
                'Failed to fetch expenses.',
          );
        }
      } else {
        // 🆕 CHANGED: Get.snackbar -> AppSnackbar.apiError
        AppSnackbar.apiError(
          'Fetch failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error (URL wagairah) user ko nahi dikhega,
      // sirf "Something went wrong", asli error console me
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  // ─── 2. Fetch Categories ───────────────────────────────────────────────────
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      selectedCategoryId.value = null;
      selectedCategoryName.value = '';
      categoryItems.clear();

      final response = await http.get(
        Uri.parse(
          'https://playschool.edubloom.in/api/ExpensesApp/ViewAddExpensesCategoryApp/$schoolId',
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final AddCategoryResponse categoryResponse =
        AddCategoryResponse.fromJson(data);
        final List<AddCategory> categories = categoryResponse.listData;
        categories.sort((a, b) => b.createDate.compareTo(a.createDate));
        categoryItems.assignAll(categories);
      } else {
        // 🆕 CHANGED: Get.snackbar -> AppSnackbar.apiError
        AppSnackbar.apiError(
          'Failed to load categories: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ─── 3. Fetch Payment Modes ────────────────────────────────────────────────
  Future<void> fetchPaymentModes() async {
    try {
      isLoadingPaymentModes.value = true;
      selectedPaymentModeId.value = null;
      selectedPaymentModeName.value = '';
      paymentModeItems.clear();

      final response = await http.get(
        Uri.parse(
          'https://playschool.edubloom.in/api/FeeMasterApp/ViewPaymentModeApp/$schoolId',
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final PaymentModel paymentData = PaymentModel.fromJson(jsonResponse);

        if (paymentData.listData.isNotEmpty) {
          final validItems = paymentData.listData
              .where((item) =>
          item.paymentMode != null &&
              item.paymentMode!.isNotEmpty &&
              item.paymentModeId != null)
              .toList();
          paymentModeItems.assignAll(validItems);
        } else {
          // 🆕 CHANGED: Get.snackbar('Info') -> AppSnackbar.error
          // (AppSnackbar mein Info type nahi hai)
          AppSnackbar.error('No payment modes available.', title: 'Info');
        }
      } else {
        // 🆕 CHANGED: Get.snackbar -> AppSnackbar.apiError
        AppSnackbar.apiError(
          'Failed to load payment modes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isLoadingPaymentModes.value = false;
    }
  }

  // ─── 4. POST Add Expense ───────────────────────────────────────────────────
  Future<void> addExpense() async {
    // 🆕 CHANGED: Get.snackbar -> AppSnackbar (validations)
    if (selectedCategoryId.value == null) {
      AppSnackbar.error('Please select a category', title: 'Validation');
      return;
    }
    if (selectedPaymentModeId.value == null) {
      AppSnackbar.error('Please select a payment mode', title: 'Validation');
      return;
    }
    if (dateController.text.trim().isEmpty || selectedDate == null) {
      AppSnackbar.error('Please select a date', title: 'Validation');
      return;
    }
    final int? amount = int.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      AppSnackbar.error('Please enter a valid amount', title: 'Validation');
      return;
    }

    String description = descriptionController.text.trim();

    try {
      isPosting.value = true;

      final String selectDateIso = selectedDate!.toUtc().toIso8601String();
      final String nowIso = DateTime.now().toUtc().toIso8601String();

      final Map<String, dynamic> requestBody = {
        'addExpensesId': 0,
        'session': currentSession,
        'addEcategoryId': selectedCategoryId.value,
        'paymentModeId': selectedPaymentModeId.value,
        'selectdate': selectDateIso,
        'amount': amount,
        'description': description.isNotEmpty ? description : null,
        'action': '1',
        'createDate': nowIso,
        'updateDate': nowIso,
        'createBy': 'admin',
        'updateBy': 'admin',
        'schoolId': schoolId,
      };

      final response = await http.post(
        Uri.parse(
          'https://playschool.edubloom.in/api/ExpensesApp/PostAddExpensesApp',
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('POST Response Status: ${response.statusCode}');
      debugPrint('POST Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          _clearForm();
          // 🆕 CHANGED: Get.snackbar -> AppSnackbar.success
          AppSnackbar.success(
            jsonResponse['messages']?.toString() ??
                'Expense added successfully.',
          );
          await fetchExpenses();
        } else {
          // 🆕 CHANGED: Get.snackbar -> AppSnackbar.error
          AppSnackbar.error(
            jsonResponse['messages']?.toString() ?? 'Failed to add expense.',
          );
        }
      } else {
        debugPrint('Error Response: ${response.body}');
        // 🆕 CHANGED: response.body user ko nahi dikhegi, sirf console me
        AppSnackbar.apiError(
          'Server error: ${response.statusCode}\n${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stack) {
      debugPrint('Exception in addExpense: $e');
      // 🆕 CHANGED: raw error nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isPosting.value = false;
    }
  }

  // ─── Form Clear ────────────────────────────────────────────────────────────
  void _clearForm() {
    descriptionController.clear();
    amountController.clear();
    dateController.clear();
    selectedCategoryId.value = null;
    selectedCategoryName.value = '';
    selectedPaymentModeId.value = null;
    selectedPaymentModeName.value = '';
    selectedDate = null;
  }
}