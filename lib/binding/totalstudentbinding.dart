import 'package:get/get.dart';
import '../controller/View_AttendanceController.dart';
import '../controller/totalstudentcontroller.dart';

class Totalstudentbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Totalstudentcontroller());
  }
}
