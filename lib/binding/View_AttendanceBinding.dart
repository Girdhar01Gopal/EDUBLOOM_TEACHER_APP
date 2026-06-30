import 'package:get/get.dart';
import '../controller/View_AttendanceController.dart';

class ViewAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ViewAttendanceController());
  }
}
