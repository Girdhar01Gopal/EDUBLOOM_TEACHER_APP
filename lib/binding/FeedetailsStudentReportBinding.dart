import 'package:get/get.dart';

import '../controller/FeedetailsStudentReportsController.dart';

class Feedetailsstudentreportbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Feedetailsstudentreportscontroller());
  }
}
