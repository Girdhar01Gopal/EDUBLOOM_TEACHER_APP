import 'package:get/get.dart';
import '../controller/expenses_add_category_controller.dart';

class ExpensesCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpensesCategoryController>(() => ExpensesCategoryController());
  }
}