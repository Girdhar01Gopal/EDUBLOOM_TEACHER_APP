import 'package:get/get.dart';

import '../controller/add_expenses_controller.dart';
import '../controller/add_products_controller.dart';

class AddexpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddExpenseController>(() => AddExpenseController());
  }
}