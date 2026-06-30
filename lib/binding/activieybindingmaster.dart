import 'package:get/get.dart';


import '../controller/Activitymaster.dart';

class Activieybindingmaster extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Activitymastercontroller());
  }

}
