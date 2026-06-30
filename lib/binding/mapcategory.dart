import 'package:get/get.dart';

import '../controller/mapcategory.dart';

class Mapcategorybinding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut(() => Mapcategorycontroller());
  }
}