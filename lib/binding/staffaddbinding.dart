import 'package:get/get.dart';
import '../controller/addstaffcontroller.dart';
import '../controller/teacher_add_controller.dart';

class Staffaddbinding extends Bindings {
  @override
  void dependencies() {
    // ✅ always create when route opens, and dispose when removed
    Get.lazyPut<Addstaffcontroller>(() => Addstaffcontroller(), fenix: false);
  }
}