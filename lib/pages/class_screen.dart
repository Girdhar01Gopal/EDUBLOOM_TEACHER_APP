import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../controller/class_controller.dart';
import '../infrastructures/utils/utils.dart';

class ClassScreen extends GetView<ClassController> {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            "🏫 Class Management",
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.add, color: Colors.white),
                text: "Add Class",
              ),
              Tab(
                icon: Icon(Icons.list, color: Colors.white),
                text: "View Classes",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddClassTab(),
            ViewClassTab(),
          ],
        ),
      ),
    );
  }
}

// ============================
// ADD CLASS TAB
// ============================
class AddClassTab extends GetView<ClassController> {
  const AddClassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📘 Add New Class',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField(
            controller: controller.clas,
            label: "Class Name",
            icon: Icons.class_,
            hint: "e.g., Nursery, LKG, 1st",
          ),
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed: controller.isPosting.value
                    ? null
                    : () async {
                  if (controller.clas.text.trim().isEmpty) {
                    ShortMessage.toast(title: "Please enter class name");
                    return;
                  }

                  await controller.postClass(
                    className: controller.clas.text.trim(),
                  );
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  controller.isPosting.value ? "Please wait..." : "Submit",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD3C72),
                  disabledForegroundColor:
                  const Color(0xFFFB6E9A).withOpacity(0.38),
                  disabledBackgroundColor:
                  const Color(0xFFFB6E9A).withOpacity(0.12),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters ?? [],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ============================
// VIEW CLASS TAB
// ============================
class ViewClassTab extends GetView<ClassController> {
  const ViewClassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchClasses,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = controller.classList.value.listData.reversed.toList();

        if (classes.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 200),
              Center(child: Text("📭 No classes available")),
            ],
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: classes.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final c = classes[index];

            final className = c.className.trim().isEmpty ? "-" : c.className.trim();
            final created = controller.formatDDMMYYYY(c.createDate);
            final updated = controller.formatDDMMYYYY(c.updateDate);
            final isActionOne = c.action.trim() == "1";

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade100.withOpacity(0.7),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.indigo.shade100, width: 1.2),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left icon badge
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.class_rounded, color: Colors.white, size: 26.sp),
                    ),
                    SizedBox(width: 14.w),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Class name + edit button row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  className,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: IconButton(
                                  tooltip: "Edit",
                                  constraints: BoxConstraints(
                                    minWidth: 36.w,
                                    minHeight: 36.w,
                                  ),
                                  padding: EdgeInsets.all(6.r),
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: Colors.orange.shade700,
                                    size: 18.sp,
                                  ),
                                  onPressed: () =>
                                      controller.openEditClassDialog(context, c),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          // Status chip
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isActionOne ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isActionOne ? Colors.green.shade200 : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActionOne ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      size: 13.sp,
                                      color: isActionOne ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      isActionOne ? "Active" : "Inactive",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isActionOne ? Colors.green.shade700 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          // Divider
                          Divider(color: Colors.indigo.shade50, height: 1, thickness: 1),
                          SizedBox(height: 8.h),
                          // Date info
                          _infoRow(Icons.calendar_today_rounded, "Created", created, Colors.indigo),
                          SizedBox(height: 6.h),
                          _infoRow(Icons.update_rounded, "Updated", updated, Colors.teal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, MaterialColor color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14.sp, color: color.shade400),
        SizedBox(width: 6.w),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color.shade600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _rowText(String left, String right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$left: ",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}