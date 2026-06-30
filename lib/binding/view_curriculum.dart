import 'package:get/get.dart';
import '../controller/view_curriculum.dart';

class ViewCurriculumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewCurriculumController>(() => ViewCurriculumController());
  }
}