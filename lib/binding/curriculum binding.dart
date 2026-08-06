import 'package:get/get.dart';

import '../controller/curriculum controller.dart';

class curriculumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CurriculumController());
  }
}
