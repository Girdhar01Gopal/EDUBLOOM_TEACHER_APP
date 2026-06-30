import 'package:get/get.dart';

import '../controller/createandmapcategory.dart';

class Createandmapcategorybinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => Createandmapcategorycontroller());
    // TODO: implement dependencies
  }

}