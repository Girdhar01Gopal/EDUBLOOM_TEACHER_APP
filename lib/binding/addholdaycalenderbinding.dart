import 'package:get/get.dart';

import '../controller/addholidaycalendercontroller.dart';

class AddHolidayCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddHolidayCalendarController>(() => AddHolidayCalendarController());
  }
}