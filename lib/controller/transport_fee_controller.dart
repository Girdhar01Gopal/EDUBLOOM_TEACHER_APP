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
import '../utils/app_snackbar.dart';

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

  /// Agar server id 0 bheje to update naya record bana dega,
  /// isliye edit sirf id > 0 par allowed hai.
  bool get canEdit => transFeeHeadId > 0;

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

  static const String _addTransportFeeUrlPath =
      'api/MasterApp/AddTransportFeeApp';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };
  static const Duration _timeout = Duration(seconds: 30);
  static const String _generic = 'Something went wrong. Please try again.';

  // ── Session ──────────────────────────────────────────────
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ── Fee Duration (multi-select) ──────────────────────────
  final feeDurationList = <FeeDurationItem>[].obs;
  final selectedFeeDurations = <FeeDurationItem>[].obs;

  // ── Route ─────────────────────────────────────────────────
  final routeList = <RouteData>[].obs;
  final selectedRoute = Rx<RouteData?>(null);

  // ── Stoppage ──────────────────────────────────────────────
  final stoppageList = <Data>[].obs;
  final selectedStoppage = Rx<Data?>(null);

  // ── Transport Type ────────────────────────────────────────
  final selectedTransportType = RxString('');

  // ── Amount ───────────────────────────────────────────────
  final amountController = TextEditingController();

  // ── View List ────────────────────────────────────────────
  final viewList = <TFViewItem>[].obs;

  // ── Loaders ──────────────────────────────────────────────
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isListLoading = false.obs;
  final isStoppageLoading = false.obs;

  int _listRequestId = 0;

  // Page load ke time kai API ek saath chalti hain. Us waqt har fail par
  // alag snackbar nahi dikhate, sab khatam hone ke baad sirf ek dikhate hain.
  bool _batch = false;
  bool _batchFailed = false;
  Object? _batchError;
  int? _batchStatus;
  StackTrace? _batchStack;

  // ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error('School ID not found');
      return;
    }
    await _loadAll();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  // ── HTTP helper (timeout ke saath) ───────────────────────
  Future<http.Response> _get(String url) =>
      http.get(Uri.parse(url), headers: _headers).timeout(_timeout);

  /// Load wali API ka error: batch chal raha ho to ruk kar ek baar dikhao,
  /// warna turant dikhao. [silent] true ho to sirf console mein print hota hai.
  void _reportError(
      Object? error, {
        int? statusCode,
        StackTrace? stackTrace,
        bool silent = false,
      }) {
    if (_batch) {
      if (!_batchFailed) {
        _batchFailed = true;
        _batchError = error;
        _batchStatus = statusCode;
        _batchStack = stackTrace;
      }
      return;
    }
    if (silent) {
      debugPrint('TransportFee silent error ($statusCode): $error');
      return;
    }
    AppSnackbar.apiError(error, statusCode: statusCode, stackTrace: stackTrace);
  }

  Future<void> _loadAll() async {
    _batch = true;
    _batchFailed = false;
    _batchError = null;
    _batchStatus = null;
    _batchStack = null;
    try {
      isPageLoading(true);

      // Pehle session (list ko session chahiye), baaki parallel.
      await fetchSessions();
      await Future.wait([
        fetchFeeDurations(),
        fetchRoutes(),
        fetchViewList(),
      ]);
    } finally {
      isPageLoading(false);
      _batch = false;
    }

    // Agar kisi bhi API ne fail kiya to sirf ek snackbar.
    if (_batchFailed) {
      AppSnackbar.apiError(
        _batchError,
        statusCode: _batchStatus,
        stackTrace: _batchStack,
      );
    }

    // Session badalne par list apne aap reload ho (initial load ke baad).
    ever<session_model.sListDdata?>(selectedSession, (_) {
      viewList.clear();
      fetchViewList();
    });
  }

  // ── 1. Sessions ───────────────────────────────────────────
  Future<void> fetchSessions() async {
    try {
      final res = await _get(
          '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId');

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }

        if (jsonData['listData'] != null) {
          for (final e in (jsonData['listData'] as List)) {
            final s = session_model.sListDdata(
              sessionId: e['sessionId'],
              session: e['session'],
              action: e['action'],
              schoolId: e['schoolId'],
            );
            if (!sessionList.any((x) => x.sessionId == s.sessionId)) {
              sessionList.add(s);
            }
          }
        }

        selectedSession.value ??=
        sessionList.isNotEmpty ? sessionList.first : null;
      } else {
        _reportError('Session API failed: ${res.statusCode}',
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      _reportError(e, stackTrace: s);
    }
  }

  // ── 2. Fee Durations ──────────────────────────────────────
  Future<void> fetchFeeDurations() async {
    try {
      final res = await _get(
          '${AppUrl.base_url}api/FeeMasterApp/ViewFeesDurationApp/$schoolId');

      if (res.statusCode == 200) {
        final parsed = FeeDurationMaster.fromJson(jsonDecode(res.body));
        feeDurationList.assignAll(parsed.listData);
        selectedFeeDurations.clear();
      } else {
        _reportError('Fee Duration API failed: ${res.statusCode}',
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      _reportError(e, stackTrace: s);
    }
  }

  // ── 3. Routes ─────────────────────────────────────────────
  Future<void> fetchRoutes() async {
    try {
      final res = await _get(
          '${AppUrl.base_url}api/StudentApp/GetRouteApp/$schoolId');

      if (res.statusCode == 200) {
        final parsed = RouteResponse.fromJson(jsonDecode(res.body));
        routeList.assignAll(parsed.data);
      } else {
        _reportError('Route API failed: ${res.statusCode}',
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      _reportError(e, stackTrace: s);
    }
  }

  // ── Route changed → fetch stoppages ──────────────────────
  void onRouteChanged(RouteData? route) {
    selectedRoute.value = route;
    selectedStoppage.value = null;
    stoppageList.clear();
    if (route != null) fetchStoppages(route.routeNo);
  }

  // ── 4. Stoppages ──────────────────────────────────────────
  Future<void> fetchStoppages(int routeNo) async {
    try {
      isStoppageLoading(true);
      final points = await loadStoppages(routeNo);
      // Late answer ignore karo agar route badal chuka ho.
      if (selectedRoute.value?.routeNo != routeNo) return;
      stoppageList.assignAll(points);
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isStoppageLoading(false);
    }
  }

  // ── 5. View List (single method) ─────────────────────────
  /// [session] na do to selected session use hoti hai.
  /// [silent] true ho to fail hone par snackbar nahi aata (sirf console).
  Future<void> fetchViewList({String? session, bool silent = false}) async {
    final s = (session ?? selectedSession.value?.session ?? '').trim();
    if (s.isEmpty || schoolId.trim().isEmpty) return;

    final reqId = ++_listRequestId;
    try {
      isListLoading(true);

      final res = await _get(
          '${AppUrl.base_url}api/MasterApp/GetTransportFeeHeadAppAsync/$schoolId/$s');

      // Purana jawab ignore karo.
      if (reqId != _listRequestId) return;

      if (res.statusCode == 200) {
        final parsed = TransportFeeResponse.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess) {
          viewList.assignAll(
            parsed.data.map((tf) => TFViewItem.fromTransportFee(tf)).toList(),
          );
        } else {
          viewList.clear();
        }
      } else {
        _reportError('View list API failed: ${res.statusCode}',
            statusCode: res.statusCode, silent: silent);
      }
    } catch (e, st) {
      if (reqId == _listRequestId) {
        _reportError(e, stackTrace: st, silent: silent);
      }
    } finally {
      if (reqId == _listRequestId) isListLoading(false);
    }
  }

  /// View tab khulte hi / refresh par call hota hai.
  Future<void> refreshList() => fetchViewList();

  // ── 6. Save (multi fee duration) — admin jaisa ───────────
  Future<void> save(BuildContext context) async {
    if (selectedSession.value == null) {
      AppSnackbar.error('Please select Session', title: 'Validation');
      return;
    }
    if (selectedFeeDurations.isEmpty) {
      AppSnackbar.error('Please select Fee Duration', title: 'Validation');
      return;
    }
    if (selectedRoute.value == null) {
      AppSnackbar.error('Please select Route No.', title: 'Validation');
      return;
    }
    if (selectedStoppage.value == null) {
      AppSnackbar.error('Please select Stoppage', title: 'Validation');
      return;
    }
    final transportType = selectedTransportType.value.trim();
    if (transportType.isEmpty) {
      AppSnackbar.error('Please select Transport Type', title: 'Validation');
      return;
    }
    final amtText = amountController.text.trim();
    if (amtText.isEmpty) {
      AppSnackbar.error('Please enter Amount', title: 'Validation');
      return;
    }
    final amount = int.tryParse(amtText) ?? 0;
    if (amount <= 0) {
      AppSnackbar.error('Amount must be greater than 0', title: 'Validation');
      return;
    }

    try {
      isSaving(true);

      // API ek request mein ek duration leti hai — har selected duration save karo.
      int ok = 0;
      final failed = <String>[];
      String? firstError;
      String? lastSuccessMsg;

      for (final duration in selectedFeeDurations.toList()) {
        final now = DateTime.now().toUtc().toIso8601String();
        final body = {
          'transFeeHeadId': 0,
          'session': selectedSession.value!.session ?? '',
          'routeNo': selectedRoute.value!.routeNo,
          'routeNameId': selectedRoute.value!.routeNameId,
          'routePointId': selectedStoppage.value!.routePointId ?? 0,
          'feesDurationId': duration.feesDurationId,
          'feesHead': 'Transport Fee',
          'amount': amtText,
          'action': '1',
          'createDate': now,
          'updateDate': now,
          'createBy': 'Admin',
          'updateBy': 'Admin',
          'schoolId': schoolId,
          'feeTypeId': 0,
          'transportType': transportType,
        };

        try {
          final res = await http.post(
            Uri.parse('${AppUrl.base_url}$_addTransportFeeUrlPath'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          if (res.statusCode != 200) {
            debugPrint(
                'TransportFee save failed: ${res.statusCode} | ${res.body}');
          }
          final apiResponse = res.statusCode == 200
              ? ApiResponseModel.fromJson(jsonDecode(res.body))
              : null;
          final msg = apiResponse == null
              ? null
              : apiResponse.popupMessage?.isNotEmpty == true
              ? apiResponse.popupMessage!
              : apiResponse.messages;

          if (apiResponse != null && apiResponse.isSuccess) {
            ok++;
            if ((msg ?? '').isNotEmpty) lastSuccessMsg = msg;
          } else {
            failed.add(duration.feesDuration);
            firstError ??= (msg ?? '').isNotEmpty ? msg : _generic;
          }
        } catch (e) {
          debugPrint('TransportFee save error: $e');
          failed.add(duration.feesDuration);
          firstError ??= _generic;
        }
      }

      if (failed.isEmpty) {
        AppSnackbar.success(selectedFeeDurations.length == 1
            ? (lastSuccessMsg ?? 'Transport fee saved successfully')
            : 'Transport fee saved for $ok fee durations');
      } else if (ok > 0) {
        AppSnackbar.error(
            'Saved: $ok  |  Not saved: ${failed.join(", ")}\n$firstError',
            title: 'Partially Saved');
      } else {
        AppSnackbar.error(firstError ?? 'Could not save transport fee',
            title: 'Failed');
      }

      if (ok > 0) {
        if (failed.isEmpty) {
          _clearForm();
        } else {
          // Sirf wahi durations rakho jo abhi save nahi hue.
          selectedFeeDurations
              .retainWhere((d) => failed.contains(d.feesDuration));
        }
        // View list refresh (silent taaki Success snackbar na dabe).
        if (selectedSession.value?.session != null) {
          await fetchViewList(
              session: selectedSession.value!.session!, silent: true);
        }
        if (failed.isEmpty && context.mounted) {
          DefaultTabController.of(context).animateTo(1);
        }
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isSaving(false);
    }
  }

  // ── 7. Edit helpers ───────────────────────────────────────

  /// Kisi route ke stoppages (Add tab ki state ko touch nahi karta).
  /// Fail hone par exception throw karta hai, caller snackbar dikhata hai.
  Future<List<Data>> loadStoppages(int routeNo) async {
    final res = await _get(
        '${AppUrl.base_url}api/StudentApp/GetPikPointApp/$schoolId/$routeNo');
    if (res.statusCode != 200) {
      throw Exception('Stoppage API failed: ${res.statusCode}');
    }
    final parsed = RoutePoint.fromJson(jsonDecode(res.body));
    return (parsed.data ?? [])
        .where((d) => (d.pickupPoint ?? '').trim().isNotEmpty)
        .toList();
  }

  /// List API route nahi deti, sirf routePointId. Isliye routes ke
  /// stoppages mein dhundh kar route nikalte hain.
  Future<({RouteData? route, List<Data> stoppages, Data? stoppage})>
  findRouteOf(TFViewItem item) async {
    if (routeList.isEmpty) await fetchRoutes();

    final knownRoute = int.tryParse('${item.routeNo ?? ''}');
    final candidates = knownRoute != null
        ? routeList.where((r) => r.routeNo == knownRoute).toList()
        : routeList.toList();

    int loadFailures = 0;
    Object? firstLoadError;

    final results = await Future.wait(candidates.map((r) async {
      try {
        return (route: r, points: await loadStoppages(r.routeNo));
      } catch (e) {
        loadFailures++;
        firstLoadError ??= e;
        return (route: r, points: <Data>[]);
      }
    }));

    for (final r in results) {
      for (final p in r.points) {
        if (p.routePointId == item.routePointId) {
          return (route: r.route, stoppages: r.points, stoppage: p);
        }
      }
    }

    // Saare routes ke stoppages load fail hue (net band etc.) → ek snackbar.
    if (candidates.isNotEmpty && loadFailures == candidates.length) {
      AppSnackbar.apiError(firstLoadError);
    }
    return (route: null, stoppages: <Data>[], stoppage: null);
  }

  /// List row ka fee duration (naam se match).
  FeeDurationItem? durationOf(TFViewItem item) {
    final name = item.feesDuration.trim().toLowerCase();
    for (final d in feeDurationList) {
      if (d.feesDuration.trim().toLowerCase() == name) return d;
    }
    return null;
  }

  /// Existing fee update — admin jaisa. transFeeHeadId = existing id => update.
  Future<bool> updateFee({
    required TFViewItem item,
    required RouteData route,
    required Data stoppage,
    required FeeDurationItem duration,
    required String transportType,
    required String amount,
  }) async {
    if (!item.canEdit) {
      AppSnackbar.error('This record has no ID from the server.',
          title: 'Cannot Edit');
      return false;
    }
    try {
      isSaving(true);
      final body = {
        'transFeeHeadId': item.transFeeHeadId,
        'session': item.session,
        'routeNo': route.routeNo,
        'routeNameId': route.routeNameId,
        'routePointId': stoppage.routePointId ?? 0,
        'feesDurationId': duration.feesDurationId,
        'feesHead': item.feesHead.isEmpty ? 'Transport Fee' : item.feesHead,
        'amount': amount,
        'action': '1',
        'createDate': item.createDate.toUtc().toIso8601String(),
        'updateDate': DateTime.now().toUtc().toIso8601String(),
        'createBy': item.createBy.isEmpty ? 'Admin' : item.createBy,
        'updateBy': 'Admin',
        'schoolId': schoolId,
        'feeTypeId': item.feeTypeId,
        'transportType': transportType,
      };

      final res = await http.post(
        Uri.parse('${AppUrl.base_url}$_addTransportFeeUrlPath'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode != 200) {
        debugPrint(
            'TransportFee update failed: ${res.statusCode} | ${res.body}');
      }
      final apiResponse = res.statusCode == 200
          ? ApiResponseModel.fromJson(jsonDecode(res.body))
          : null;
      final msg = apiResponse == null
          ? null
          : apiResponse.popupMessage?.isNotEmpty == true
          ? apiResponse.popupMessage!
          : apiResponse.messages;

      if (apiResponse != null && apiResponse.isSuccess) {
        AppSnackbar.success('Transport fee updated successfully');
        await fetchViewList(session: item.session, silent: true);
        return true;
      }
      AppSnackbar.error(
          (msg ?? '').isNotEmpty ? msg! : 'Could not update transport fee',
          title: 'Failed');
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isSaving(false);
    }
    return false;
  }

  // ── Clear form ────────────────────────────────────────────
  void _clearForm() {
    selectedFeeDurations.clear();
    selectedRoute.value = null;
    selectedStoppage.value = null;
    selectedTransportType.value = '';
    stoppageList.clear();
    amountController.clear();
  }
}