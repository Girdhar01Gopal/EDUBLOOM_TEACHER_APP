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
import '../models/get all leave app.dart' as get_all_leave;
import '../models/leave apply model.dart' as leave_apply;
import '../models/leave balance dropdown model.dart' as leave_dropdown;

// TODO: adjust these import paths to wherever these model files actually
// live. Also make sure these two model classes expose every field the API
// actually returns (see the JSON samples referenced in the comments below):
//   - get_all_leave.EmployeeLeaveData must expose: totalLeave (int?),
//     totalTaken (int?), remainingLeave (int?) in addition to the existing
//     leave / takenLeaveTypes strings.
//   - leave_apply.LeaveData must expose: employeeName (String?),
//     balanceLeave (int?), totalLeave (int?) — the API already returns
//     these per leave request, they just weren't being read anywhere yet.

// ======================= Small helper: per-type balance row =======================
// Derived client-side by parsing EmployeeLeaveData.leave ("CL - 5 | MC - 12 | ...")
// and .takenLeaveTypes ("c - 1 | CL - 1 | ...") since that's the only place the
// API breaks balances down PER leave type. (The API does also return
// totalLeave / totalTaken / remainingLeave directly, but those are the
// *aggregate* numbers across every leave type combined — see
// overallTotalLeave / overallTakenLeave / overallRemainingLeave below.)
class LeaveTypeBalanceRow {
  final String type;
  final int total;
  final int taken;

  LeaveTypeBalanceRow({
    required this.type,
    required this.total,
    required this.taken,
  });

  int get remaining => total - taken;
}

// ======================= CONTROLLER =======================

class LeaveRequestController extends GetxController {
  // Base URL for all 3 real leave GET/POST APIs (test env).
  // TODO: confirm whether this should instead come from AppUrl.base_url.
  static const String _apiBase = "https://playschool.edubloom.in/api";

  // ── Lists ──────────────────────────────────────────────────────────
  final leaveRequestList = <leave_apply.LeaveData>[].obs;
  final leaveTypeList = <leave_dropdown.LeaveBalanceData>[].obs;

  // Full response from GetAllLeveApp is school-wide (all employees), so we
  // keep only the row that matches the logged-in user.
  final myLeaveSummary = Rx<get_all_leave.EmployeeLeaveData?>(null);

  // ── Loading flags ─────────────────────────────────────────────────
  final isLoading = false.obs; // list loading
  final isSubmitting = false.obs; // apply-leave submit loading
  final isTypesLoading = false.obs; // dropdown loading
  final isBalanceLoading = false.obs; // balance chips loading

  // ── Form fields ───────────────────────────────────────────────────
  final selectedLeaveType = Rx<leave_dropdown.LeaveBalanceData?>(null);
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
  String registrationNo = ""; // TODO: unknown source — sending empty for now.

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";

    // TODO: if the app already stores the active academic session in prefs,
    // read it here instead — this is a computed fallback ("2026-27" style)
    // so the 3 APIs below (which all require a session in their path/body)
    // don't break while that key is confirmed.
    session = _computeDefaultSession();

    await fetchLeaveTypes();
    fetchLeaveRequests();
    fetchLeaveBalance();
  }

  String _computeDefaultSession() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final endYearShort = (startYear + 1).toString().substring(2);
    return '$startYear-$endYearShort';
  }

  // ── Days count helpers ───────────────────────────────────────────
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int daysBetween(DateTime from, DateTime to) =>
      _dateOnly(to).difference(_dateOnly(from)).inDays + 1;

  int get selectedDaysCount {
    if (fromDate.value == null || toDate.value == null) return 0;
    return daysBetween(fromDate.value!, toDate.value!);
  }

  int daysCountForRequest(leave_apply.LeaveData item) {
    if (item.noOfDay != null) return item.noOfDay!;
    if (item.fromDate == null || item.toDate == null) return 0;
    return daysBetween(item.fromDate!, item.toDate!);
  }

  // ── Status summary for the View Requests tab ─────────────────────
  int get pendingCount => leaveRequestList
      .where((e) => (e.status ?? 'Pending').toLowerCase() == 'pending')
      .length;
  int get approvedCount => leaveRequestList
      .where((e) => (e.status ?? '').toLowerCase() == 'approved')
      .length;
  int get rejectedCount => leaveRequestList
      .where((e) => (e.status ?? '').toLowerCase() == 'rejected')
      .length;

  // ── Parse "CL - 5 | MC - 12 | ..." style strings into a type->count map ──
  Map<String, int> _parseLeaveCounts(String? raw) {
    final map = <String, int>{};
    if (raw == null || raw.trim().isEmpty) return map;
    for (final part in raw.split('|')) {
      final segment = part.trim();
      if (segment.isEmpty) continue;
      final pieces = segment.split('-');
      if (pieces.length < 2) continue;
      final type = pieces.first.trim();
      final value = int.tryParse(pieces.sublist(1).join('-').trim()) ?? 0;
      if (type.isEmpty) continue;
      map[type] = value;
    }
    return map;
  }

  /// Per-type balance rows for the current user, derived from
  /// [myLeaveSummary] (`leave` = total per type, `takenLeaveTypes` = taken
  /// per type). This is the source of truth for per-type balance/taken —
  /// e.g. for `"leave": "CL - 5", "takenLeaveTypes": "CL - 2"` this returns
  /// a single row: CL, total 5, taken 2, remaining 3.
  List<LeaveTypeBalanceRow> get leaveBalanceRows {
    final summary = myLeaveSummary.value;
    if (summary == null) return [];

    final totals = _parseLeaveCounts(summary.leave);
    final takenRaw = _parseLeaveCounts(summary.takenLeaveTypes);
    final takenLower = {
      for (final e in takenRaw.entries) e.key.toLowerCase(): e.value,
    };

    return totals.entries.map((e) {
      final taken = takenLower[e.key.toLowerCase()] ?? 0;
      return LeaveTypeBalanceRow(type: e.key, total: e.value, taken: taken);
    }).toList();
  }

  LeaveTypeBalanceRow? _matchingBalanceRow(String? leaveType) {
    if (leaveType == null || leaveType.trim().isEmpty) return null;
    for (final row in leaveBalanceRows) {
      if (row.type.toLowerCase() == leaveType.toLowerCase()) return row;
    }
    return null;
  }

  // ── Aggregate total / taken / remaining across ALL leave types ──────
  // The API returns these directly on the summary (`totalLeave`,
  // `totalTaken`, `remainingLeave`) so we use them as-is when present, and
  // only fall back to summing the per-type rows if the API ever omits them.
  int get overallTotalLeave {
    final apiValue = myLeaveSummary.value?.totalLeave;
    if (apiValue != null) return apiValue;
    return leaveBalanceRows.fold<int>(0, (sum, r) => sum + r.total);
  }

  int get overallTakenLeave {
    final apiValue = myLeaveSummary.value?.totalTaken;
    if (apiValue != null) return apiValue;
    return leaveBalanceRows.fold<int>(0, (sum, r) => sum + r.taken);
  }

  int get overallRemainingLeave {
    final apiValue = myLeaveSummary.value?.remainingLeave;
    if (apiValue != null) return apiValue;
    return overallTotalLeave - overallTakenLeave;
  }

  // ── Live, per-type balance/total/taken for a leave type ─────────────
  // IMPORTANT: the dropdown API's own `balanceLeave` / `totalLeave` /
  // `noOfDay` fields are template/master values and can be stale or zero
  // (confirmed from real data: ViewLeaveBalanceDropdown returned
  // `balanceLeave: 0, noOfDay: 8` for "CL", while GetAllLeveApp — the
  // user's actual usage record — correctly showed 5 total / 2 taken / 3
  // remaining for the same "CL" type). So these three always prefer the
  // real number parsed from GetAllLeveApp (via leaveBalanceRows) and only
  // fall back to the dropdown's own value if the user's summary has no
  // entry at all for that leave type yet.
  int balanceForType(leave_dropdown.LeaveBalanceData? type) {
    if (type == null) return 0;
    final row = _matchingBalanceRow(type.leave);
    if (row != null) return row.remaining;
    return type.balanceLeave ?? 0;
  }

  int totalForType(leave_dropdown.LeaveBalanceData? type) {
    if (type == null) return 0;
    final row = _matchingBalanceRow(type.leave);
    if (row != null) return row.total;
    return type.totalLeave ?? type.noOfDay ?? 0;
  }

  int takenForType(leave_dropdown.LeaveBalanceData? type) {
    if (type == null) return 0;
    final row = _matchingBalanceRow(type.leave);
    if (row != null) return row.taken;
    return 0;
  }

  // ── Fetch Leave Types + Balance (dropdown) ──────────────────────────
  // GET {base}/MasterApp/ViewLeaveBalanceDropdown/{schoolId}/{session}/{userId}
  Future<void> fetchLeaveTypes() async {
    if (schoolId.trim().isEmpty) {
      leaveTypeList.value = [];
      return;
    }

    try {
      isTypesLoading(true);

      final url = Uri.parse(
        '$_apiBase/MasterApp/ViewLeaveBalanceDropdown/$schoolId/$session/$userId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = leave_dropdown.LeaveBalanceDropdownResponse.fromJson(
          decoded,
        );
        leaveTypeList.value = model.listData;
      } else {
        Get.snackbar(
          "Error",
          "Failed to load leave types (${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching leave types: $e");
    } finally {
      isTypesLoading(false);
    }
  }

  void setSelectedLeaveType(leave_dropdown.LeaveBalanceData? value) =>
      selectedLeaveType.value = value;

  // ── Fetch Leave Balance (top chips) ─────────────────────────────────
  // GET {base}/SchoolApp/GetAllLeveApp/{schoolId}/{userId}
  // NOTE: this endpoint returns ALL employees of the school, so we pick out
  // the single row belonging to the logged-in user.
  Future<void> fetchLeaveBalance() async {
    try {
      isBalanceLoading(true);

      if (schoolId.isEmpty || userId.isEmpty) {
        myLeaveSummary.value = null;
        return;
      }

      final url = Uri.parse(
        '$_apiBase/SchoolApp/GetAllLeveApp/$schoolId/$userId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = get_all_leave.GetAllLeaveAppResponse.fromJson(
          jsonDecode(response.body),
        );
        final uid = int.tryParse(userId);

        get_all_leave.EmployeeLeaveData? found;
        for (final e in model.data) {
          if (e.userId == uid) {
            found = e;
            break;
          }
        }
        myLeaveSummary.value = found;
      } else {
        debugPrint("Failed to load leave balance: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching leave balance: $e");
    } finally {
      isBalanceLoading(false);
    }
  }

  // ── Date pickers ─────────────────────────────────────────────────
  // From Date: only today or a future date (past dates are hidden).
  Future<void> pickFromDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final maxDate = DateTime(today.year + 5);
    final currentValue = fromDate.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: (currentValue != null && !currentValue.isBefore(today))
          ? currentValue
          : today,
      firstDate: today,
      lastDate: maxDate,
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
    }
  }

  // To Date: from the selected From Date (or today) onward into the future.
  Future<void> pickToDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final maxDate = DateTime(today.year + 5);
    final minDate = fromDate.value ?? today;
    final currentValue = toDate.value;

    final picked = await showDatePicker(
      context: context,
      initialDate:
      (currentValue != null &&
          !currentValue.isBefore(minDate) &&
          !currentValue.isAfter(maxDate))
          ? currentValue
          : minDate,
      firstDate: minDate,
      lastDate: maxDate,
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
  // GET {base}/MasterApp/ViewLeaveApply/{schoolId}/{session}/{userId}
  Future<void> fetchLeaveRequests() async {
    try {
      isLoading(true);

      if (schoolId.isEmpty || userId.isEmpty) {
        leaveRequestList.value = [];
        return;
      }

      final url = Uri.parse(
        '$_apiBase/MasterApp/ViewLeaveApply/$schoolId/$session/$userId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = leave_apply.LeaveApplyResponse.fromJson(
          jsonDecode(response.body),
        );
        // Newest first.
        final list = model.listData;
        list.sort((a, b) {
          final ad = a.createdate ?? DateTime(2000);
          final bd = b.createdate ?? DateTime(2000);
          return bd.compareTo(ad);
        });
        leaveRequestList.value = list;
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
  // POST {base}/MasterApp/PostLeaveApply (multipart, attachment optional)
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
    final selected = selectedLeaveType.value!;
    // Use the same live numbers shown on screen (balanceForType/
    // totalForType) rather than the dropdown's own possibly-stale
    // balanceLeave/totalLeave/noOfDay, so what gets submitted matches what
    // the user actually saw on the form.
    final liveBalance = balanceForType(selected);
    final liveTotal = totalForType(selected);

    try {
      isSubmitting(true);

      final url = Uri.parse('$_apiBase/MasterApp/PostLeaveApply');
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'LeaveId': (editingLeaveId.value ?? 0).toString(),
        'UserId': userId,
        'RegistrationNo': registrationNo,
        'Leave': selected.leave ?? '',
        'BalanceLeave': liveBalance.toString(),
        'TotalLeave': liveTotal.toString(),
        'ReasonforLeave': reason.value.trim(),
        'FromDate': df.format(fromDate.value!),
        'ToDate': df.format(toDate.value!),
        'NoOfDay': selectedDaysCount.toString(),
        'Remark': '',
        'ApprovedRemark': '',
        'Action': '1',
        'SchoolId': schoolId,
        'Session': session,
        'Createdate': df.format(DateTime.now()),
        'CreateBy': 'Teacher',
      });

      if (attachmentFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'LeaveFile',
            attachmentFile.value!.path,
            filename: attachmentFile.value!.path.split('/').last,
          ),
        );
      }

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Give the submit call itself a bound so a slow network doesn't leave
      // the button stuck on "Submitting..." indefinitely.
      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final resBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        Map<String, dynamic> decoded = {};
        try {
          decoded = jsonDecode(resBody);
        } catch (_) {}

        final success = decoded['isSuccess'] == true;
        if (success) {
          ShortMessage.toast(
            title:
            decoded['messages']?.toString() ??
                "Leave Request Submitted Successfully",
          );
          resetForm();
          // Close the screen immediately instead of waiting on 3 sequential
          // GET calls — that serial refresh was the main source of the
          // "submit takes forever" delay. Refresh the lists/balances in the
          // background instead; the previous screen will pick them up.
          Get.back();
          Future.wait([
            fetchLeaveRequests(),
            fetchLeaveBalance(),
            fetchLeaveTypes(),
          ]);
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
  // NOTE: no cancel endpoint was provided among the real APIs — left as-is.
  Future<void> cancelLeaveRequest(int leaveId) async {
    ShortMessage.toast(title: "Cancel endpoint not provided yet.");
  }
}