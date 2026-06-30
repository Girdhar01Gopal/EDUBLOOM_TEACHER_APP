import 'package:get/get.dart';
import '../controller/View_AttendanceController.dart';
import '../controller/viewtransaction.dart';

class Viewtransctionbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewtransactioncontroller());
  }
}
