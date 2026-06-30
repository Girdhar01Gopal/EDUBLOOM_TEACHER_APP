// view_girls_boys_report_binding.dart
import 'package:get/get.dart';
import '../controller/ViewGirlsBoysReportcontroller.dart';

class ViewGirlsBoysReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewGirlsBoysReportController>(() => ViewGirlsBoysReportController());
  }
}
