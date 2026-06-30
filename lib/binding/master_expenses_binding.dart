import 'package:get/get.dart';
import '../controller/master_expenses_controller.dart';

class masterexpensesbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterExpensesViewController>(
          () => MasterExpensesViewController(),
    );
  }
}