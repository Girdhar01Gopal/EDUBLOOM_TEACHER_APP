import 'package:get/get.dart';
import '../controller/daycareattendancecontroller2.dart';

class AttendanceDetailsDayCareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceDetailsDayCareController>(
          () => AttendanceDetailsDayCareController(),
    );
  }
}