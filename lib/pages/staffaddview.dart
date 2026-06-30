import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/addstaffcontroller.dart';
import '../models/staff_details_model15.dart';

class Staffaddview extends GetView<Addstaffcontroller> {
  const Staffaddview({super.key});

  @override
  Widget build(BuildContext context) {
    final Addstaffcontroller controller = Get.put(Addstaffcontroller());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          title: const Text(
            'Staff Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person_add, color: Colors.white), text: "Add Staff"),
              Tab(icon: Icon(Icons.view_list, color: Colors.white), text: "View Staff"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddTeacherTab(),
            ViewTeacherTab(),
          ],
        ),
      ),
    );
  }
}

// ── Add Staff Tab ─────────────────────────────────────────────────────────────
class AddTeacherTab extends GetView<Addstaffcontroller> {
  const AddTeacherTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.resetForm();
        await controller.fetchDesignations();
        await Future.delayed(const Duration(milliseconds: 200));
      },
      child: Form(
        key: controller.formKey,
        child: LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            final cols = width >= 1100 ? 3 : (width >= 800 ? 2 : 1);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            controller.isEditMode ? 'Edit Staff' : 'Add New Staff',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          )),
                          const SizedBox(height: 16),

                          _Grid(columns: cols, children: [
                            _TextFieldBlock(label: 'Staff Name *', controller: controller.teacherNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, 'Staff Name')),
                            _ReadOnlyFieldBlock(label: 'Staff ID', controller: controller.teacherIdC),
                            _TextFieldBlock(label: "Father/Husband's Name *", controller: controller.fatherHusbandNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, "Father/Husband's Name")),
                            _DateFieldBlock(label: 'Date Of Birth *', controller: controller.dobC, onPick: () => controller.pickDate(controller: controller.dobC, firstDate: DateTime(1950), lastDate: DateTime.now()), validator: (v) => controller.requiredValidator(v, 'Date Of Birth')),
                            _DropdownBlock(label: 'Blood Group *', valueRx: controller.bloodGroup, itemsBuilder: () => controller.bloodGroups, hint: 'Select Blood Group'),
                            _DropdownBlock(label: 'Gender *', valueRx: controller.gender, itemsBuilder: () => controller.genders, hint: 'Select Gender'),
                            _DropdownBlock(label: 'Caste *', valueRx: controller.caste, itemsBuilder: () => controller.castes, hint: 'Select Caste'),
                            _TextFieldBlock(label: 'E-Mail ', controller: controller.emailC, keyboardType: TextInputType.emailAddress, validator: controller.emailValidator, hint: 'Enter email'),
                            _TextFieldBlock(label: 'Mobile No *', controller: controller.mobileC, keyboardType: TextInputType.phone, validator: controller.mobileValidator, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
                            _DropdownBlock(label: 'Staff Type *', valueRx: controller.designation, itemsBuilder: () => controller.designationNames, hint: 'Select Staff Type', isLoadingRx: controller.isDesignationLoading),
                            _TextFieldBlock(label: 'License No', controller: controller.salaryC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'License No'), inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                            _TextFieldBlock(label: 'State *', controller: controller.stateC, validator: (v) => controller.requiredValidator(v, 'State'), hint: 'Enter state', textCapitalization: TextCapitalization.words),
                            _TextFieldBlock(label: 'City *', controller: controller.cityC, validator: (v) => controller.requiredValidator(v, 'City'), textCapitalization: TextCapitalization.words),
                            _DateFieldBlock(label: 'Date Of Joining *', controller: controller.joiningDateC, onPick: () => controller.pickDate(controller: controller.joiningDateC, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650))), validator: (v) => controller.requiredValidator(v, 'Date Of Joining')),
                            _TextFieldBlock(label: 'Address *', controller: controller.addressC, validator: (v) => controller.requiredValidator(v, 'Address'), hint: 'Enter address', maxLines: 2, textCapitalization: TextCapitalization.sentences),
                          ]),

                          const SizedBox(height: 18),
                          _Grid(columns: cols == 1 ? 1 : 2, children: [
                            _fileCol('Upload Staff Photo', controller.userPic, controller),
                            _fileCol('Upload ID Proof', controller.idProofPhoto, controller),
                          ]),
                          const SizedBox(height: 18),
                          _Grid(columns: cols == 1 ? 1 : 2, children: [
                            _fileCol('Upload License Photo', controller.resumePhoto, controller),
                          ]),
                          const SizedBox(height: 22),

                          Row(children: [
                            Expanded(
                              child: Obx(() => ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.amber.shade700,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: controller.isSubmitting.value
                                    ? null
                                    : () => controller.submit(idForUpdate: controller.editingId.value),
                                icon: controller.isSubmitting.value
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save, color: Colors.white),
                                label: Text(
                                  controller.isSubmitting.value ? 'Saving...' : controller.isEditMode ? 'Update' : 'Save',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              )),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
                              onPressed: controller.resetForm,
                              child: const Text('Clear'),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _fileCol(String title, Rxn<PlatformFile> rx, Addstaffcontroller ctrl) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(title),
      const SizedBox(height: 8),
      _FilePickerField(
        hint: 'Choose here',
        fileRx: rx,
        onPick: () => ctrl.pickFile(rx),
        onClear: () => ctrl.clearFile(rx),
      ),
    ],
  );
}

// ── View Staff Tab ─────────────────────────────────────────────────────────────
class ViewTeacherTab extends GetView<Addstaffcontroller> {
  const ViewTeacherTab({super.key});

  void _openEditDialog(BuildContext context, Addstaffcontroller ctrl, StaffDetail15Data teacher) {
    ctrl.fillTeacherForDialogEdit(teacher);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - 48,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.teal.shade500, Colors.teal.shade800]),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text("Edit Staff Details",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        IconButton(
                          onPressed: () { ctrl.resetForm(); Navigator.pop(context); },
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Form
                  Expanded(
                    child: Form(
                      key: ctrl.dialogFormKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _EditTeacherDialogForm(controller: ctrl),
                      ),
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () { ctrl.resetForm(); Navigator.pop(context); },
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Obx(() => ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: ctrl.isSubmitting.value ? null : () async => await ctrl.updateTeacherFromDialog(),
                            icon: ctrl.isSubmitting.value
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_outlined),
                            label: Text(ctrl.isSubmitting.value ? "Updating..." : "Update Staff"),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("All Staff Data",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Obx(() => IconButton(
                        onPressed: controller.isTeacherLoading.value ? null : () async => await controller.fetchTeachers(),
                        icon: controller.isTeacherLoading.value
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh),
                      )),
                    ],
                  ),
                  const Divider(height: 18),
                  SizedBox(
                    height: 44,
                    child: TextField(
                      controller: controller.teacherSearchC,
                      decoration: InputDecoration(
                        hintText: "Search name / staff id / mobile",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    if (controller.isTeacherLoading.value) {
                      return const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator()));
                    }

                    final list = controller.filteredTeachers;
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(18),
                        child: Center(child: Text("No staff found", style: TextStyle(color: Colors.grey.shade700))),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 44,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 56,
                        columnSpacing: 22,
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                        columns: const [
                          DataColumn(label: Text("S.No")),
                          DataColumn(label: Text("Staff Id")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Father Name")),
                          DataColumn(label: Text("Mobile No")),
                          DataColumn(label: Text("Joining Date")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Update Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final t = list[i];
                          return DataRow(cells: [
                            DataCell(Text("${i + 1}")),
                            DataCell(Text(t.staffReg ?? "-")),
                            DataCell(Text(t.name ?? "-")),
                            DataCell(Text(t.fhname ?? "-")),
                            DataCell(Text(t.mobileNo ?? "-")),
                            DataCell(Text(controller.formatDateFromDateTime(t.dateofJoining))),
                            DataCell(Text(controller.formatDateFromDateTime(t.createDate))),
                            DataCell(Text(controller.formatDateFromDateTime(t.updateDate))),
                            DataCell(_ActionButtons(
                              onEdit: () => _openEditDialog(context, controller, t),
                              onView: () => controller.onTeacherView(t),   // ← eye icon
                              onApprove: () => controller.onTeacherApprove(t),
                            )),
                          ]);
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Action Buttons: Edit (orange) + View (teal) ───────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onApprove;

  const _ActionButtons({
    required this.onEdit,
    required this.onView,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn({
      required Color bg,
      required IconData icon,
      required VoidCallback onTap,
      required String tooltip,
    }) {
      return Tooltip(
        message: tooltip,
        child: SizedBox(
          height: 34,
          width: 38,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: bg,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: onTap,
            child: Icon(icon, size: 18),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(bg: Colors.orange, icon: Icons.edit, onTap: onEdit, tooltip: 'Edit'),
        const SizedBox(width: 6),
        btn(bg: Colors.teal.shade600, icon: Icons.visibility, onTap: onView, tooltip: 'View Details'),
      ],
    );
  }
}

// ── Edit Dialog Form ───────────────────────────────────────────────────────────
class _EditTeacherDialogForm extends StatelessWidget {
  final Addstaffcontroller controller;
  const _EditTeacherDialogForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final cols = width >= 1100 ? 3 : (width >= 800 ? 2 : 1);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Grid(columns: cols, children: [
              _TextFieldBlock(label: 'Staff Name *', controller: controller.teacherNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, 'Staff Name')),
              _ReadOnlyFieldBlock(label: 'Staff ID', controller: controller.teacherIdC),
              _TextFieldBlock(label: "Father/Husband's Name *", controller: controller.fatherHusbandNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, "Father/Husband's Name")),
              _DateFieldBlock(label: 'Date Of Birth *', controller: controller.dobC, onPick: () => controller.pickDate(controller: controller.dobC, firstDate: DateTime(1950), lastDate: DateTime.now()), validator: (v) => controller.requiredValidator(v, 'Date Of Birth')),
              _DropdownBlock(label: 'Blood Group *', valueRx: controller.bloodGroup, itemsBuilder: () => controller.bloodGroups, hint: 'Select Blood Group'),
              _DropdownBlock(label: 'Gender *', valueRx: controller.gender, itemsBuilder: () => controller.genders, hint: 'Select Gender'),
              _DropdownBlock(label: 'Caste *', valueRx: controller.caste, itemsBuilder: () => controller.castes, hint: 'Select Caste'),
              _TextFieldBlock(label: 'E-Mail ', controller: controller.emailC, keyboardType: TextInputType.emailAddress, validator: controller.emailValidator, hint: 'Enter email'),
              _TextFieldBlock(label: 'Mobile No *', controller: controller.mobileC, keyboardType: TextInputType.phone, validator: controller.mobileValidator, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              _DropdownBlock(label: 'Staff Type *', valueRx: controller.designation, itemsBuilder: () => controller.designationNames, hint: 'Select Staff Type', isLoadingRx: controller.isDesignationLoading),
              _TextFieldBlock(label: 'License No', controller: controller.salaryC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'License No'), inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              _TextFieldBlock(label: 'State *', controller: controller.stateC, validator: (v) => controller.requiredValidator(v, 'State'), hint: 'Enter state', textCapitalization: TextCapitalization.words),
              _TextFieldBlock(label: 'City *', controller: controller.cityC, validator: (v) => controller.requiredValidator(v, 'City'), textCapitalization: TextCapitalization.words),
              _DateFieldBlock(label: 'Date Of Joining *', controller: controller.joiningDateC, onPick: () => controller.pickDate(controller: controller.joiningDateC, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650))), validator: (v) => controller.requiredValidator(v, 'Date Of Joining')),
              _TextFieldBlock(label: 'Address *', controller: controller.addressC, validator: (v) => controller.requiredValidator(v, 'Address'), hint: 'Enter address', maxLines: 2, textCapitalization: TextCapitalization.sentences),
            ]),
            const SizedBox(height: 18),
            _Grid(columns: cols == 1 ? 1 : 2, children: [
              _fileCol('Upload Staff Photo', controller.userPic, controller),
              _fileCol('Upload ID Proof', controller.idProofPhoto, controller),
            ]),
            const SizedBox(height: 18),
            _Grid(columns: cols == 1 ? 1 : 2, children: [
              _fileCol('Upload License Photo', controller.resumePhoto, controller),
            ]),
          ],
        );
      },
    );
  }
}

// ── Shared UI Widgets ──────────────────────────────────────────────────────────

class _Grid extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  const _Grid({required this.columns, required this.children});

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return Column(
        children: children.map((e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: e)).toList(),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = children.skip(i).take(columns).toList();
      while (rowChildren.length < columns) rowChildren.add(const SizedBox());
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(rowChildren.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == rowChildren.length - 1 ? 0 : 16),
                child: rowChildren[index],
              ),
            );
          }),
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _FieldShell extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldShell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    counterText: '',
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
  );
}

class _TextFieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hint;
  final int? maxLength;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _TextFieldBlock({
    required this.label, required this.controller,
    this.keyboardType, this.validator, this.hint, this.maxLength,
    this.maxLines = 1, this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        decoration: _inputDecoration(hint: hint),
      ),
    );
  }
}

class _ReadOnlyFieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _ReadOnlyFieldBlock({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _FieldShell(label: label, child: TextFormField(controller: controller, readOnly: true, decoration: _inputDecoration()));
  }
}

class _DateFieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onPick;
  final String? Function(String?)? validator;
  const _DateFieldBlock({required this.label, required this.controller, required this.onPick, this.validator});

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: validator,
        onTap: onPick,
        decoration: _inputDecoration().copyWith(suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: onPick)),
      ),
    );
  }
}

class _DropdownBlock extends StatelessWidget {
  final String label;
  final RxnString valueRx;
  final List<String> Function() itemsBuilder;
  final String hint;
  final RxBool? isLoadingRx;
  const _DropdownBlock({required this.label, required this.valueRx, required this.itemsBuilder, required this.hint, this.isLoadingRx});

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: Obx(() {
        final items = itemsBuilder().map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
        final loading = isLoadingRx?.value ?? false;
        String? sel = valueRx.value?.trim();
        if (sel != null && sel.isNotEmpty) {
          final matched = items.where((e) => e.toLowerCase() == sel!.toLowerCase()).toList();
          sel = matched.length == 1 ? matched.first : null;
        } else {
          sel = null;
        }
        return DropdownButtonFormField<String>(
          value: sel,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: loading ? null : (v) => valueRx.value = v,
          validator: (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
          decoration: _inputDecoration(hint: loading ? "Loading..." : hint).copyWith(
            suffixIcon: loading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null,
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87));
  }
}

class _FilePickerField extends StatelessWidget {
  final String hint;
  final Rxn<PlatformFile> fileRx;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _FilePickerField({required this.hint, required this.fileRx, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = fileRx.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                file?.name ?? hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: file == null ? Colors.grey.shade600 : Colors.black87),
              ),
            ),
            if (file != null) IconButton(onPressed: onClear, icon: const Icon(Icons.close, color: Colors.red)),
            ElevatedButton(onPressed: onPick, child: const Text('Browse')),
          ],
        ),
      );
    });
  }
}