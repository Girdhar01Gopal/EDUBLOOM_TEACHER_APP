import 'dart:convert';
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
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/birthdaymodel.dart';
import '../models/login_model.dart';
import '../models/school_expiry_model.dart';
import '../repo/repo.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart';
import '../utils/module_display.dart';
import '../view_model/login_view_model.dart';
import 'package:http/http.dart' as https;

// Finds the app-wide DashboardScreenController (registering it if some
// screen reaches for it before AppDrawer/home has had a chance to), so any
// sub-module controller can read the real, cached module-access list.
DashboardScreenController getDashboardController() =>
    Get.isRegistered<DashboardScreenController>()
        ? Get.find<DashboardScreenController>()
        : Get.put(DashboardScreenController());

// The activityName set of a top-level module's accessible children, e.g.
// accessibleChildNames('Teachers') -> {AddTeacher, TeacherAttendance, ...}.
// Used by sub-module screens to gate their (otherwise hardcoded) tiles by
// the current user's real per-child access instead of always showing them.
Set<String> accessibleChildNames(String parentActivityName) {
  for (final module in getDashboardController().accessibleModuleList) {
    if (module['activityName'] == parentActivityName) {
      final children = (module['childActivity'] as List?) ?? [];
      return children.map((c) => (c['activityName'] ?? '').toString()).toSet();
    }
  }
  return <String>{};
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class DashboardScreenController extends GetxController {
  static const _jsonHeaders = {"Content-Type": "application/json"};

  final myRepo = LoginRepository();
  RxInt totalStudentCount = 0.obs;
  var schoolname = "".obs;
  RxDouble totaldueamount = 0.0.obs;
  var cfPaymentGatewayService = CFPaymentGatewayService();

  int selectedIndex = 0;
  Future<dynamic>? selectedWidget;
  RxInt counter = 0.obs;
  final loginViewModel = Provider.of<LoginViewModel>(Get.context!);
  final RxBool isToday = RxBool(false);
  RxList<DhashboardItemsModel> vehicleDocumentList = <DhashboardItemsModel>[].obs;
  RxList<bData> birthdaylist = <bData>[].obs;

  // Expiry data observable
  Rx<ExpiryData?> expiryInfo = Rx<ExpiryData?>(null);

  List<DhashboardItemsModel> get filteredList => vehicleDocumentList
      .where((item) => item.moduleKey != "Master" && item.moduleKey != "Dashboard")
      .toList();

  var session = "".obs;
  var schoolid = "".obs;
  var schoollname = "".obs;
  var schoollogo = "".obs;
  var expiryDate = "".obs;
  RxInt userid = 0.obs;
  var list = [].obs;

  // Only the modules (and sub-modules) whose "access" flag is true.
  // A parent with access:false is still kept if it has at least one
  // accessible child, but its childActivity is trimmed to just those.
  List<Map<String, dynamic>> get accessibleModuleList =>
      _filterAccessibleModules(list);

  List<Map<String, dynamic>> _filterAccessibleModules(List items) {
    final result = <Map<String, dynamic>>[];
    for (final raw in items) {
      final item = Map<String, dynamic>.from(raw as Map);
      final children = item['childActivity'] as List?;
      final filteredChildren = (children != null && children.isNotEmpty)
          ? _filterAccessibleModules(children)
          : <Map<String, dynamic>>[];
      final hasAccess = item['access'] == true;
      if (hasAccess || filteredChildren.isNotEmpty) {
        item['childActivity'] = filteredChildren;
        result.add(item);
      }
    }
    return result;
  }

  // Reads the saved module-access value (JSON string or already a list).
  List _decodeModuleAccess(dynamic raw) =>
      raw is String ? jsonDecode(raw) as List : (raw ?? []);

  @override
  void onInit() async {
    final pref = PrefManager();
    session.value = await pref.readValue(key: PrefConst.session) ?? "";
    schoolid.value = await pref.readValue(key: PrefConst.schollId) ?? "";
    schoolname.value = await pref.readValue(key: PrefConst.Name) ?? "";
    schoollogo.value = await pref.readValue(key: PrefConst.schoollogo) ?? "";
    userid.value = int.tryParse(
      (await pref.readValue(key: PrefConst.Userid))?.toString() ?? '',
    ) ??
        0;

    schoollname.value = await pref.readValue(key: PrefConst.schoolname) ?? "";
    list.value = _decodeModuleAccess(await pref.readValue(key: PrefConst.moduleAccess));

    expiry();
    await checkForAppUpdate();

    loginViewModel.fetchModuleAccess(userid.value, schoolid.value).then((_) async {
      list.value = _decodeModuleAccess(await pref.readValue(key: PrefConst.moduleAccess));
      dashboardCategory();
    });

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

      if (response.statusCode != 200) {
        print("Failed to load expiry date, Status code: ${response.statusCode}");
        return;
      }

      final jsonBody = jsonDecode(response.body);
      print("Expiry date data: $jsonBody");

      final model = SchoolExpiryModel.fromJson(jsonBody);
      if (model.data.isEmpty) {
        print("Expiry date not found.");
        return;
      }

      final ed = model.data[0];
      expiryInfo.value = ed;

      final expiryDateStr = ed.expirydate.toIso8601String();
      expiryDate.value = expiryDateStr;
      await PrefManager().writeValue(key: PrefConst.expiry, value: expiryDateStr);

      final currentDateOnly = _dateOnly(DateTime.now());
      final expiryDateOnly = _dateOnly(ed.expirydate);

      if (!currentDateOnly.isBefore(expiryDateOnly)) {
        if (Get.isDialogOpen != true) {
          _showExpiryAlertDialog(ed);
        }
      } else if (Get.isDialogOpen == true) {
        Get.back();
        AppSnackbar.success("Subscription renewed successfully", title: "Renewed");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void _showExpiryAlertDialog(ExpiryData ed) {
    final fmt = DateFormat('dd MMM yyyy');
    final daysLeft = _dateOnly(ed.expirydate).difference(_dateOnly(DateTime.now())).inDays;

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
                      const _DialogInfoRow(label: 'Status', value: 'Expired', valueColor: Colors.red),

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
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                          Get.offAllNamed(RouteName.login_screen);
                          AppSnackbar.success("Teacher logged out successfully", title: "Logout");
                        },
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 18.sp),
                            SizedBox(width: 10.w),
                            Text('Logout',
                                style: TextStyle(fontSize: 13.sp, color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            expiry();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, color: const Color(0xFF00695C), size: 18.sp),
                              SizedBox(width: 10.w),
                              Text('Refresh',
                                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF00695C),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none)),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
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

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+919717096165');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:info@monteage.in?subject=Subscription%20Expired');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> checkForAppUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) return;

      if (updateInfo.immediateUpdateAllowed) {
        InAppUpdate.performImmediateUpdate()
            .catchError((e) => print("Immediate update error: $e"));
      } else if (updateInfo.flexibleUpdateAllowed) {
        InAppUpdate.startFlexibleUpdate()
            .then((_) => InAppUpdate.completeFlexibleUpdate())
            .catchError((e) => print("Flexible update error: $e"));
      }
    } catch (e) {
      print("Failed to check for update: $e");
    }
  }

  void sendWishOnWhatsApp(String phone, String name, [String? message]) async {
    if (phone.isEmpty) {
      AppSnackbar.error("Mobile number is missing!");
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
      AppSnackbar.error("WhatsApp is not installed on this device.");
    }
  }

  // One place that turns an API failure / exception into a friendly snackbar.
  void _showLoadError(String what, {Object? error, int? statusCode}) {
    AppSnackbar.error(
      AppSnackbar.friendlyMessage(
        error,
        statusCode: statusCode,
        fallback: 'Unable to load $what. Please try again.',
      ),
    );
  }

  Future<void> fetchBirthday() async {
    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/StudentApp/GetDateOfBirthStudentsAsyncApp/${schoolid.value}/${session.value}");
      print("Request URL: $url");
      final response = await https.get(url, headers: _jsonHeaders);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final birthdayData = birthday.fromJson(json);
        birthdaylist.assignAll(birthdayData.data ?? []);
        print("Birthday Data => $json");
      } else {
        print("Birthday API failed: ${response.statusCode}");
        _showLoadError('birthdays', statusCode: response.statusCode);
      }
    } catch (e) {
      print("❌ ERROR fetching birthday data: $e");
      _showLoadError('birthdays', error: e);
    }
  }

  Future<void> totaldue() async {
    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/StudentApp/GetDeuFeeCollection?SchoolId=${schoolid.value}&Session=${session.value}");
      final response = await https.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        print("RAW RESPONSE → $jsonBody");
        final dynamic data = jsonBody["data"];
        final double value;
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
      final response = await https.post(url, headers: _jsonHeaders, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json["data"] as List?;
        totalStudentCount.value = (data != null && data.isNotEmpty)
            ? data[0]["totalStudent"] ?? 0
            : 0;
        print("Total Students => ${totalStudentCount.value}");
      } else {
        print("Total students API failed: ${response.statusCode}");
        _showLoadError('student count', statusCode: response.statusCode);
      }
    } catch (e) {
      print("❌ ERROR fetching student count: $e");
      _showLoadError('student count', error: e);
    }
  }

  Future<void> fetchtoken() async {
    final pref = PrefManager();
    final expireDate = await pref.readValue(key: PrefConst.expireDate);
    if (expireDate == null) return;

    final lastDate = DateTime.parse(expireDate);
    isToday.value = DateFormat('yyyy-MM-dd').format(lastDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (isToday.isTrue) {
      final username = await pref.readValue(key: PrefConst.username);
      final password = await pref.readValue(key: PrefConst.password);
      final Map data = {
        "userName": username.toString(),
        "password": password.toString(),
        "rememberMe": true
      };
      loginApi(data);
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
    final items = filteredList;
    if (index < 0 || index >= items.length) return;
    final route = displayMetaFor(items[index].moduleKey).route;
    if (route != null) {
      selectedWidget = Get.toNamed(route);
    }
  }

  void dashboardCategory() {
    vehicleDocumentList.value = accessibleModuleList
        .where((module) => !displayMetaFor((module['activityName'] ?? '').toString()).hidden)
        .map((module) {
      final key = (module['activityName'] ?? '').toString();
      final meta = displayMetaFor(key);
      final label = meta.label ?? (module['displayName'] ?? module['activityName'] ?? '').toString();
      return DhashboardItemsModel(
        label,
        key,
        meta.icon,
        meta.color,
        gradientColors: [meta.color, meta.bgColor],
        emoji: meta.emoji,
      );
    }).toList();
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
  String moduleKey;
  IconData? image;
  Color color;
  List<Color>? gradientColors;
  String emoji;

  DhashboardItemsModel(this.name, this.moduleKey, this.image, this.color,
      {this.gradientColors, this.emoji = ''});
}