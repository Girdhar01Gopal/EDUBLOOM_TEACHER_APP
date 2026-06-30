import 'package:get/get.dart';

import '../controller/mastercontroller.dart';

class Masterbinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(
      () => Mastercontroller(),
    );
  }
}
