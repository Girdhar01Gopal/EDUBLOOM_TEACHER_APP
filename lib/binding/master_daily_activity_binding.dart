import 'package:get/get.dart';
import '../controller/master_daily_activity_controller.dart';

class MasterDailyActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterDailyActivityViewController>(
          () => MasterDailyActivityViewController(),
    );
  }
}