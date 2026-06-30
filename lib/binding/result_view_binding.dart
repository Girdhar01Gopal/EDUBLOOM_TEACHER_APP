import 'package:get/get.dart';

import '../controller/result_view_controller.dart';

class ResultViewBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => ResultViewController());
  }
}