import 'package:get/get.dart';
import '../controller/ClassWiseFeeStructureController.dart';

class ClassWiseFeeStructureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClassWiseFeeStructureController>(
          () => ClassWiseFeeStructureController(),
      fenix: true,
    );
  }
}
