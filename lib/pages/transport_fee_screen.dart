import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model;
import '../models/add_route_model.dart' hide RouteData;
import '../models/activitystudentmodel.dart' hide Data;
import '../models/feedurationmodel.dart';
import '../models/routeno.dart';
import '../models/route_model_points.dart';
import '../controller/transport_fee_controller.dart';
import '../utils/app_snackbar.dart';

class TransportFeeScreen extends GetView<TransportFeeController> {
  const TransportFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Transport Fee',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: teal,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Add'),
              Tab(icon: Icon(Icons.view_list), text: 'View'),
            ],
          ),
        ),
        body: const _TabRefresher(
          child: TabBarView(
            children: [
              _AddTab(),
              _ViewTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// View tab (index 1) khulte hi list apne aap reload karta hai
// ══════════════════════════════════════════════════════════════
class _TabRefresher extends StatefulWidget {
  final Widget child;
  const _TabRefresher({required this.child});

  @override
  State<_TabRefresher> createState() => _TabRefresherState();
}

class _TabRefresherState extends State<_TabRefresher> {
  TabController? _tc;

  void _listener() {
    final tc = _tc;
    if (tc == null || tc.indexIsChanging) return;
    if (tc.index == 1) {
      final c = Get.find<TransportFeeController>();
      if (!c.isListLoading.value) c.refreshList();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tc = DefaultTabController.of(context);
    if (tc != _tc) {
      _tc?.removeListener(_listener);
      _tc = tc;
      _tc!.addListener(_listener);
    }
  }

  @override
  void dispose() {
    _tc?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ══════════════════════════════════════════════════════════════
// ADD TAB
// ══════════════════════════════════════════════════════════════
class _AddTab extends GetView<TransportFeeController> {
  const _AddTab();

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Transport Fee',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 16.h),
                  _sessionDropdown(),
                  SizedBox(height: 14.h),
                  _feeDurationDropdown(context),
                  SizedBox(height: 14.h),
                  _routeDropdown(),
                  SizedBox(height: 14.h),
                  _stoppageDropdown(),
                  SizedBox(height: 14.h),
                  _transportTypeDropdown(),
                  SizedBox(height: 14.h),
                  _amountField(),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 150.w,
                    height: 46.h,
                    child: Obx(
                          () => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () => controller.save(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isSaving.value
                              ? Colors.grey
                              : Colors.orange.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (controller.isPageLoading.value)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      );
    });
  }

  Widget _sessionDropdown() {
    return Obx(() {
      if (controller.isPageLoading.value && controller.sessionList.isEmpty) {
        return _loadingField('Session');
      }
      if (controller.sessionList.isEmpty) {
        return _disabledField('Session *', 'No sessions available');
      }
      return DropdownButtonFormField<session_model.sListDdata>(
        value: controller.selectedSession.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: const Text('Select Session'),
        items: controller.sessionList
            .map((s) => DropdownMenuItem<session_model.sListDdata>(
          value: s,
          child: Text(s.session ?? ''),
        ))
            .toList(),
        onChanged: (v) => controller.selectedSession.value = v,
        decoration: _inputDec('Session *'),
      );
    });
  }

  // ── Fee Duration: multi-select ────────────────────────────
  Widget _feeDurationDropdown(BuildContext context) {
    return Obx(() {
      if (controller.isPageLoading.value &&
          controller.feeDurationList.isEmpty) {
        return _loadingField('Fee Duration');
      }
      if (controller.feeDurationList.isEmpty) {
        return _disabledField('Fee Duration *', 'No fee durations available');
      }
      final selected = controller.selectedFeeDurations;
      return InkWell(
        onTap: () => _openFeeDurationPicker(context),
        child: InputDecorator(
          decoration: _inputDec('Fee Duration *'),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected.isEmpty
                      ? 'Select Fee Duration'
                      : selected.map((d) => d.feesDuration).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: selected.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );
    });
  }

  void _openFeeDurationPicker(BuildContext context) {
    final items = controller.feeDurationList.reversed.toList();
    final temp = <FeeDurationItem>[...controller.selectedFeeDurations];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final allChecked = items.isNotEmpty &&
              items.every((i) =>
                  temp.any((e) => e.feesDurationId == i.feesDurationId));
          return AlertDialog(
            title: const Text('Select Fee Duration'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  CheckboxListTile(
                    value: allChecked,
                    title: const Text('Select All',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => setState(() {
                      temp.clear();
                      if (v == true) temp.addAll(items);
                    }),
                  ),
                  const Divider(height: 1),
                  ...items.map((item) => CheckboxListTile(
                    value: temp.any(
                            (e) => e.feesDurationId == item.feesDurationId),
                    title: Text(item.feesDuration),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        temp.add(item);
                      } else {
                        temp.removeWhere((e) =>
                        e.feesDurationId == item.feesDurationId);
                      }
                    }),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // List ka order rakho, tap ka order nahi.
                  controller.selectedFeeDurations.assignAll(items.where((i) =>
                      temp.any((e) => e.feesDurationId == i.feesDurationId)));
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _routeDropdown() {
    return Obx(() {
      if (controller.isPageLoading.value && controller.routeList.isEmpty) {
        return _loadingField('Route No.');
      }
      if (controller.routeList.isEmpty) {
        return _disabledField('Route No. *', 'No routes available');
      }
      return DropdownButtonFormField<RouteData>(
        value: controller.selectedRoute.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: const Text('Select Route No.'),
        items: controller.routeList
            .map((r) => DropdownMenuItem<RouteData>(
          value: r,
          child: Text(
            'Route: ${r.routeNo}  |  Bus: ${r.busNo}',
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: controller.onRouteChanged,
        decoration: _inputDec('Route No. *'),
      );
    });
  }

  Widget _stoppageDropdown() {
    return Obx(() {
      if (controller.isStoppageLoading.value) {
        return _loadingField('Stoppage');
      }
      if (controller.selectedRoute.value == null) {
        return _disabledField('Stoppage *', 'Select route first');
      }
      if (controller.stoppageList.isEmpty) {
        return _disabledField('Stoppage *', 'No stoppages available');
      }
      return DropdownButtonFormField<Data>(
        value: controller.selectedStoppage.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: const Text('Select Stoppage'),
        items: controller.stoppageList
            .map((d) => DropdownMenuItem<Data>(
          value: d,
          child: Text(d.pickupPoint ?? ''),
        ))
            .toList(),
        onChanged: (v) => controller.selectedStoppage.value = v,
        decoration: _inputDec('Stoppage *'),
      );
    });
  }

  Widget _transportTypeDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedTransportType.value.isEmpty
            ? null
            : controller.selectedTransportType.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: const Text('Select Transport Type'),
        items: const [
          DropdownMenuItem(value: 'One Way', child: Text('One Way')),
          DropdownMenuItem(value: 'Two Way', child: Text('Two Way')),
        ],
        onChanged: (v) {
          if (v != null) controller.selectedTransportType.value = v;
        },
        decoration: _inputDec('Transport Type *'),
      );
    });
  }

  Widget _amountField() {
    return TextFormField(
      controller: controller.amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Amount *',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        prefixText: '₹ ',
      ),
    );
  }

  Widget _loadingField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700),
        ),
        SizedBox(height: 6.h),
        const LinearProgressIndicator(),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _disabledField(String label, String hint) {
    return IgnorePointer(
      child: DropdownButtonFormField<String>(
        value: null,
        items: const [],
        onChanged: null,
        hint: Text(
          hint,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// VIEW TAB
// ══════════════════════════════════════════════════════════════
class _ViewTab extends GetView<TransportFeeController> {
  const _ViewTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isListLoading.value;
      final empty = controller.viewList.isEmpty;

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transport Fee List',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: loading ? null : controller.refreshList,
                    icon: loading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (!empty)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          'Total: ${controller.viewList.length} records',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: (loading && empty)
                    ? const Center(child: CircularProgressIndicator())
                    : empty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus_outlined,
                          size: 52, color: Colors.grey.shade300),
                      SizedBox(height: 10.h),
                      Text(
                        'No records found',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Session: ${controller.selectedSession.value?.session ?? '-'}',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                )
                    : _buildTable(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTable() {
    return RefreshIndicator(
      onRefresh: controller.refreshList,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF3E0E8)),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: const Color(0xFF6E0F39),
            ),
            dataTextStyle: TextStyle(fontSize: 12.sp, color: Colors.black87),
            columnSpacing: 18,
            dividerThickness: 0.8,
            columns: const [
              DataColumn(label: Text('S.No')),
              DataColumn(label: Text('Fee Duration')),
              DataColumn(label: Text('Pickup Point')),
              DataColumn(label: Text('Transport Type')),
              DataColumn(label: Text('Amount'), numeric: true),
              DataColumn(label: Text('Fees Head')),
              DataColumn(label: Text('Edit')),
            ],
            rows: List.generate(
              controller.viewList.length,
                  (i) {
                final item = controller.viewList[i];
                final isEven = i % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                        (states) => isEven ? Colors.grey.shade50 : Colors.white,
                  ),
                  cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.feesDuration.isEmpty ? '-' : item.feesDuration,
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 140.w,
                        child: Text(
                          item.pickupPoint.isEmpty ? '-' : item.pickupPoint,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor(item.transportType)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _typeColor(item.transportType)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          item.transportType.isEmpty
                              ? '-'
                              : item.transportType,
                          style: TextStyle(
                            color: _typeColor(item.transportType),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.amount.isEmpty ? '-' : '₹ ${item.amount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    DataCell(Text(item.feesHead.isEmpty ? '-' : item.feesHead)),
                    DataCell(
                      IconButton(
                        tooltip: item.canEdit
                            ? 'Edit'
                            : 'Cannot edit: no record ID from the server',
                        icon: Icon(Icons.edit,
                            color: item.canEdit
                                ? const Color(0xFF97144D)
                                : Colors.grey.shade400),
                        onPressed: () {
                          if (!item.canEdit) {
                            AppSnackbar.error(
                              'The server did not send an ID for this record, so it cannot be edited yet.',
                              title: 'Cannot Edit',
                            );
                            return;
                          }
                          Get.dialog(_EditTransportFeeDialog(item: item),
                              barrierDismissible: false);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('one')) return Colors.blue.shade700;
    if (t.contains('two')) return Colors.orange.shade700;
    return Colors.grey.shade600;
  }
}

// ══════════════════════════════════════════════════════════════
// EDIT DIALOG — ek saved transport fee edit karta hai.
// Apni alag state use karta hai, Add tab ka form touch nahi hota.
// ══════════════════════════════════════════════════════════════
class _EditTransportFeeDialog extends StatefulWidget {
  final TFViewItem item;
  const _EditTransportFeeDialog({required this.item});

  @override
  State<_EditTransportFeeDialog> createState() =>
      _EditTransportFeeDialogState();
}

class _EditTransportFeeDialogState extends State<_EditTransportFeeDialog> {
  final c = Get.find<TransportFeeController>();
  late final TextEditingController amountCtrl;

  bool loading = true;
  bool stoppagesLoading = false;
  FeeDurationItem? duration;
  RouteData? route;
  List<Data> stoppages = [];
  Data? stoppage;
  String transportType = '';

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.item.amount);
    final t = widget.item.transportType.trim().toLowerCase();
    transportType =
    t.contains('two') ? 'Two Way' : (t.contains('one') ? 'One Way' : '');
    _load();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    duration = c.durationOf(widget.item);
    try {
      final found = await c.findRouteOf(widget.item);
      route = found.route;
      stoppages = found.stoppages;
      stoppage = found.stoppage;
    } catch (e, st) {
      // Route/stoppage khaali rahenge, user khud select karega.
      AppSnackbar.apiError(e, stackTrace: st);
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _onRouteChanged(RouteData? r) async {
    setState(() {
      route = r;
      stoppage = null;
      stoppages = [];
      stoppagesLoading = r != null;
    });
    if (r == null) return;
    List<Data> points = [];
    try {
      points = await c.loadStoppages(r.routeNo);
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    }
    // Purane route ka late jawab ignore karo.
    if (!mounted || route?.routeNo != r.routeNo) return;
    setState(() {
      stoppages = points;
      stoppagesLoading = false;
    });
  }

  Future<void> _save() async {
    String? error;
    final amt = amountCtrl.text.trim();
    if (duration == null) {
      error = 'Please select Fee Duration';
    } else if (route == null) {
      error = 'Please select Route No.';
    } else if (stoppage == null) {
      error = 'Please select Stoppage';
    } else if (transportType.isEmpty) {
      error = 'Please select Transport Type';
    } else if ((int.tryParse(amt) ?? 0) <= 0) {
      error = 'Amount must be greater than 0';
    }
    if (error != null) {
      AppSnackbar.error(error, title: 'Validation');
      return;
    }

    final ok = await c.updateFee(
      item: widget.item,
      route: route!,
      stoppage: stoppage!,
      duration: duration!,
      transportType: transportType,
      amount: amt,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    // Dropdown ki value list ke same object honi chahiye.
    final durationValue = duration == null
        ? null
        : c.feeDurationList.firstWhereOrNull(
            (d) => d.feesDurationId == duration!.feesDurationId);
    final routeValue = route == null
        ? null
        : c.routeList.firstWhereOrNull((r) => r.routeNo == route!.routeNo);
    final stoppageValue = stoppage == null
        ? null
        : stoppages
        .firstWhereOrNull((s) => s.routePointId == stoppage!.routePointId);

    return AlertDialog(
      title: const Text('Edit Transport Fee'),
      content: SizedBox(
        width: double.maxFinite,
        child: loading
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        )
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputDecorator(
                decoration: _dec('Session'),
                child: Text(widget.item.session.isEmpty
                    ? '-'
                    : widget.item.session),
              ),
              SizedBox(height: 14.h),
              DropdownButtonFormField<FeeDurationItem>(
                value: durationValue,
                isExpanded: true,
                menuMaxHeight: 300,
                hint: const Text('Select Fee Duration'),
                items: c.feeDurationList.reversed
                    .map((d) => DropdownMenuItem<FeeDurationItem>(
                    value: d, child: Text(d.feesDuration)))
                    .toList(),
                onChanged: (v) => setState(() => duration = v),
                decoration: _dec('Fee Duration *'),
              ),
              SizedBox(height: 14.h),
              DropdownButtonFormField<RouteData>(
                value: routeValue,
                isExpanded: true,
                menuMaxHeight: 300,
                hint: const Text('Select Route No.'),
                items: c.routeList
                    .map((r) => DropdownMenuItem<RouteData>(
                  value: r,
                  child: Text(
                    'Route: ${r.routeNo}  |  Bus: ${r.busNo}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
                    .toList(),
                onChanged: _onRouteChanged,
                decoration: _dec('Route No. *'),
              ),
              SizedBox(height: 14.h),
              if (stoppagesLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<Data>(
                  value: stoppageValue,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  hint: Text(route == null
                      ? 'Select route first'
                      : stoppages.isEmpty
                      ? 'No stoppages available'
                      : 'Select Stoppage'),
                  items: stoppages
                      .map((d) => DropdownMenuItem<Data>(
                      value: d, child: Text(d.pickupPoint ?? '')))
                      .toList(),
                  onChanged: stoppages.isEmpty
                      ? null
                      : (v) => setState(() => stoppage = v),
                  decoration: _dec('Stoppage *'),
                ),
              SizedBox(height: 14.h),
              DropdownButtonFormField<String>(
                value: transportType.isEmpty ? null : transportType,
                isExpanded: true,
                hint: const Text('Select Transport Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'One Way', child: Text('One Way')),
                  DropdownMenuItem(
                      value: 'Two Way', child: Text('Two Way')),
                ],
                onChanged: (v) =>
                    setState(() => transportType = v ?? ''),
                decoration: _dec('Transport Type *'),
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dec('Amount *').copyWith(prefixText: '₹ '),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Obx(() => TextButton(
          onPressed:
          c.isSaving.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        )),
        Obx(() => ElevatedButton(
          onPressed: loading || c.isSaving.value ? null : _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700),
          child: c.isSaving.value
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
              : const Text('Update',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        )),
      ],
    );
  }
}