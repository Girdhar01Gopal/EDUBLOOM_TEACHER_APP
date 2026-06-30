import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/add_product_model.dart';
import '../res/app_url.dart';

class AddProductsController extends GetxController {
  final TextEditingController productController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

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
    userName = await PrefManager().readValue(key: PrefConst.UserName) ?? "Admin";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await fetchProducts();
  }

  @override
  void onClose() {
    productController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    try {
      isListLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/ViewProductApp/$schoolId',
      );

      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = AddProductsResponse.fromJson(decoded);

        productsList.assignAll(parsed.listData);
        filteredList.assignAll(parsed.listData);
      } else {
        productsList.clear();
        filteredList.clear();
        Get.snackbar(
          "Error",
          "GET failed: ${res.statusCode}\n${res.body}",
        );
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

    try {
      isPosting(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/PostProductApp',
      );

      final now = DateTime.now().toUtc().toIso8601String();

      final body = {
        "pmasterId": 0,
        "product": text,
        "createBy": userName,
        "updateBy": userName,
        "schoolId": schoolId,
        "updateDate": now,
        "createDate": now,
        "action": 1,
        "session": session,
      };

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        final bool isSuccess = decoded["isSuccess"] == true;

        if (isSuccess) {
          productController.clear();
          await fetchProducts();
          Get.snackbar("Success", decoded["messages"] ?? "Added successfully");
        } else {
          Get.snackbar(
            "Error",
            decoded["messages"] ?? "Something went wrong",
          );
        }
      } else if (res.statusCode == 409) {
        Get.snackbar(
          "Duplicate",
          decoded["messages"] ?? "Product already exists for this SchoolId.",
        );
      } else {
        Get.snackbar(
          "Error",
          decoded["messages"] ?? "POST failed: ${res.statusCode}",
        );
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
          const SizedBox(height: 14),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPosting.value
                    ? null
                    : () async {
                  final updatedText = editController.text.trim();

                  if (updatedText.isEmpty) {
                    Get.snackbar(
                      "Validation",
                      "Product cannot be empty",
                    );
                    return;
                  }

                  await updateProduct(item, updatedText);
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
      ) async {
    try {
      isPosting(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/PostProductApp',
      );

      final body = {
        "pmasterId": item.pmasterId,
        "product": updatedText,
        "createBy": item.createBy ?? userName,
        "updateBy": userName,
        "schoolId": item.schoolId.isNotEmpty ? item.schoolId : schoolId,
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createDate":
        (item.createDate ?? DateTime.now()).toUtc().toIso8601String(),
        "action": item.action,
        "session": session,
      };

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        final bool isSuccess = decoded["isSuccess"] == true;

        if (isSuccess) {
          Get.back();
          await fetchProducts();
          Get.snackbar("Success", decoded["messages"] ?? "Updated successfully");
        } else {
          Get.snackbar(
            "Error",
            decoded["messages"] ?? "Something went wrong",
          );
        }
      } else if (res.statusCode == 409) {
        Get.snackbar(
          "Duplicate",
          decoded["messages"] ?? "Product already exists for this SchoolId.",
        );
      } else {
        Get.snackbar(
          "Error",
          decoded["messages"] ?? "Update failed: ${res.statusCode}",
        );
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
  }
}