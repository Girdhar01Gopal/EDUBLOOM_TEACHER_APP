import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/birthdaymodel.dart';
import '../models/login_model.dart';
import '../models/school_expiry_model.dart';
import '../repo/repo.dart';
import '../res/app_url.dart';
import '../view_model/login_view_model.dart';
import 'package:http/http.dart' as https;

class DashboardScreenController extends GetxController {
  final myRepo = LoginRepository();
  RxInt totalStudentCount = 0.obs;
  var schoolname = "".obs;
  RxDouble totaldueamount = 0.0.obs;
  var cfPaymentGatewayService = CFPaymentGatewayService();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget = null;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);
  RxList<DhashboardItemsModel> vehicleDocumentList = <DhashboardItemsModel>[].obs;
  RxList<bData> birthdaylist = <bData>[].obs;

  // Expiry data observable
  Rx<ExpiryData?> expiryInfo = Rx<ExpiryData?>(null);

  List<DhashboardItemsModel> get filteredList =>
      vehicleDocumentList.where((item) => item.name != "Master's" && item.name != "Dashboard").toList();

  var session = "".obs;
  var schoolid = "".obs;
  var schoollname = "".obs;
  var schoollogo = "".obs;
  var expiryDate = "".obs;

  @override
  void onInit() async {
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";
    schoolid.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    schoolname.value = await PrefManager().readValue(key: PrefConst.Name) ?? "";
    schoollogo.value = await PrefManager().readValue(key: PrefConst.schoollogo) ?? "";
    print(schoollogo.value);
    schoollname.value = await PrefManager().readValue(key: PrefConst.schoolname) ?? "";
    expiry();
    await checkForAppUpdate();
    fetchBirthday();
    fetchtoken();
    dashboardCategory();
    totalamount();
    totaldue();
    initPaymentGateway();
    super.onInit();
  }

  void initPaymentGateway() {
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    print("Payment done for order: $orderId");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print("Error for order $orderId: ${errorResponse.getMessage()}");
  }

  Future<void> openPaymentGateway(String orderId, String paymentSessionId, CFEnvironment environment) async {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();
      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print("Exception: ${e.message}");
    }
  }

  Future<void> expiry() async {
    try {
      final url = Uri.parse(
          '${AppUrl.base_url}api/SchoolApp/GetSchoolExpiryDate?SchoolId=${schoolid.value}');
      print("Expiry date URL: $url");
      final response = await https.get(url);

      if (response.statusCode == 200) {
        var jsonBody = jsonDecode(response.body);
        print("Expiry date data: $jsonBody");

        final model = SchoolExpiryModel.fromJson(jsonBody);

        if (model.data.isNotEmpty) {
          final ed = model.data[0];
          expiryInfo.value = ed;

          final expiryDateStr = ed.expirydate.toIso8601String();
          expiryDate.value = expiryDateStr;
          await PrefManager().writeValue(key: PrefConst.expiry, value: expiryDateStr);

          DateTime currentDateOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          DateTime expiryDateOnly = DateTime(ed.expirydate.year, ed.expirydate.month, ed.expirydate.day);

          if (currentDateOnly == expiryDateOnly || currentDateOnly.isAfter(expiryDateOnly)) {
            _showExpiryAlertDialog(ed);
          }
        } else {
          print("Expiry date not found.");
        }
      } else {
        print("Failed to load expiry date, Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void _showExpiryAlertDialog(ExpiryData ed) {
    final fmt = DateFormat('dd MMM yyyy');
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final expiryOnly = DateTime(ed.expirydate.year, ed.expirydate.month, ed.expirydate.day);
    final daysLeft = expiryOnly.difference(today).inDays;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40.sp),
                      SizedBox(height: 8.h),
                      Text('Subscription Expired',
                          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4.h),
                      Text('Your plan has expired. Please renew.',
                          style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
                  child: Column(
                    children: [
                      _DialogInfoRow(label: 'School ID', value: ed.schoolId),
                      _DialogInfoRow(
                        label: 'Expired On',
                        value: fmt.format(ed.expirydate),
                        valueColor: Colors.red,
                      ),
                      _DialogInfoRow(
                        label: 'Days Overdue',
                        value: daysLeft < 0 ? '${daysLeft.abs()} days' : 'Today',
                        valueColor: Colors.red,
                      ),
                      _DialogInfoRow(label: 'Status', value: 'Expired', valueColor: Colors.red),

                      SizedBox(height: 16.h),
                      const Divider(height: 1),
                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green, size: 18.sp),
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: _launchPhone,
                            child: Text('+91 9717096165',
                                style: TextStyle(fontSize: 13.sp, color: Colors.blue,
                                    decoration: TextDecoration.none)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue, size: 18.sp),
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: _launchEmail,
                            child: Text('support@edubloom.in',
                                style: TextStyle(fontSize: 13.sp, color: Colors.blue,
                                    decoration: TextDecoration.none)),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 50.h,
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       Get.offAll(() => const SubscriptionPlansScreen());
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFF6C63FF),
                      //       foregroundColor: Colors.white,
                      //       elevation: 0,
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(14.r)),
                      //     ),
                      //     child: Text('Renew Subscription',
                      //         style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _launchPhone() async {
    const phoneUrl = 'tel:+919717096165';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    }
  }

  void _launchEmail() async {
    const emailUrl = 'mailto:info@monteage.in?subject=Subscription%20Expired';
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    }
  }

  Future<void> checkForAppUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          InAppUpdate.performImmediateUpdate()
              .catchError((e) => print("Immediate update error: $e"));
        } else if (updateInfo.flexibleUpdateAllowed) {
          InAppUpdate.startFlexibleUpdate()
              .then((_) => InAppUpdate.completeFlexibleUpdate())
              .catchError((e) => print("Flexible update error: $e"));
        }
      }
    } catch (e) {
      print("Failed to check for update: $e");
    }
  }

  void sendWishOnWhatsApp(String phone, String name, [String? message]) async {
    if (phone.isEmpty) {
      Get.snackbar("Error", "Mobile number is missing!");
      return;
    }
    final String msg = (message != null && message.trim().isNotEmpty)
        ? message.trim()
        : "🎂 Wish you a Very Happy Birthday, $name! 🎉🥳\nFrom: ${schoolname.value}";
    final String finalPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/91$finalPhone?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "WhatsApp not installed!");
    }
  }

  Future<void> fetchBirthday() async {
    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/StudentApp/GetDateOfBirthStudentsAsyncApp/$schoolid/$session");
      print("Request URL: $url");
      final response = await https.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        birthday birthdayData = birthday.fromJson(json);
        birthdaylist.assignAll(birthdayData.data ?? []);
        print("Birthday Data => ${json}");
      } else {
        Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ERROR fetching birthday data: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> totaldue() async {
    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/StudentApp/GetDeuFeeCollection?SchoolId=$schoolid&Session=$session");
      final response = await https.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        print("RAW RESPONSE → $jsonBody");
        dynamic data = jsonBody["data"];
        double value = 0.0;
        if (data is List && data.isNotEmpty) {
          value = _extractDue(data[0]);
        } else if (data is Map) {
          value = _extractDue(data);
        } else {
          value = _extractDue(jsonBody);
        }
        totaldueamount.value = value;
        print("✔️ FINAL DUE AMOUNT → ₹$value");
      }
    } catch (e) {
      print("❌ ERROR => $e");
    }
  }

  double _extractDue(Map item) {
    return (item["totalDueFeeAmount"] ??
        item["totalDueAmount"] ??
        item["TotalDueFeeAmount"] ??
        item["TotalDueAmount"] ??
        0).toDouble();
  }

  Future<void> totalamount() async {
    try {
      final url = Uri.parse("${AppUrl.base_url}api/StudentApp/GetTotalStudentAsynsApp");
      final body = {"currentSession": session.value, "schoolId": schoolid.value};
      print("Request Body: $body");
      print("Request URL: $url");
      final response = await https.post(url,
          headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = json["data"] as List?;
        totalStudentCount.value = (list != null && list.isNotEmpty)
            ? list[0]["totalStudent"] ?? 0
            : 0;
        print("Total Students => ${totalStudentCount.value}");
      } else {
        Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ERROR fetching student count: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> fetchtoken() async {
    var expireDate = await PrefManager().readValue(key: PrefConst.expireDate);
    if (expireDate != null) {
      DateTime lastDate = DateTime.parse(expireDate);
      isToday.value = DateFormat('yyyy-MM-dd').format(lastDate) ==
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (isToday.isTrue) {
        var username = await PrefManager().readValue(key: PrefConst.username);
        var password = await PrefManager().readValue(key: PrefConst.password);
        Map data = {
          "userName": username.toString(),
          "password": password.toString(),
          "rememberMe": true
        };
        loginApi(data);
      }
    }
  }

  Future<void> loginApi(dynamic data) async {
    myRepo.loginApi(data: data).then((value) async {
      var data = Login_Model.fromJson(value);
      if (data.data != null) {
        PrefManager().writeValue(
            key: PrefConst.token,
            value: data.data!.accessToker!.token.toString());
      } else if (data.statusCode == 400) {
        debugPrint("API error");
      }
    }).onError((error, stackTrace) {});
  }

  void onSelectedBottom(int index) {
    selectedIndex = index;
    if (index < 0 || index >= filteredList.length) return;
    final selectedItem = filteredList[index];
    switch (selectedItem.name) {
      case "Student's": selectedWidget = Get.toNamed(RouteName.addstudentmaster); break;
      case "Communication's": selectedWidget = Get.toNamed(RouteName.communicationview); break;
      //case "Master's": selectedWidget = Get.toNamed(RouteName.feesmaster); break;
      case "Activity's": selectedWidget = Get.toNamed(RouteName.activitymaster); break;
      case "Reports": selectedWidget = Get.toNamed(RouteName.reports); break;
      case "Certificate's": selectedWidget = Get.toNamed(RouteName.mastercertificate); break;
      case "Expenses": selectedWidget = Get.toNamed(RouteName.masterexpenses); break;
      case "Master's": selectedWidget = Get.toNamed(RouteName.master); break;
      case "Results": selectedWidget = Get.toNamed(RouteName.results); break;
      case "Products": selectedWidget = Get.toNamed(RouteName.products); break;
    }
  }

  void dashboardCategory() {
    final dhashboardItems = [
      DhashboardItemsModel("Student's", Icons.school_rounded, const Color(0xFF6366F1),
          gradientColors: [Color(0xFF6366F1), Color(0xFF818CF8)], emoji: '🎓'),
      DhashboardItemsModel("Communication's", Icons.forum_rounded, const Color(0xFF0EA5E9),
          gradientColors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)], emoji: '💬'),
      // DhashboardItemsModel("Fees's", Icons.account_balance_wallet_rounded, const Color(0xFFEF4444),
      //     gradientColors: [Color(0xFFEF4444), Color(0xFFFB7185)], emoji: '💰'),
      DhashboardItemsModel("Activity's", Icons.directions_run_rounded, const Color(0xFF14B8A6),
          gradientColors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)], emoji: '🎨'),
      DhashboardItemsModel("Certificate's", Icons.cast_for_education_rounded, const Color(0xFF10B981),
          gradientColors: [Color(0xFF10B981), Color(0xFF34D399)], emoji: '👩‍🏫'),
      DhashboardItemsModel("Expenses", Icons.badge_rounded, const Color(0xFF8B5CF6),
          gradientColors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], emoji: '🪪'),
      DhashboardItemsModel("Reports", Icons.bar_chart_rounded, const Color(0xFFF59E0B),
          gradientColors: [Color(0xFFF59E0B), Color(0xFFFBBF24)], emoji: '📊'),
      DhashboardItemsModel("Master's", Icons.admin_panel_settings_rounded, const Color(0xFF64748B),
          gradientColors: [Color(0xFF64748B), Color(0xFF94A3B8)], emoji: '⚙️'),
      DhashboardItemsModel("Results", Icons.emoji_events_rounded, const Color(0xFFF43F5E),
          gradientColors: [Color(0xFFF43F5E), Color(0xFFFF7070)], emoji: '🏆'),
      DhashboardItemsModel("Products", Icons.inventory_2_rounded, const Color(0xFFF97316),
          gradientColors: [Color(0xFFF97316), Color(0xFFFB923C)], emoji: '📦'),
    ];
    vehicleDocumentList.value = dhashboardItems;
  }
}

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DialogInfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1A2847),
          )),
        ],
      ),
    );
  }
}

class DhashboardItemsModel {
  String name;
  IconData? image;
  Color color;
  List<Color>? gradientColors;
  String emoji;

  DhashboardItemsModel(this.name, this.image, this.color,
      {this.gradientColors, this.emoji = ''});
}