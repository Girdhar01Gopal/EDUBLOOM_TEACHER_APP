import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../controller/teacher_add_controller.dart';
import '../models/teacher list model.dart';

class AddTeacherView extends GetView<TeacherAddController> {
  const AddTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TeacherAddController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF97144D),
          foregroundColor: Colors.white,
          title: const Text(
            '📚 Teacher Management',
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
              Tab(icon: Icon(Icons.person_add, color: Colors.white), text: "Add Teacher"),
              Tab(icon: Icon(Icons.view_list, color: Colors.white), text: "View Teacher"),
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

// ── Add Teacher Tab ─────────────────────────────────────────────────────────
class AddTeacherTab extends GetView<TeacherAddController> {
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
                            controller.isEditMode ? 'Edit Teacher' : 'Add New Teacher',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          )),
                          const SizedBox(height: 16),

                          _Grid(columns: cols, children: [
                            _TextFieldBlock(label: 'Teacher Name *', controller: controller.teacherNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, 'Teacher Name')),
                            _ReadOnlyFieldBlock(label: 'Teacher ID', controller: controller.teacherIdC),
                            _TextFieldBlock(label: "Father/Husband's Name *", controller: controller.fatherHusbandNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, "Father/Husband's Name")),
                            _DateFieldBlock(label: 'Date Of Birth *', controller: controller.dobC, onPick: () => controller.pickDate(controller: controller.dobC, firstDate: DateTime(1950), lastDate: DateTime.now()), validator: (v) => controller.requiredValidator(v, 'Date Of Birth')),
                            _DropdownBlock(label: 'Blood Group *', valueRx: controller.bloodGroup, itemsBuilder: () => controller.bloodGroups, hint: 'Select Blood Group'),
                            _DropdownBlock(label: 'Gender *', valueRx: controller.gender, itemsBuilder: () => controller.genders, hint: 'Select Gender'),
                            _DropdownBlock(label: 'Caste *', valueRx: controller.caste, itemsBuilder: () => controller.castes, hint: 'Select Caste'),
                            _TextFieldBlock(label: 'E-Mail ', controller: controller.emailC, keyboardType: TextInputType.emailAddress, validator: controller.emailValidator, hint: 'Enter email'),
                            _TextFieldBlock(label: 'Mobile No *', controller: controller.mobileC, keyboardType: TextInputType.phone, validator: controller.mobileValidator, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
                            _TextFieldBlock(label: 'Qualification', controller: controller.qualificationC),
                            _TextFieldBlock(label: 'Last Organization', controller: controller.lastOrgC),
                            _DropdownBlock(label: 'Designation *', valueRx: controller.designation, itemsBuilder: () => controller.designationNames, hint: 'Select Designation', isLoadingRx: controller.isDesignationLoading),
                            _TextFieldBlock(label: 'Total Experience', controller: controller.totalExpC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'Total Experience')),
                            _TextFieldBlock(label: 'Salary', controller: controller.salaryC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'Salary'), inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                            _TextFieldBlock(label: 'State *', controller: controller.stateC, validator: (v) => controller.requiredValidator(v, 'State'), hint: 'Enter state', textCapitalization: TextCapitalization.words),
                            _TextFieldBlock(label: 'City *', controller: controller.cityC, validator: (v) => controller.requiredValidator(v, 'City'), textCapitalization: TextCapitalization.words),
                            _DateFieldBlock(label: 'Date Of Joining *', controller: controller.joiningDateC, onPick: () => controller.pickDate(controller: controller.joiningDateC, firstDate: DateTime(2000), lastDate: DateTime(DateTime.now().year + 2)), validator: (v) => controller.requiredValidator(v, 'Date Of Joining')),
                            _TextFieldBlock(label: 'Address *', controller: controller.addressC, validator: (v) => controller.requiredValidator(v, 'Address')),
                            _TextFieldBlock(label: 'Specialization *', controller: controller.specializationC, validator: (v) => controller.requiredValidator(v, 'Specialization')),
                            _TextFieldBlock(label: 'Bank Name *', controller: controller.bankNameC, validator: (v) => controller.requiredValidator(v, 'Bank Name'), textCapitalization: TextCapitalization.words),
                            _TextFieldBlock(label: 'Account No', controller: controller.accountNoC, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(18)]),
                            _TextFieldBlock(label: 'IFSC Code *', controller: controller.ifscC, validator: (v) => controller.requiredValidator(v, 'IFSC Code'), textCapitalization: TextCapitalization.characters, inputFormatters: [LengthLimitingTextInputFormatter(11)]),
                            if (cols > 1) const SizedBox.shrink(),
                            if (cols > 2) const SizedBox.shrink(),
                          ]),

                          const SizedBox(height: 18),
                          _Grid(columns: cols == 1 ? 1 : 2, children: [
                            _fileCol('Upload User Pic', controller.userPic, controller),
                            _fileCol('Upload Id Proof Photo', controller.idProofPhoto, controller),
                          ]),
                          const SizedBox(height: 18),
                          _Grid(columns: cols == 1 ? 1 : 2, children: [
                            _fileCol('Upload Resume Photo', controller.resumePhoto, controller),
                            _fileCol('Upload Call Letter Photo', controller.callLetterPhoto, controller),
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

Widget _fileCol(String title, Rxn<PlatformFile> rx, TeacherAddController ctrl) {
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

// ── View Teacher Tab ─────────────────────────────────────────────────────────
class ViewTeacherTab extends GetView<TeacherAddController> {
  const ViewTeacherTab({super.key});

  void _openEditDialog(BuildContext context, TeacherAddController ctrl, TeacherModel teacher) {
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
                  // Dialog header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFB6547B), Color(0xFF97144D)]),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text("Edit Teacher Details",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        IconButton(
                          onPressed: () { ctrl.resetForm(); Navigator.pop(context); },
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Dialog form
                  Expanded(
                    child: Form(
                      key: ctrl.dialogFormKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _EditTeacherDialogForm(controller: ctrl),
                      ),
                    ),
                  ),
                  // Dialog footer buttons
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
                              backgroundColor: const Color(0xFF97144D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: ctrl.isSubmitting.value
                                ? null
                                : () async => await ctrl.updateTeacherFromDialog(),
                            icon: ctrl.isSubmitting.value
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_outlined),
                            label: Text(ctrl.isSubmitting.value ? "Updating..." : "Update Teacher"),
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
                  // Header row
                  Row(
                    children: [
                      Text("All Teacher Data",
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

                  // Search field
                  SizedBox(
                    height: 44,
                    child: TextField(
                      controller: controller.teacherSearchC,
                      decoration: InputDecoration(
                        hintText: "Search name / teacher id / mobile",
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

                  // Table
                  Obx(() {
                    if (controller.isTeacherLoading.value) {
                      return const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator()));
                    }

                    final list = controller.filteredTeachers;
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(18),
                        child: Center(child: Text("No teacher found", style: TextStyle(color: Colors.grey.shade700))),
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
                          DataColumn(label: Text("Teacher Id")),
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
                            DataCell(Text(t.teacherReg ?? "-")),
                            DataCell(Text(t.name ?? "-")),
                            DataCell(Text(t.fhname ?? "-")),
                            DataCell(Text(t.mobileNo ?? "-")),
                            DataCell(Text(controller.formatDate(t.dateofJoining))),
                            DataCell(Text(controller.formatDate(t.createDate))),
                            DataCell(Text(controller.formatDate(t.updateDate))),
                            DataCell(_ActionButtons(
                              onEdit: () => _openEditDialog(context, controller, t),
                              onView: () => controller.onTeacherView(t),   // ← eye icon navigates
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

// ── Action Buttons: Edit (orange) + View (Axis Maroon) ──────────────────────
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
        btn(bg: const Color(0xFF97144D), icon: Icons.visibility, onTap: onView, tooltip: 'View Details'),
      ],
    );
  }
}

// ── Edit Dialog Form ──────────────────────────────────────────────────────────
class _EditTeacherDialogForm extends StatelessWidget {
  final TeacherAddController controller;
  const _EditTeacherDialogForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 1100 ? 3 : (MediaQuery.of(context).size.width >= 800 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Grid(columns: cols, children: [
          _TextFieldBlock(label: 'Teacher Name *', controller: controller.teacherNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, 'Teacher Name')),
          _ReadOnlyFieldBlock(label: 'Teacher ID', controller: controller.teacherIdC),
          _TextFieldBlock(label: "Father/Husband's Name *", controller: controller.fatherHusbandNameC, textCapitalization: TextCapitalization.words, validator: (v) => controller.requiredValidator(v, "Father/Husband's Name")),
          _DateFieldBlock(label: 'Date Of Birth *', controller: controller.dobC, onPick: () => controller.pickDate(controller: controller.dobC, firstDate: DateTime(1950), lastDate: DateTime.now()), validator: (v) => controller.requiredValidator(v, 'Date Of Birth')),
          _DropdownBlock(label: 'Blood Group *', valueRx: controller.bloodGroup, itemsBuilder: () => controller.bloodGroups, hint: 'Select Blood Group'),
          _DropdownBlock(label: 'Gender *', valueRx: controller.gender, itemsBuilder: () => controller.genders, hint: 'Select Gender'),
          _DropdownBlock(label: 'Caste *', valueRx: controller.caste, itemsBuilder: () => controller.castes, hint: 'Select Caste'),
          _TextFieldBlock(label: 'E-Mail ', controller: controller.emailC, keyboardType: TextInputType.emailAddress, validator: controller.emailValidator, hint: 'Enter email'),
          _TextFieldBlock(label: 'Mobile No *', controller: controller.mobileC, keyboardType: TextInputType.phone, validator: controller.mobileValidator, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
          _TextFieldBlock(label: 'Qualification', controller: controller.qualificationC),
          _TextFieldBlock(label: 'Last Organization', controller: controller.lastOrgC),
          _DropdownBlock(label: 'Designation *', valueRx: controller.designation, itemsBuilder: () => controller.designationNames, hint: 'Select Designation', isLoadingRx: controller.isDesignationLoading),
          _TextFieldBlock(label: 'Total Experience', controller: controller.totalExpC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'Total Experience')),
          _TextFieldBlock(label: 'Salary', controller: controller.salaryC, keyboardType: TextInputType.number, validator: (v) => controller.numberOptionalValidator(v, 'Salary'), inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _TextFieldBlock(label: 'State *', controller: controller.stateC, validator: (v) => controller.requiredValidator(v, 'State'), hint: 'Enter state', textCapitalization: TextCapitalization.words),
          _TextFieldBlock(label: 'City *', controller: controller.cityC, validator: (v) => controller.requiredValidator(v, 'City'), textCapitalization: TextCapitalization.words),
          _DateFieldBlock(label: 'Date Of Joining *', controller: controller.joiningDateC, onPick: () => controller.pickDate(controller: controller.joiningDateC, firstDate: DateTime(2000), lastDate: DateTime(DateTime.now().year + 2)), validator: (v) => controller.requiredValidator(v, 'Date Of Joining')),
          _TextFieldBlock(label: 'Address *', controller: controller.addressC, validator: (v) => controller.requiredValidator(v, 'Address')),
          _TextFieldBlock(label: 'Specialization *', controller: controller.specializationC, validator: (v) => controller.requiredValidator(v, 'Specialization')),
          _TextFieldBlock(label: 'Bank Name *', controller: controller.bankNameC, validator: (v) => controller.requiredValidator(v, 'Bank Name'), textCapitalization: TextCapitalization.words),
          _TextFieldBlock(label: 'Account No', controller: controller.accountNoC, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(18)]),
          _TextFieldBlock(label: 'IFSC Code *', controller: controller.ifscC, validator: (v) => controller.requiredValidator(v, 'IFSC Code'), textCapitalization: TextCapitalization.characters, inputFormatters: [LengthLimitingTextInputFormatter(11)]),
          if (cols > 1) const SizedBox.shrink(),
          if (cols > 2) const SizedBox.shrink(),
        ]),
        const SizedBox(height: 18),
        _Grid(columns: cols == 1 ? 1 : 2, children: [
          _fileCol('Upload User Pic', controller.userPic, controller),
          _fileCol('Upload Id Proof Photo', controller.idProofPhoto, controller),
        ]),
        const SizedBox(height: 18),
        _Grid(columns: cols == 1 ? 1 : 2, children: [
          _fileCol('Upload Resume Photo', controller.resumePhoto, controller),
          _fileCol('Upload Call Letter Photo', controller.callLetterPhoto, controller),
        ]),
      ],
    );
  }
}

// ── Shared UI Widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87));
  }
}

class _Grid extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  const _Grid({required this.columns, required this.children});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 3 ? 3.2 : (columns == 2 ? 3.0 : 3.4),
      children: children.map((w) => Align(alignment: Alignment.topLeft, child: w)).toList(),
    );
  }
}

class _TextFieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization? textCapitalization;

  const _TextFieldBlock({required this.label, required this.controller, this.hint, this.keyboardType, this.validator, this.inputFormatters, this.maxLength, this.textCapitalization});

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        decoration: _inputDecoration(hint: hint).copyWith(counterText: ''),
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
    return _FieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: _inputDecoration().copyWith(fillColor: Colors.grey.shade100),
      ),
    );
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
        decoration: _inputDecoration(hint: 'DD-MM-YYYY').copyWith(suffixIcon: const Icon(Icons.calendar_month)),
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
          items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
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

class _FieldShell extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldShell({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SizedBox(height: 44, child: child),
      ],
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.blue)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red)),
  );
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
      final f = fileRx.value;
      final hasFile = f != null;
      return TextFormField(
        readOnly: true,
        onTap: onPick,
        decoration: _inputDecoration(hint: hint).copyWith(
          suffixIcon: hasFile
              ? IconButton(tooltip: 'Remove', onPressed: onClear, icon: const Icon(Icons.close))
              : const Icon(Icons.upload_file),
        ),
        controller: TextEditingController(text: hasFile ? f!.name : ''),
      );
    });
  }
}