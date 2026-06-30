import 'package:get/get.dart';
import '../controller/FeeDailyCollectionController.dart';

class FeeDailyCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeeDailyCollectionController>(() => FeeDailyCollectionController());
  }
}
