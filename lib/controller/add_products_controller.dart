import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/add_product_model.dart';
import '../res/app_url.dart';
import '../data/network/network_api_response.dart'; // Import for NetworkApiServices

class AddProductsController extends GetxController {
  final NetworkApiServices _api = NetworkApiServices();

  final TextEditingController productController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController productsScrollController = ScrollController();

  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;
  final RxBool isPageLoading = false.obs;

  final RxList<AddProductsItem> productsList = <AddProductsItem>[].obs;
  final RxList<AddProductsItem> filteredList = <AddProductsItem>[].obs;

  String schoolId = "";
  String session = "";
  String userName = "Admin";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userName =
        await PrefManager().readValue(key: PrefConst.UserName) ?? "Admin";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await fetchProducts();
  }

  @override
  void onClose() {
    productController.dispose();
    amountController.dispose();
    searchController.dispose();
    productsScrollController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    try {
      isListLoading(true);

      final result = await _api
          .getJson('${AppUrl.base_url}${AppUrl.viewProductApp}$schoolId');

      if (result.isSuccess && result.data != null) {
        final parsed =
        AddProductsResponse.fromJson(result.data as Map<String, dynamic>);

        productsList.assignAll(parsed.listData);
        filteredList.assignAll(parsed.listData);
      } else {
        productsList.clear();
        filteredList.clear();
        Get.snackbar("Error", "GET failed: ${result.message}");
      }
    } catch (e) {
      productsList.clear();
      filteredList.clear();
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  void searchProduct(String value) {
    if (value.trim().isEmpty) {
      filteredList.assignAll(productsList);
      return;
    }

    filteredList.assignAll(
      productsList.where((item) {
        return item.product.toLowerCase().contains(value.toLowerCase());
      }).toList(),
    );
  }

  Future<void> addProduct() async {
    final text = productController.text.trim();

    if (text.isEmpty) {
      Get.snackbar("Validation", "Product cannot be empty");
      return;
    }

    final alreadyExists = productsList.any(
          (item) => item.product.trim().toLowerCase() == text.toLowerCase(),
    );
    if (alreadyExists) {
      Get.snackbar("Duplicate", "This product already exists");
      return;
    }

    final amountText = amountController.text.trim();
    final amount = num.tryParse(amountText);
    if (amountText.isEmpty || amount == null) {
      Get.snackbar("Validation", "Enter a valid amount");
      return;
    }

    try {
      isPosting(true);

      final now = DateTime.now().toUtc().toIso8601String();

      final body = {
        "pmasterId": 0,
        "product": text,
        "pAmount": amount,
        "amount": amount,
        "createBy": userName,
        "updateBy": userName,
        "schoolId": schoolId,
        "updateDate": now,
        "createDate": now,
        "action": 1,
        "session": session,
      };

      final result = await _api.postJson(
          '${AppUrl.base_url}${AppUrl.postProductApp}', body);

      if (result.isSuccess) {
        productController.clear();
        amountController.clear();
        await fetchProducts();
        Get.snackbar("Success", result.message);
      } else if (result.isDuplicate) {
        Get.snackbar("Duplicate", result.message);
      } else {
        Get.snackbar("Error", result.message);
      }
    } catch (e) {
      Get.snackbar("Error", "Add failed: $e");
    } finally {
      isPosting(false);
    }
  }

  void openEditProductDialog(AddProductsItem item) {
    final TextEditingController editController =
    TextEditingController(text: item.product);
    final TextEditingController editAmountController =
    TextEditingController(text: item.pAmount.toString());

    Get.defaultDialog(
      title: "Edit Product",
      radius: 8,
      content: Column(
        children: [
          TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Enter Product",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: editAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: "Enter Amount",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPosting.value
                    ? null
                    : () async {
                  final updatedText = editController.text.trim();
                  final updatedAmount =
                  num.tryParse(editAmountController.text.trim());

                  if (updatedText.isEmpty) {
                    Get.snackbar(
                      "Validation",
                      "Product cannot be empty",
                    );
                    return;
                  }
                  if (updatedAmount == null) {
                    Get.snackbar("Validation", "Enter a valid amount");
                    return;
                  }

                  await updateProduct(item, updatedText, updatedAmount);
                },
                child: isPosting.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Update"),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> updateProduct(
      AddProductsItem item,
      String updatedText,
      num updatedAmount,
      ) async {
    try {
      isPosting(true);

      final body = {
        "pmasterId": item.pmasterId,
        "product": updatedText,
        "pAmount": updatedAmount,
        "amount": updatedAmount,
        "createBy": item.createBy ?? userName,
        "updateBy": userName,
        "schoolId": item.schoolId.isNotEmpty ? item.schoolId : schoolId,
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createDate":
        (item.createDate ?? DateTime.now()).toUtc().toIso8601String(),
        "action": item.action,
        "session": session,
      };

      final result = await _api.postJson(
          '${AppUrl.base_url}${AppUrl.postProductApp}', body);

      if (result.isSuccess) {
        Get.back();
        await fetchProducts();
        Get.snackbar("Success", result.message);
      } else if (result.isDuplicate) {
        Get.snackbar("Duplicate", result.message);
      } else {
        Get.snackbar("Error", result.message);
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  Future<void> refreshList() async {
    await fetchProducts();
  }

  void resetForm() {
    productController.clear();
    amountController.clear();
  }

  // ---------------- Active / Inactive toggle ----------------
  final RxnInt statusLoadingId = RxnInt();

  Future<void> toggleProductStatus(AddProductsItem row) async {
    final id = row.pmasterId;

    statusLoadingId.value = id;
    try {
      final url =
          '${AppUrl.base_url}${AppUrl.productActiveandInactive}?SchoolId=$schoolId&Id=$id';

      final result = await _api.postJson(url, null);

      if (result.isSuccess) {
        final nextAction = row.action == 1 ? 0 : 1;
        row.action = nextAction;
        productsList.refresh();
        filteredList.refresh();
      } else {
        Get.snackbar("Error", "Status update failed: ${result.message}");
      }
    } catch (e) {
      Get.snackbar("Error", "Status update error: $e");
    } finally {
      statusLoadingId.value = null;
    }
  }
}