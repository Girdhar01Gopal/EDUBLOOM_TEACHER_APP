import 'package:get/get.dart';
import '../controller/daily_collection_class_wise.dart';

class DailyCollectionClassWiseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeeCollectionClassWiseController>(
          () => FeeCollectionClassWiseController(),
    );
  }
}
