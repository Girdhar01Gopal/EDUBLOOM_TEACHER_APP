import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:teacher_app_edubloom/models/session_model.dart' as session_model;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/add_route_model.dart' hide RouteData;
import '../models/activitystudentmodel.dart' hide Data;
import '../models/feedurationmodel.dart';
import '../models/route_model_points.dart';
import '../models/routeno.dart';
import '../models/transport_fee_model.dart';
import '../res/app_url.dart';

// ── View List Model ──────────────────────────────────────────
class TFViewItem {
  final int transFeeHeadId;
  final String session;
  final String feesDuration;
  final dynamic routeNo;
  final String pickupPoint;
  final String transportType;
  final String amount;
  final String feesHead;
  final int routePointId;
  final int feeTypeId;
  final String createBy;
  final DateTime createDate;

  TFViewItem({
    required this.transFeeHeadId,
    required this.session,
    required this.feesDuration,
    this.routeNo,
    required this.pickupPoint,
    required this.transportType,
    required this.amount,
    required this.feesHead,
    required this.routePointId,
    required this.feeTypeId,
    required this.createBy,
    required this.createDate,
  });

  factory TFViewItem.fromTransportFee(TransportFee tf) => TFViewItem(
    transFeeHeadId: tf.transFeeHeadId,
    session: tf.session,
    feesDuration: tf.feesDuration,
    routeNo: tf.routeNo,
    pickupPoint: tf.pickupPoint,
    transportType: tf.transportType,
    amount: tf.amount,
    feesHead: tf.feesHead,
    routePointId: tf.routePointId,
    feeTypeId: tf.feeTypeId,
    createBy: tf.createBy,
    createDate: tf.createDate,
  );
}

// ════════════════════════════════════════════════════════════
class TransportFeeController extends GetxController {
  String schoolId = '';

  // ── Session ──────────────────────────────────────────────
  final sessionList     = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ── Fee Duration ─────────────────────────────────────────
  final feeDurationList     = <FeeDurationItem>[].obs;
  final selectedFeeDuration = Rx<FeeDurationItem?>(null);

  // ── Route ─────────────────────────────────────────────────
  final routeList     = <RouteData>[].obs;
  final selectedRoute = Rx<RouteData?>(null);

  // ── Stoppage (full Data object → gives routePointId) ──────
  final stoppageList     = <Data>[].obs;
  final selectedStoppage = Rx<Data?>(null);

  // ── Transport Type ────────────────────────────────────────
  final selectedTransportType = RxString('');

  // ── Amount ───────────────────────────────────────────────
  final amountController = TextEditingController();

  // ── View List ────────────────────────────────────────────
  final viewList = <TFViewItem>[].obs;

  // ── Loaders ──────────────────────────────────────────────
  final isPageLoading     = false.obs;
  final isSaving          = false.obs;
  final isListLoading     = false.obs;
  final isStoppageLoading = false.obs;

  // ─────────────────────────────────────────────────────────
  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    if (schoolId.trim().isEmpty) {
      Get.snackbar('Error', 'School ID not found');
      return;
    }
    await _loadAll();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> _loadAll() async {
    try {
      isPageLoading(true);
      await Future.wait([
        fetchSessions(),
        fetchFeeDurations(),
        fetchRoutes(),
        fetchViewList(),
      ]);
    } finally {
      isPageLoading(false);
    }
  }

  // ── 1. Sessions ───────────────────────────────────────────
  Future<void> fetchSessions() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session:   jsonData['currentSession']['currentSession'],
            action:    jsonData['currentSession']['action'],
            schoolId:  jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }

        if (jsonData['listData'] != null) {
          for (final e in (jsonData['listData'] as List)) {
            final s = session_model.sListDdata(
              sessionId: e['sessionId'],
              session:   e['session'],
              action:    e['action'],
              schoolId:  e['schoolId'],
            );
            if (!sessionList.any((x) => x.sessionId == s.sessionId)) {
              sessionList.add(s);
            }
          }
        }

        selectedSession.value ??=
        sessionList.isNotEmpty ? sessionList.first : null;
      } else {
        Get.snackbar('Error', 'Session API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Session fetch failed: $e');
    }
  }

  // ── 2. Fee Durations ──────────────────────────────────────
  Future<void> fetchFeeDurations() async {
    try {
      final res = await http.get(
        Uri.parse(
            '${AppUrl.base_url}api/FeeMasterApp/ViewFeesDurationApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = FeeDurationMaster.fromJson(jsonDecode(res.body));
        feeDurationList.assignAll(parsed.listData);
        selectedFeeDuration.value =
        parsed.listData.isNotEmpty ? parsed.listData.first : null;
      } else {
        Get.snackbar('Error', 'Fee Duration API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Fee Duration fetch failed: $e');
    }
  }

  // ── 3. Routes ─────────────────────────────────────────────
  Future<void> fetchRoutes() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/StudentApp/GetRouteApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = RouteResponse.fromJson(jsonDecode(res.body));
        routeList.assignAll(parsed.data);
      } else {
        Get.snackbar('Error', 'Route API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Route fetch failed: $e');
    }
  }

  // ── Route changed → fetch stoppages ──────────────────────
  void onRouteChanged(RouteData? route) {
    selectedRoute.value    = route;
    selectedStoppage.value = null;
    stoppageList.clear();
    if (route != null) fetchStoppages(route.routeNo);
  }

  // ── 4. Stoppages ──────────────────────────────────────────
  Future<void> fetchStoppages(int routeNo) async {
    try {
      isStoppageLoading(true);

      final res = await http.get(
        Uri.parse(
            '${AppUrl.base_url}api/StudentApp/GetPikPointApp/$schoolId/$routeNo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = RoutePoint.fromJson(jsonDecode(res.body));
        final points = (parsed.data ?? [])
            .where((d) => (d.pickupPoint ?? '').trim().isNotEmpty)
            .toList();
        stoppageList.assignAll(points);
      } else {
        Get.snackbar('Error', 'Stoppage API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Stoppage fetch failed: $e');
    } finally {
      isStoppageLoading(false);
    }
  }

  Future<void> fetchViewList() async {
    try {
      isListLoading(true);
      viewList.clear();

      final session = selectedSession.value?.session?.trim() ?? '';
      if (session.isEmpty) {
        return;
      }

      final url =
          '${AppUrl.base_url}api/MasterApp/GetTransportFeeHeadAppAsync/$schoolId/$session';

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed =
        TransportFeeResponse.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess) {
          viewList.assignAll(
            parsed.data.map((tf) => TFViewItem.fromTransportFee(tf)).toList(),
          );
        } else {
          viewList.clear();
        }
      } else {
        Get.snackbar('Error', 'View list API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'View list fetch failed: $e');
    } finally {
      isListLoading(false);
    }
  }

  // ── fetchViewList with session (called after session loads) ──
  Future<void> fetchViewListForSession(String session) async {
    try {
      isListLoading(true);
      viewList.clear();

      final url =
          '${AppUrl.base_url}api/MasterApp/GetTransportFeeHeadAppAsync/$schoolId/$session';

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed =
        TransportFeeResponse.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess) {
          viewList.assignAll(
            parsed.data.map((tf) => TFViewItem.fromTransportFee(tf)).toList(),
          );
        } else {
          viewList.clear();
        }
      }
    } catch (_) {
      // silent
    } finally {
      isListLoading(false);
    }
  }

  // ── 6. Save ───────────────────────────────────────────────
  Future<void> save(BuildContext context) async {
    if (selectedSession.value == null) {
      Get.snackbar('Validation', 'Please select Session');
      return;
    }
    if (selectedFeeDuration.value == null) {
      Get.snackbar('Validation', 'Please select Fee Duration');
      return;
    }
    if (selectedRoute.value == null) {
      Get.snackbar('Validation', 'Please select Route No.');
      return;
    }
    if (selectedStoppage.value == null) {
      Get.snackbar('Validation', 'Please select Stoppage');
      return;
    }
    final transportType = selectedTransportType.value.trim();
    if (transportType.isEmpty) {
      Get.snackbar('Validation', 'Please select Transport Type');
      return;
    }
    final amtText = amountController.text.trim();
    if (amtText.isEmpty) {
      Get.snackbar('Validation', 'Please enter Amount');
      return;
    }
    final amount = int.tryParse(amtText) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Validation', 'Amount must be greater than 0');
      return;
    }

    try {
      isSaving(true);

      final now = DateTime.now().toUtc().toIso8601String();

      final body = {
        'transFeeHeadId': 0,
        'session':        selectedSession.value!.session ?? '',
        'routeNo':        selectedRoute.value!.routeNo,
        'routeNameId':    selectedRoute.value!.routeNameId,
        'routePointId':   selectedStoppage.value!.routePointId ?? 0,
        'feesDurationId': selectedFeeDuration.value!.feesDurationId ?? 0,
        'feesHead':       'Transport Fee',
        'amount':         amtText,
        'action':         '1',
        'createDate':     now,
        'updateDate':     now,
        'createBy':       'Admin',
        'updateBy':       'string',
        'schoolId':       schoolId,
        'feeTypeId':      0,
        'transportType':  transportType,
      };

      final res = await http.post(
        Uri.parse('${AppUrl.base_url}api/MasterApp/AddTransportFeeApp'),
        headers: {'Content-Type': 'application/json'},
        body:    jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final apiResponse = ApiResponseModel.fromJson(jsonDecode(res.body));

        if (apiResponse.isSuccess) {
          final msg = apiResponse.popupMessage?.isNotEmpty == true
              ? apiResponse.popupMessage!
              : apiResponse.messages.isNotEmpty
              ? apiResponse.messages
              : 'Transport fee saved successfully';

          Get.snackbar('Success', msg,
              backgroundColor: Colors.green.shade100);
          _clearForm();
          if (selectedSession.value?.session != null) {
            await fetchViewListForSession(selectedSession.value!.session!);
          }
          DefaultTabController.of(context)?.animateTo(1);
        } else {
          final msg = apiResponse.popupMessage?.isNotEmpty == true
              ? apiResponse.popupMessage!
              : apiResponse.messages.isNotEmpty
              ? apiResponse.messages
              : 'Could not save transport fee';
          Get.snackbar('Failed', msg,
              backgroundColor: Colors.red.shade100);
        }
      } else {
        Get.snackbar('Error', 'Save failed (${res.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', 'Save error: $e');
    } finally {
      isSaving(false);
    }
  }

  // ── Clear form ────────────────────────────────────────────
  void _clearForm() {
    selectedFeeDuration.value =
    feeDurationList.isNotEmpty ? feeDurationList.first : null;
    selectedRoute.value         = null;
    selectedStoppage.value      = null;
    selectedTransportType.value = '';
    stoppageList.clear();
    amountController.clear();
  }
}