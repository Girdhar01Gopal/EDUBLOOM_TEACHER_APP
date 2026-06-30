import 'package:get/get.dart';

import '../controller/syllabus_controller.dart';

class SyllabusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyllabusController());
  }
}
