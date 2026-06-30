import 'package:get/get.dart';

import '../controller/home_work_controller.dart';

class HomeworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeworkController()); // Use the EventController
  }
}
