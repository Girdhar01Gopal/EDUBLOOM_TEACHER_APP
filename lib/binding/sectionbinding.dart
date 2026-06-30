
import 'package:get/get.dart';

import '../controller/sectioncontroller.dart';

class Sectionbinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => Sectioncontroller());
  }
}