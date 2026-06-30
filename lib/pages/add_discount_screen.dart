import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/add_discount_controller.dart';
import '../models/fee_type_model.dart';
import '../models/fees_duration_model.dart';

class AddDiscountScreen extends GetView<AddDiscountController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Discount"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.filteredList.isNotEmpty) {
                  final student = controller.filteredList.first;
                  return Center(
                    child: Text(
                      'Student Id: ${controller.studentId}, Class: ${student.className}, Section: ${student.section}, Session: ${student.session}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Center(
                  child: Text(
                    "No student data available",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }),
              SizedBox(height: 20),
              Text(
                'Fees Duration *',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return DropdownButtonFormField<DListData>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  hint: Text('Select Fees Duration'),
                  items: controller.feesDurationList.map((item) {
                    return DropdownMenuItem<DListData>(
                      value: item,
                      child: Text(item.feesDuration ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedFeesDuration.value =
                        value!.feesDurationId!;
                    controller.selectedFeesDurationName.value =
                        value!.feesDuration!;
                  },
                );
              }),
              SizedBox(height: 20),
              Text(
                'Fees Type ',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return DropdownButtonFormField<fData>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  hint: Text('Please Select Fees Type'),
                  items: controller.feeTypeList.map((item) {
                    return DropdownMenuItem<fData>(
                      value: item,
                      child: Text(item.feeType ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedFeeType.value = value!.feeTypeId!;
                    controller.selectedFeeTypeName.value = value.feeType!;
                  },
                );
              }),
              SizedBox(height: 20),
              Text(
                'Discount',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: controller.discountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Amount',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text(
                'Remark',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: controller.remarkController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Remarks',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate discount amount
                    final discountAmount = int.tryParse(controller.discountController.text) ?? 0;
                    final totalAmount = controller.getTotalAmount(); // You need to implement this method
                    
                    if (discountAmount > totalAmount) {
                      Get.snackbar(
                        'Invalid Discount',
                        'Discount amount cannot be greater than total fee amount (₹$totalAmount)',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: Duration(seconds: 3),
                      );
                      return;
                    }
                    
                    if (discountAmount <= 0) {
                      Get.snackbar(
                        'Invalid Discount',
                        'Please enter a valid discount amount',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    controller.submitDiscount(
                      controller.selectedFeesDuration.value,
                      controller.selectedFeesDurationName.value,
                      controller.selectedFeeType.value,
                      controller.selectedFeeTypeName.value,
                      controller.discountController.text,
                      controller.remarkController.text,
                      controller.studentId,
                      controller.filteredList.first.classId,
                      controller.filteredList.first.sectionId,
                      controller.filteredList.first.session,
                      controller.filteredList.first.schoolId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}