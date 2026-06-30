import 'package:get/get.dart';
import '../controller/foundational_skills_controller.dart';

class FoundationalSkillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoundationalSkillsController>(
          () => FoundationalSkillsController(),
    );
  }
}