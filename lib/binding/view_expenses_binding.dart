import 'package:get/get.dart';
import '../controller/View_AttendanceController.dart';
import '../controller/view_expenses_controller.dart';

class ViewexpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ViewExpensesController());
  }
}
