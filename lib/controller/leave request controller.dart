import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../res/app_url.dart';

// ======================= MODELS =======================
// NOTE: Move these into separate files under `models/` if you want to
// keep the same structure as the rest of the project.

class LeaveTypeData {
  int? leaveTypeId;
  String? leaveTypeName;

  LeaveTypeData({this.leaveTypeId, this.leaveTypeName});

  factory LeaveTypeData.fromJson(Map<String, dynamic> json) => LeaveTypeData(
    // 👇 supports both a generic "leaveTypeId/leaveTypeName" shape
    // and the actual ViewLeave API shape ("id" / "leave").
    leaveTypeId: json['leaveTypeId'] ?? json['LeaveTypeId'] ?? json['id'] ?? json['Id'],
    leaveTypeName: json['leaveTypeName'] ??
        json['LeaveTypeName'] ??
        json['leave'] ??
        json['Leave'],
  );
}

class LeaveTypeModel {
  bool? isSuccess;
  List<LeaveTypeData>? data;

  LeaveTypeModel({this.isSuccess, this.data});

  // 👇 accepts either a raw JSON array, or an object wrapping the list
  // under "listData" / "data" (ViewLeave API returns { "listData": [...] }).
  factory LeaveTypeModel.fromJson(dynamic json) {
    List<dynamic> rawList = [];
    bool? success;

    if (json is List) {
      rawList = json;
    } else if (json is Map<String, dynamic>) {
      rawList = (json['listData'] ?? json['data'] ?? json['Data'] ?? []) as List<dynamic>;
      success = json['isSuccess'];
    }

    return LeaveTypeModel(
      isSuccess: success,
      data: rawList.map((e) => LeaveTypeData.fromJson(e)).toList(),
    );
  }
}

class LeaveRequestData {
  int? leaveId;
  int? leaveTypeId;
  String? leaveTypeName;
  String? fromDate;
  String? toDate;
  String? reason;
  String? status; // Pending / Approved / Rejected
  String? appliedOn;
  String? attachmentFileName;
  String? remarksByAdmin;

  LeaveRequestData({
    this.leaveId,
    this.leaveTypeId,
    this.leaveTypeName,
    this.fromDate,
    this.toDate,
    this.reason,
    this.status,
    this.appliedOn,
    this.attachmentFileName,
    this.remarksByAdmin,
  });

  factory LeaveRequestData.fromJson(Map<String, dynamic> json) =>
      LeaveRequestData(
        leaveId: json['leaveId'] ?? json['LeaveId'],
        leaveTypeId: json['leaveTypeId'] ?? json['LeaveTypeId'],
        leaveTypeName: json['leaveTypeName'] ?? json['LeaveTypeName'],
        fromDate: json['fromDate'] ?? json['FromDate'],
        toDate: json['toDate'] ?? json['ToDate'],
        reason: json['reason'] ?? json['Reason'],
        status: json['status'] ?? json['Status'] ?? 'Pending',
        appliedOn: json['appliedOn'] ?? json['AppliedOn'] ?? json['createDate'],
        attachmentFileName:
        json['attachmentFileName'] ?? json['AttachmentFileName'],
        remarksByAdmin: json['remarksByAdmin'] ?? json['RemarksByAdmin'],
      );
}

class LeaveRequestModel {
  bool? isSuccess;
  List<LeaveRequestData>? data;

  LeaveRequestModel({this.isSuccess, this.data});

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      LeaveRequestModel(
        isSuccess: json['isSuccess'],
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => LeaveRequestData.fromJson(e))
            .toList(),
      );
}

class LeaveBalanceData {
  int? leaveTypeId;
  String? leaveTypeName;
  int? totalDays;
  int? usedDays;
  int? remainingDays;

  LeaveBalanceData({
    this.leaveTypeId,
    this.leaveTypeName,
    this.totalDays,
    this.usedDays,
    this.remainingDays,
  });

  factory LeaveBalanceData.fromJson(Map<String, dynamic> json) {
    final total = json['totalDays'] ?? json['TotalDays'] ?? 0;
    final used = json['usedDays'] ?? json['UsedDays'] ?? 0;
    // Prefer a remainingDays value from the API if present, else derive it.
    final remaining = json['remainingDays'] ??
        json['RemainingDays'] ??
        (total is int && used is int ? total - used : 0);

    return LeaveBalanceData(
      leaveTypeId: json['leaveTypeId'] ?? json['LeaveTypeId'],
      leaveTypeName: json['leaveTypeName'] ?? json['LeaveTypeName'],
      totalDays: total,
      usedDays: used,
      remainingDays: remaining,
    );
  }
}

class LeaveBalanceModel {
  bool? isSuccess;
  List<LeaveBalanceData>? data;

  LeaveBalanceModel({this.isSuccess, this.data});

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        isSuccess: json['isSuccess'],
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => LeaveBalanceData.fromJson(e))
            .toList(),
      );
}

// ======================= CONTROLLER =======================

class LeaveRequestController extends GetxController {
  // ── Lists ──────────────────────────────────────────────────────────
  final leaveRequestList = <LeaveRequestData>[].obs;
  final leaveTypeList = <LeaveTypeData>[].obs;
  final leaveBalanceList = <LeaveBalanceData>[].obs; // remaining days per leave type

  // ── Loading flags ─────────────────────────────────────────────────
  final isLoading = false.obs; // list loading
  final isSubmitting = false.obs; // apply-leave submit loading

  // ── Form fields ───────────────────────────────────────────────────
  final selectedLeaveType = Rx<LeaveTypeData?>(null);
  final fromDate = Rx<DateTime?>(null);
  final toDate = Rx<DateTime?>(null);
  final reason = ''.obs;
  final attachmentFile = Rx<File?>(null);

  // set when editing/cancelling an existing record
  final editingLeaveId = Rx<int?>(null);

  // ── Auth / school context ────────────────────────────────────────
  String token = "";
  String schoolId = "";
  String userId = "";
  String session = "";

  // ✅ Leave Type dropdown data comes from the actual ViewLeave master API
  // (same one used in LeaveController) — schoolId gets appended at the end.
  final String leaveTypeGetBaseUrl =
      "https://playschool.edubloom.in/api/MasterApp/ViewLeave/";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";
    // If you keep the active session in prefs, read it here, else leave blank.
    // session = await PrefManager().readValue(key: PrefConst.session) ?? "";

    await fetchLeaveTypes();
    fetchLeaveRequests();
    fetchLeaveBalance();
  }

  // ── Days count helpers ───────────────────────────────────────────
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Inclusive day count between two dates, e.g. 10-Jan to 12-Jan = 3 days.
  int daysBetween(DateTime from, DateTime to) =>
      _dateOnly(to).difference(_dateOnly(from)).inDays + 1;

  /// Days count for the form currently being filled (Add tab).
  int get selectedDaysCount {
    if (fromDate.value == null || toDate.value == null) return 0;
    return daysBetween(fromDate.value!, toDate.value!);
  }

  /// Days count for an already-fetched leave request (View tab), parsed
  /// from its string dates.
  int daysCountForRequest(LeaveRequestData item) {
    try {
      final from = DateTime.parse(item.fromDate ?? '');
      final to = DateTime.parse(item.toDate ?? '');
      return daysBetween(from, to);
    } catch (_) {
      return 0;
    }
  }

  // ── Fetch Leave Types (for dropdown) ────────────────────────────────
  // GET https://playschool.edubloom.in/api/MasterApp/ViewLeave/{schoolId}
  Future<void> fetchLeaveTypes() async {
    if (schoolId.trim().isEmpty) {
      leaveTypeList.value = [];
      return;
    }

    try {
      final url = Uri.parse('$leaveTypeGetBaseUrl$schoolId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = LeaveTypeModel.fromJson(decoded);
        leaveTypeList.value = model.data ?? [];
      } else {
        Get.snackbar("Error", "Failed to load leave types (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error fetching leave types: $e");
    }
  }

  void setSelectedLeaveType(LeaveTypeData? value) =>
      selectedLeaveType.value = value;

  // ── Fetch Leave Balance (remaining days per leave type) ─────────────
  // GET {base}/api/TeacherApp/GetLeaveBalance/{schoolId}/{userId}
  Future<void> fetchLeaveBalance() async {
    try {
      if (schoolId.isEmpty || userId.isEmpty) {
        leaveBalanceList.value = [];
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetLeaveBalance/$schoolId/$userId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = LeaveBalanceModel.fromJson(jsonDecode(response.body));
        leaveBalanceList.value = model.data ?? [];
      } else {
        debugPrint("Failed to load leave balance: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching leave balance: $e");
    }
  }

  // ── Date pickers (From Date can only be today or a past date) ──────
  Future<void> pickFromDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final currentValue = fromDate.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: (currentValue != null && !currentValue.isAfter(today))
          ? currentValue
          : today,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: today, // 👈 blocks all future dates
    );
    if (picked != null) {
      fromDate.value = picked;
      // reset toDate if it's before the new fromDate
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final minDate = fromDate.value ?? DateTime(DateTime.now().year - 1);
    final currentValue = toDate.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: (currentValue != null &&
          !currentValue.isBefore(minDate) &&
          !currentValue.isAfter(today))
          ? currentValue
          : (minDate.isAfter(today) ? today : minDate),
      firstDate: minDate, // 👈 can't be before From Date
      lastDate: today, // 👈 blocks all future dates
    );
    if (picked != null) {
      toDate.value = picked;
    }
  }

  // ── Attachment picker (optional) ────────────────────────────────
  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      attachmentFile.value = File(result.files.single.path!);
    }
  }

  void removeAttachment() => attachmentFile.value = null;

  void resetForm() {
    selectedLeaveType.value = null;
    fromDate.value = null;
    toDate.value = null;
    reason.value = "";
    attachmentFile.value = null;
    editingLeaveId.value = null;
  }

  // ── Fetch Leave Requests (View tab) ────────────────────────────────
  // GET {base}/api/TeacherApp/ViewLeaveRequest/{schoolId}/{userId}
  Future<void> fetchLeaveRequests() async {
    try {
      isLoading(true);

      if (schoolId.isEmpty || userId.isEmpty) {
        leaveRequestList.value = [];
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ViewLeaveRequest/$schoolId/$userId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = LeaveRequestModel.fromJson(jsonDecode(response.body));
        leaveRequestList.value = model.data ?? [];
      } else {
        Get.snackbar("Error", "Failed to load leave requests");
      }
    } catch (e) {
      debugPrint("Error fetching leave requests: $e");
    } finally {
      isLoading(false);
    }
  }

  // ── Apply Leave Request ──────────────────────────────────────────
  // POST {base}/api/TeacherApp/ApplyLeaveRequest  (multipart, attachment optional)
  Future<void> applyLeaveRequest() async {
    if (selectedLeaveType.value == null) {
      ShortMessage.toast(title: "Please select Leave Type.");
      return;
    }
    if (fromDate.value == null) {
      ShortMessage.toast(title: "Please select From Date.");
      return;
    }
    if (toDate.value == null) {
      ShortMessage.toast(title: "Please select To Date.");
      return;
    }
    if (toDate.value!.isBefore(fromDate.value!)) {
      ShortMessage.toast(title: "To Date cannot be before From Date.");
      return;
    }
    if (reason.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter Reason.");
      return;
    }

    final df = DateFormat('yyyy-MM-dd');

    try {
      isSubmitting(true);

      final url =
      Uri.parse('${AppUrl.base_url}api/TeacherApp/ApplyLeaveRequest');
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'LeaveId': (editingLeaveId.value ?? 0).toString(),
        'SchoolId': schoolId,
        'UserId': userId,
        'LeaveTypeId': selectedLeaveType.value!.leaveTypeId.toString(),
        'LeaveTypeName': selectedLeaveType.value!.leaveTypeName ?? '',
        'FromDate': df.format(fromDate.value!),
        'ToDate': df.format(toDate.value!),
        'Reason': reason.value.trim(),
        'Session': session,
        'CreateBy': 'Teacher',
      });

      if (attachmentFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Attachment',
            attachmentFile.value!.path,
            filename: attachmentFile.value!.path.split('/').last,
          ),
        );
      }

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamed = await request.send();
      final resBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        Map<String, dynamic> decoded = {};
        try {
          decoded = jsonDecode(resBody);
        } catch (_) {}

        final success = decoded['isSuccess'] == true;
        if (success) {
          ShortMessage.toast(
            title: decoded['messages']?.toString() ??
                "Leave Request Submitted Successfully",
          );
          resetForm();
          await fetchLeaveRequests();
          Get.back();
        } else {
          ShortMessage.toast(
            title: decoded['messages']?.toString() ?? "Submit failed",
          );
        }
      } else {
        ShortMessage.toast(title: "Submit failed (${streamed.statusCode})");
        debugPrint("Server Response: $resBody");
      }
    } catch (e) {
      ShortMessage.toast(title: "Something went wrong while submitting");
    } finally {
      isSubmitting(false);
    }
  }

  // ── Cancel a Pending Leave Request ───────────────────────────────
  // GET {base}/api/TeacherApp/CancelLeaveRequest/{schoolId}/{leaveId}
  Future<void> cancelLeaveRequest(int leaveId) async {
    if (schoolId.isEmpty || leaveId == 0) {
      ShortMessage.toast(title: "Invalid leave record");
      return;
    }

    try {
      isLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/CancelLeaveRequest/$schoolId/$leaveId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ShortMessage.toast(title: "Leave request cancelled");
        await fetchLeaveRequests();
      } else {
        Get.snackbar(
          "Error",
          "Failed to cancel leave (${response.statusCode})",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to cancel leave: $e");
    } finally {
      isLoading(false);
    }
  }
}