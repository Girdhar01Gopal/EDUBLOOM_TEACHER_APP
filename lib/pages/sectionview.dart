import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/sectioncontroller.dart';

class sectionview extends GetView<Sectioncontroller> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(

          title: const Text('📘 Section Management',
            style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: const Color(0xFF6E0F38), // AppBar color
          iconTheme: IconThemeData(color: Colors.white), // Change the back arrow to white
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Add Section'),
              Tab(icon: Icon(Icons.view_list), text: 'View Sections'),
            ],
            labelColor: Colors.white, // Change selected tab icon/text to white
            unselectedLabelColor: Colors.white, // Change unselected tab icon/text to white
          ),
        ),
        body: const TabBarView(
          children: [
            PostSessionTab(),
            ViewSessionTab(),
          ],
        ),
      ),
    );
  }
}

class PostSessionTab extends GetView<Sectioncontroller> {
  const PostSessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗓️ Add New Section',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: controller.sessionController,
            decoration: InputDecoration(
              labelText: 'Enter Section',
              hintText: 'e.g., A, B, C',
              prefixIcon: Icon(Icons.calendar_today),
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
                await controller.postSession();

                Get.snackbar('Success', 'Section added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              icon: Icon(Icons.send,color: Colors.white,),
              label: Text('Submit', style: TextStyle(fontSize: 18.sp,color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12), backgroundColor: Colors.pink.shade500, disabledForegroundColor: Colors.pink.shade300.withOpacity(0.38), disabledBackgroundColor: Colors.pink.shade300.withOpacity(0.12), // Gradient End for Button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewSessionTab extends GetView<Sectioncontroller> {
  const ViewSessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final sessionData = controller.sessionData.value;

      if (sessionData.listData == null || sessionData.listData!.isEmpty) {
        return const Center(child: Text('🚫 No Section available'));
      }

      return Padding(
        padding: EdgeInsets.all(16.r),
        child: ListView(
          children: [
            Text(
              '📂All Sections',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ...sessionData.listData!.map((item) {
              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.symmetric(vertical: 6.h),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blueAccent),
                  title: Text(
                    item.section ?? 'No Section Name',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  trailing: InkWell(
                    onTap: () => controller.openEditSectionDialog(item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
