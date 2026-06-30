import 'package:get/get.dart';

import '../controller/term_result_controller.dart';

class TermResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermResultController>(() => TermResultController());
  }
}