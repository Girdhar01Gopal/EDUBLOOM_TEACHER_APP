import 'package:get/get.dart';

import '../controller/fees_controller.dart';
import '../controller/galaryvidevconroller.dart';

class Galleryvideobinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Galaryvidevconroller());
  }

}