import 'package:get/get.dart';
import '../controller/DobCertificateController.dart';

class StudentListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StudentListController>(StudentListController());
  }
}