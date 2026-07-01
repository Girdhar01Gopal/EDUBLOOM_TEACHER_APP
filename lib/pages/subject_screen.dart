import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/subject_controller.dart';

class SubjectScreen extends GetView<SubjectController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            '📚 Subject Management',
            style: TextStyle(color: Colors.white), // Text color set to white
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF99144E), // AppBar color
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add, color: Colors.white), text: 'Post Subject'),
              Tab(icon: Icon(Icons.list, color: Colors.white), text: 'View Subjects'),
            ],
            labelColor: Colors.white, // Text color in TabBar
            unselectedLabelColor: Colors.white, // Unselected Tab Text color
          ),
        ),
        body: const TabBarView(
          children: [
            PostSubjectTab(),
            ViewSubjectTab(),
          ],
        ),
      ),
    );
  }
}

class PostSubjectTab extends GetView<SubjectController> {
  const PostSubjectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '➕ Add New Subject',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: controller.subject,
            decoration: InputDecoration(
              labelText: 'Subject Name',
              hintText: 'Enter subject (e.g., Mathematics)',
              prefixIcon: Icon(Icons.book),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 30.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                await controller.postSubject(context);
                controller.subject.clear();
                Get.snackbar('Success', 'Subject added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              icon: Icon(Icons.check, color: Colors.white),
              label: Text('Submit', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                backgroundColor: Colors.pink.shade500,
                disabledForegroundColor: Colors.pink.shade300.withOpacity(0.38),
                disabledBackgroundColor: Colors.pink.shade300.withOpacity(0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewSubjectTab extends GetView<SubjectController> {
  const ViewSubjectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Obx(() {
        final list = controller.subjectdata.value.listData;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (list == null || list.isEmpty) {
          return const Center(child: Text("📭 No subjects available"));
        }

        // latest first (reverse)
        final subjects = list.reversed.toList();

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: subjects.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final s = subjects[index];

            final title = (s.subject ?? '').trim();
            final sid = s.subjectId;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEAD0DB).withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFEAD0DB), width: 1.2),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Left icon badge
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC17294), Color(0xFFA1265C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 26.sp),
                    ),
                    SizedBox(width: 14.w),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? "-" : title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              // Container(
                              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              //   decoration: BoxDecoration(
                              //     color: Colors.teal.shade50,
                              //     borderRadius: BorderRadius.circular(20.r),
                              //     border: Border.all(color: Colors.teal.shade200),
                              //   ),
                              //   child: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       // Icon(Icons.tag_rounded, size: 13.sp, color: Colors.teal.shade700),
                              //       // SizedBox(width: 4.w),
                              //       // Text(
                              //       //   "ID: ${sid ?? '-'}",
                              //       //   style: TextStyle(
                              //       //     fontSize: 12.sp,
                              //       //     fontWeight: FontWeight.w600,
                              //       //     color: Colors.teal.shade700,
                              //       //   ),
                              //       // ),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 13.sp, color: Colors.green.shade700),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Active",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: IconButton(
                        tooltip: "Edit",
                        icon: Icon(Icons.edit_rounded, color: Colors.orange.shade700, size: 20.sp),
                        onPressed: () => controller.openEditSubjectDialog(context, s),
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

  Widget _chip(String text, IconData icon, {Color? bg, Color? fg}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: (fg ?? Colors.blue.shade700).withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: fg ?? Colors.blue.shade700),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: fg ?? Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await controller.fetchsubjectdata();
  }
}