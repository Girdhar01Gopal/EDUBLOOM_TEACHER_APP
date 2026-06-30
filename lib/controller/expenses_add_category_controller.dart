import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/expenses_add_category_model.dart';

class ExpensesCategoryController extends GetxController {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController editController = TextEditingController();

  final RxBool isPosting = false.obs;
  final RxBool isLoading = false.obs;

  final RxList<AddCategory> filteredStaticList = <AddCategory>[].obs;
  RxString schoolId = "".obs; // Dynamic schoolId

  @override
  void onInit() async {
    super.onInit();

    // Dynamically fetch schoolId from local storage or session
    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    if (schoolId.value.isEmpty) {
      Get.snackbar("Error", "SchoolId is missing.");
      return;
    }

    fetchCategories(schoolId.value); // Fetch categories dynamically based on schoolId
  }

  @override
  void onClose() {
    categoryController.dispose();
    searchController.dispose();
    editController.dispose();
    super.onClose();
  }

  // Fetch categories from API dynamically using schoolId
  Future<void> fetchCategories(String schoolId) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://playschool.edubloom.in/api/ExpensesApp/ViewAddExpensesCategoryApp/$schoolId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<AddCategory> categories = (data['listData'] as List)
            .map((item) => AddCategory.fromJson(item))
            .toList();

        // Sorting: Newest item first
        categories.sort((a, b) => b.createDate.compareTo(a.createDate));
        filteredStaticList.assignAll(categories);
      } else {
        Get.snackbar("Error", "Failed to load categories.");
      }
    } catch (e) {
      Get.snackbar("Error", "Error fetching categories: $e");
    } finally {
      isLoading(false);
    }
  }

  // Add category via API dynamically
  Future<void> addCategory() async {
    final category = categoryController.text.trim();
    if (category.isEmpty) {
      Get.snackbar("Validation", "Category name cannot be empty");
      return;
    }

    try {
      isPosting(true);
      final now = DateTime.now().toIso8601String();

      final response = await http.post(
        Uri.parse("https://playschool.edubloom.in/api/ExpensesApp/PostAddExpensesCategoryApp"),
        body: json.encode({
          "addEcategoryId": 0,
          "category": category,
          "action": "1",
          "createDate": now,
          "updateDate": now,
          "createBy": "admin",
          "updateBy": "string",
          "schoolId": schoolId.value, // Dynamically added schoolId
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newCategory = AddCategory.fromJson(data['data']);
        filteredStaticList.insert(0, newCategory);  // Insert new category at the top
        categoryController.clear();
        Get.snackbar("Success", "Category added successfully");
      } else {
        Get.snackbar("Error", "Failed to add category.");
      }
    } catch (e) {
      Get.snackbar("Error", "Error adding category: $e");
    } finally {
      isPosting(false);
    }
  }

  // Search categories
  void searchCategory(String value) {
    if (value.trim().isEmpty) {
      filteredStaticList.assignAll(filteredStaticList);
      return;
    }
    filteredStaticList.assignAll(
      filteredStaticList
          .where((item) => item.category!.toLowerCase().contains(value.toLowerCase()))
          .toList(),
    );
  }

  // Open Edit dialog
  void openEditDialog(int index) {
    final category = filteredStaticList[index];
    editController.text = category.category ?? '';

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: 'Edit Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateCategory(category.addEcategoryId);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Update category via API
  Future<void> updateCategory(int categoryId) async {
    final updatedCategory = editController.text.trim();
    if (updatedCategory.isEmpty) {
      Get.snackbar("Validation", "Category name cannot be empty");
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();

      final response = await http.post(
        Uri.parse("https://playschool.edubloom.in/api/ExpensesApp/PostAddExpensesCategoryApp"),
        body: json.encode({
          "addEcategoryId": categoryId,
          "category": updatedCategory,
          "action": "1",
          "createDate": now,
          "updateDate": now,
          "createBy": "admin",
          "updateBy": "string",
          "schoolId": schoolId.value, // Dynamically added schoolId
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedCategoryData = AddCategory.fromJson(data['data']);
        final index = filteredStaticList.indexWhere((item) => item.addEcategoryId == categoryId);
        if (index != -1) {
          filteredStaticList[index] = updatedCategoryData;
        }
        Get.snackbar("Success", "Category updated successfully");
        Get.back();  // Close dialog
      } else {
        Get.snackbar("Error", "Failed to update category.");
      }
    } catch (e) {
      Get.snackbar("Error", "Error updating category: $e");
    }
  }
}