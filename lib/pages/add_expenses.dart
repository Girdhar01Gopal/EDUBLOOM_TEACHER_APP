import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/add_expenses_controller.dart';
import '../models/expenses_add_category_model.dart';
import '../models/paymentmodel.dart';

class AddExpenseScreen extends GetView<AddExpenseController> {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      appBar: AppBar(
        title: const Text(
          'Add Expenses',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF97144D),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Breadcrumb ─────────────────────────────────────────────────
              Row(
                children: [


                  Text(
                    'Add Expenses',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Form Card ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1 — Category + Payment Mode
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Category ───────────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Category'),
                              const SizedBox(height: 6),
                              Obx(() {
                                if (controller.isLoadingCategories.value) {
                                  return _loadingField();
                                }
                                return DropdownButtonFormField<int>(
                                  value: controller.selectedCategoryId.value,
                                  isExpanded: true,
                                  decoration:
                                  _dropdownDecoration('Select Category'),
                                  items: controller.categoryItems
                                      .map((AddCategory item) {
                                    return DropdownMenuItem<int>(
                                      value: item.addEcategoryId,
                                      child: Text(
                                        item.category,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      controller.selectedCategoryId.value =
                                          value;
                                      final selected = controller.categoryItems
                                          .firstWhere(
                                              (c) => c.addEcategoryId == value);
                                      controller.selectedCategoryName.value =
                                          selected.category;
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ── Payment Mode ───────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Payment Name'),
                              const SizedBox(height: 6),
                              Obx(() {
                                if (controller.isLoadingPaymentModes.value) {
                                  return _loadingField();
                                }
                                return DropdownButtonFormField<int>(
                                  value:
                                  controller.selectedPaymentModeId.value,
                                  isExpanded: true,
                                  decoration: _dropdownDecoration(
                                      'Select Payment Mode'),
                                  items: controller.paymentModeItems
                                      .map((PaymentData item) {
                                    return DropdownMenuItem<int>(
                                      value: item.paymentModeId,
                                      child: Text(
                                        item.paymentMode ?? '',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      controller.selectedPaymentModeId.value =
                                          value;
                                      final selected = controller
                                          .paymentModeItems
                                          .firstWhere(
                                              (p) => p.paymentModeId == value);
                                      controller.selectedPaymentModeName
                                          .value = selected.paymentMode ?? '';
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 2 — Date + Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Date ───────────────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Select Date'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: controller.dateController,
                                    readOnly: true,
                                    decoration:
                                    _inputDecoration('DD-MM-YYYY'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ── Amount ─────────────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Amount'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: controller.amountController,
                                keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: _inputDecoration('0.00'),
                                onChanged: (value) {
                                  // Amount ko integer mein convert karo
                                  final int? amount = int.tryParse(value);
                                  if (amount != null) {
                                    // Agar valid integer ho, toh controller mein save karo
                                    controller.amountController.text = amount.toString();
                                  } else {
                                    // Agar invalid ho, toh koi action na lo
                                    controller.amountController.text = '0';
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Description ────────────────────────────────────────
                    _requiredLabel('Description'),
                    const SizedBox(height: 6),
                    // Description field ko optional banaya
                    TextField(
                      controller: controller.descriptionController,
                      decoration: _inputDecoration(''),
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: 20),

                    // ── Save Button ────────────────────────────────────────
                    Obx(
                          () => ElevatedButton(
                        onPressed: controller.isPosting.value
                            ? null
                            : controller.addExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: controller.isPosting.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Expenses List Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Expenses List',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (controller.isLoadingExpenses.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final list = controller.expensesList;

                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text('No Expenses Found')),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade100),
                          columnSpacing: 20,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 56,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          columns: const [
                            DataColumn(label: Text('S.no')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Payment Mode')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: List.generate(list.length, (index) {
                            final item = list[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(item.description)),
                                DataCell(Text(item.addECategory)),
                                DataCell(Text(item.paymentName)),
                                DataCell(Text(
                                    '₹${item.amount.toStringAsFixed(2)}')),
                                DataCell(Text(_formatDate(item.selectDate))),
                                DataCell(
                                  item.action == '1'
                                      ? Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: '$text ',
        style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _loadingField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Loading...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF97144D))),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF97144D))),
    );
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd-MMM-yyyy').format(dt);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // selectedDate controller mein save karo — POST mein yahi use hoga
      controller.selectedDate = picked;
      controller.dateController.text =
          DateFormat('dd-MM-yyyy').format(picked);
    }
  }
}