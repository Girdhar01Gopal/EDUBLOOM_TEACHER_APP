import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/product_quantity_model.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class ProductQuantityController extends GetxController {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;
  final RxBool isDropdownLoading = false.obs;

  final RxString selectedProduct = ''.obs;

  final RxList<String> productDropdownList = <String>[].obs;
  final RxList<ProductQuantityData> productQuantityList =
      <ProductQuantityData>[].obs;
  final RxList<ProductQuantityData> filteredList =
      <ProductQuantityData>[].obs;

  /// productName -> pmasterId
  final Map<String, int> productMasterMap = <String, int>{};

  String schoolId = "";
  String session = "";
  String userName = "Admin";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userName = await PrefManager().readValue(key: PrefConst.UserName) ?? "Admin";

    await fetchProductDropdown();
    await fetchProductQuantityList();
  }

  @override
  void onClose() {
    quantityController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProductDropdown() async {
    if (schoolId.trim().isEmpty) {
      productDropdownList.clear();
      productMasterMap.clear();
      selectedProduct.value = "";
      return;
    }

    try {
      isDropdownLoading(true);

      final Uri url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/ViewProductApp/$schoolId',
      );

      final http.Response res = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> decoded =
        jsonDecode(res.body) as Map<String, dynamic>;

        final List<dynamic> rawList =
            (decoded['listData'] as List<dynamic>?) ?? <dynamic>[];

        productDropdownList.clear();
        productMasterMap.clear();

        for (final dynamic item in rawList) {
          final Map<String, dynamic> map = item as Map<String, dynamic>;
          final String productName = (map['product'] ?? '').toString().trim();
          final int pmasterId = map['pmasterId'] ?? 0;

          if (productName.isNotEmpty) {
            if (!productMasterMap.containsKey(productName)) {
              productMasterMap[productName] = pmasterId;
              productDropdownList.add(productName);
            }
          }
        }

        if (productDropdownList.isNotEmpty) {
          selectedProduct.value = productDropdownList.first;
        } else {
          selectedProduct.value = "";
        }
      } else {
        productDropdownList.clear();
        productMasterMap.clear();
        selectedProduct.value = "";
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Product dropdown fetch failed: ${res.statusCode} : ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      productDropdownList.clear();
      productMasterMap.clear();
      selectedProduct.value = "";
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isDropdownLoading(false);
    }
  }

  Future<void> fetchProductQuantityList() async {
    if (schoolId.trim().isEmpty || session.trim().isEmpty) {
      productQuantityList.clear();
      filteredList.clear();
      return;
    }

    try {
      isListLoading(true);

      final Uri url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/GetAllProductQuantityAsynsApp',
      );

      final Map<String, dynamic> body = <String, dynamic>{
        "schoolId": schoolId,
        "currentSession": session,
        "pmasterId": 0,
      };

      final http.Response res = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> decoded =
        jsonDecode(res.body) as Map<String, dynamic>;

        final ProductQuantity parsed = ProductQuantity.fromJson(decoded);

        if (parsed.isSuccess == true) {
          productQuantityList.assignAll(parsed.data ?? <ProductQuantityData>[]);
          filteredList.assignAll(parsed.data ?? <ProductQuantityData>[]);
        } else {
          productQuantityList.clear();
          filteredList.clear();
          // Server ka message technical hua to automatically "Something went wrong" ban jayega
          AppSnackbar.error(parsed.messages ?? "Failed to load list");
        }
      } else {
        productQuantityList.clear();
        filteredList.clear();
        AppSnackbar.apiError(
          "List fetch failed: ${res.statusCode} : ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      productQuantityList.clear();
      filteredList.clear();
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isListLoading(false);
    }
  }

  Future<void> addProductQuantity() async {
    final String productName = selectedProduct.value.trim();
    final String quantityText = quantityController.text.trim();

    if (productName.isEmpty) {
      AppSnackbar.error("Please select product name", title: "Validation");
      return;
    }

    if (quantityText.isEmpty) {
      AppSnackbar.error("Quantity cannot be empty", title: "Validation");
      return;
    }

    final int? qty = int.tryParse(quantityText);
    if (qty == null) {
      AppSnackbar.error("Quantity must be numeric", title: "Validation");
      return;
    }

    final int pmasterId = productMasterMap[productName] ?? 0;
    if (pmasterId == 0) {
      AppSnackbar.error("Invalid product selected");
      return;
    }

    try {
      isPosting(true);

      final Uri url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/PostProductQuantityApp',
      );

      final String now = DateTime.now().toUtc().toIso8601String();

      final Map<String, dynamic> body = <String, dynamic>{
        "productId": 0,
        "pmasterId": pmasterId,
        "createBy": userName,
        "updateBy": userName,
        "schoolId": schoolId,
        "updateDate": now,
        "createDate": now,
        "action": 1,
        "quantity": qty,
        "session": session,
      };

      final http.Response res = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          quantityController.clear();
          await fetchProductQuantityList();
          AppSnackbar.success(
            "$productName quantity added successfully",
          );
        } else {
          AppSnackbar.error(
            decoded["messages"]?.toString().trim().isNotEmpty == true
                ? decoded["messages"].toString()
                : "Failed to add product quantity",
          );
        }
      } else {
        if (decoded["messages"]?.toString().trim().isNotEmpty == true) {
          AppSnackbar.error(decoded["messages"].toString());
        } else {
          AppSnackbar.apiError(
            "Add failed: ${res.statusCode} : ${res.body}",
            statusCode: res.statusCode,
          );
        }
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  void openEditDialog(ProductQuantityData item) {
    final TextEditingController editQuantityController =
    TextEditingController(text: (item.quantity ?? 0).toString());

    final RxString editSelectedProduct =
        (item.productName ?? selectedProduct.value).obs;

    Get.defaultDialog(
      title: "Edit Product Quantity",
      radius: 8,
      content: Column(
        children: [
          Obx(() {
            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: editSelectedProduct.value.isEmpty
                  ? null
                  : editSelectedProduct.value,
              items: productDropdownList
                  .map(
                    (String product) => DropdownMenuItem<String>(
                  value: product,
                  child: Text(
                    product,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
                  .toList(),
              selectedItemBuilder: (BuildContext context) {
                return productDropdownList.map((String product) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              onChanged: (String? value) {
                if (value != null) {
                  editSelectedProduct.value = value;
                }
              },
              decoration: const InputDecoration(
                hintText: "Select Product",
                border: OutlineInputBorder(),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: editQuantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter Quantity",
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
                  final String updatedQty =
                  editQuantityController.text.trim();

                  if (updatedQty.isEmpty) {
                    AppSnackbar.error(
                      "Quantity cannot be empty",
                      title: "Validation",
                    );
                    return;
                  }

                  if (int.tryParse(updatedQty) == null) {
                    AppSnackbar.error(
                      "Quantity must be numeric",
                      title: "Validation",
                    );
                    return;
                  }

                  await updateProductQuantity(
                    item,
                    editSelectedProduct.value,
                    updatedQty,
                  );
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

  Future<void> updateProductQuantity(
      ProductQuantityData item,
      String updatedProductName,
      String updatedQuantity,
      ) async {
    final int? qty = int.tryParse(updatedQuantity);

    if (updatedProductName.trim().isEmpty) {
      AppSnackbar.error("Please select product name", title: "Validation");
      return;
    }

    if (qty == null) {
      AppSnackbar.error("Quantity must be numeric", title: "Validation");
      return;
    }

    final int pmasterId = productMasterMap[updatedProductName] ?? 0;
    if (pmasterId == 0) {
      AppSnackbar.error("Invalid product selected");
      return;
    }

    try {
      isPosting(true);

      final Uri url = Uri.parse(
        '${AppUrl.base_url}api/ProductApp/PostProductQuantityApp',
      );

      final Map<String, dynamic> body = <String, dynamic>{
        "productId": item.productId ?? 0,
        "pmasterId": pmasterId,
        "createBy": item.createBy ?? userName,
        "updateBy": userName,
        "schoolId": item.schoolId ?? schoolId,
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createDate": item.createDate ?? DateTime.now().toUtc().toIso8601String(),
        "action": item.action ?? 1,
        "quantity": qty,
        "session": session,
      };

      final http.Response res = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          await fetchProductQuantityList();
          AppSnackbar.success(
            decoded["messages"]?.toString() ??
                "Product quantity updated successfully",
          );
        } else {
          AppSnackbar.error(
            decoded["messages"]?.toString() ??
                "Failed to update product quantity",
          );
        }
      } else {
        if (decoded["messages"] != null) {
          AppSnackbar.error(decoded["messages"].toString());
        } else {
          AppSnackbar.apiError(
            "Update failed: ${res.statusCode} : ${res.body}",
            statusCode: res.statusCode,
          );
        }
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  void searchProductQuantity(String value) {
    if (value.trim().isEmpty) {
      filteredList.assignAll(productQuantityList);
      return;
    }

    final String search = value.toLowerCase();

    filteredList.assignAll(
      productQuantityList.where((ProductQuantityData item) {
        final String productName = (item.productName ?? '').toLowerCase();
        final String quantity = (item.quantity ?? 0).toString().toLowerCase();
        return productName.contains(search) || quantity.contains(search);
      }).toList(),
    );
  }

  Future<void> refreshList() async {
    await fetchProductDropdown();
    await fetchProductQuantityList();
  }

  void resetForm() {
    selectedProduct.value =
    productDropdownList.isNotEmpty ? productDropdownList.first : "";
    quantityController.clear();
  }
}