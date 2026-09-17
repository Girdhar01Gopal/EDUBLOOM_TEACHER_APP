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
          backgroundColor: const Color(0xFF97144D),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text("🏫 Class Management", style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Class"),
              Tab(icon: Icon(Icons.list), text: "View Classes"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [AddClassTab(), ViewClassTab()],
        ),
      ),
    );
  }
}

class AddClassTab extends GetView<ClassController> {
  const AddClassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📘 Add New Class', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),
          TextField(
            controller: controller.clas,
            decoration: InputDecoration(
              labelText: "Class Name",
              prefixIcon: const Icon(Icons.class_),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isPosting.value
                  ? null
                  : () {
                if (controller.clas.text.trim().isEmpty) {
                  ShortMessage.toast(title: "Please enter class name");
                  return;
                }
                controller.postClass(className: controller.clas.text.trim());
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFD3C72)),
              child: Text(controller.isPosting.value ? "Processing..." : "Submit",
                  style: const TextStyle(color: Colors.white)),
            )),
          ),
        ],
      ),
    );
  }
}

class ViewClassTab extends GetView<ClassController> {
  const ViewClassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchClasses,
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        // FIX: Added null safety check and default empty list
        final classes = controller.classList.value.listData.reversed.toList();

        if (classes.isEmpty) {
          return ListView(children: const [SizedBox(height: 200), Center(child: Text("📭 No classes available"))]);
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: classes.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final c = classes[index];
            // FIX: Using robust trim with fallbacks
            final className = c.className.trim().isEmpty ? "-" : c.className.trim();
            final created = controller.formatDDMMYYYY(c.createDate);
            final updated = controller.formatDDMMYYYY(c.updateDate);
            final isActionOne = c.action.trim() == "1";

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.class_, color: Colors.white, size: 20.sp)),
                title: Text(className, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                subtitle: Text("Created: $created", style: TextStyle(fontSize: 12.sp)),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange, size: 20.sp),
                  onPressed: () => controller.openEditClassDialog(context, c),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}