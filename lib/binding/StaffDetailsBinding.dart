import 'package:get/get.dart';
import '../controller/StaffDetailsController.dart';

class StaffDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StaffDetailsController());
  }
}