import 'package:get/get.dart';

import '../controller/AddResultController.dart';

class AddResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddResultController>(() => AddResultController());
  }
}