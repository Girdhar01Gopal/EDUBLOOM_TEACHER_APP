import 'package:get/get.dart';
import '../controller/DailyActivityController.dart';

class DailyActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyActivityController>(
          () => DailyActivityController(),
    );
  }
}