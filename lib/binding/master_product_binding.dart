import 'package:get/get.dart';
import '../controller/master_product_controller.dart';

class ProductMasterViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductMasterViewController>(
          () => ProductMasterViewController(),
    );
  }
}