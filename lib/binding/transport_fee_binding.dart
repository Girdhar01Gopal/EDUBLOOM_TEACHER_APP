// ─────────────────────────────────────────────────────────────
// FILE: transport_fee_binding.dart
// ─────────────────────────────────────────────────────────────
import 'package:get/get.dart';
import '../controller/transport_fee_controller.dart';

class TransportFeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransportFeeController>(
          () => TransportFeeController(),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// ROUTE NAME — add inside your RouteName class
// ─────────────────────────────────────────────────────────────
//
// static const String transportFee = '/transportFee';
//
// ─────────────────────────────────────────────────────────────
// GET PAGE — add inside your app routes list
// ─────────────────────────────────────────────────────────────
//
// GetPage(
//   name: RouteName.transportFee,
//   page: () => const TransportFeeScreen(),
//   binding: TransportFeeBinding(),
// ),