import 'package:get/get.dart';
import '../controller/AttendanceController.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AttendanceController());
  }
}
