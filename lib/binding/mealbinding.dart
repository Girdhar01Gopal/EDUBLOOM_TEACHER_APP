import 'package:get/get.dart';

import '../controller/mealcontroller.dart';

class Mealbinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(
      () => Mealcontroller(),
    );
  }
}
