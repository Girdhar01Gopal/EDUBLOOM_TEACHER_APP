import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/view_curriculum.dart';
import '../models/view_curriculum.dart';

class ViewCurriculumView extends GetView<ViewCurriculumController> {
  const ViewCurriculumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade800,
        centerTitle: true,
        title: const Text(
          'View Curriculum',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Curriculum List',
            //   style: TextStyle(
            //     fontSize: 28.sp,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.black,
            //   ),
            // ),
            SizedBox(height: 14.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.curriculumList.isEmpty) {
                  return const Center(
                    child: Text("No curriculum found"),
                  );
                }

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.curriculumList.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                          itemBuilder: (context, index) {
                            final item = controller.curriculumList[index];
                            return _buildRow(item);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          _headerCell("S.No", flex: 1),
          //_headerCell("School Name", flex: 3),
          _headerCell("Title", flex: 2),
          _headerCell("File", flex: 2),
        ],
      ),
    );
  }

  Widget _buildRow(ViewCurriculumModel item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          _bodyCell(item.sno.toString(), flex: 1),
          //_bodyCell(item.schoolName, flex: 3),
          _bodyCell(item.title, flex: 2),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 34.h,
                child: ElevatedButton(
                  onPressed: () => controller.onDownloadTap(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    "Download",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bodyCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      ),
    );
  }
}