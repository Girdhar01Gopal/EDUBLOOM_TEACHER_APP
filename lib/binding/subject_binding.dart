import 'package:get/get.dart';

import '../controller/subject_controller.dart';

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => SubjectController());
  }

}