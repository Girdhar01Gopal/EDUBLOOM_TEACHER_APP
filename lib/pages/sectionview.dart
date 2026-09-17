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
          backgroundColor: const Color(0xFF97144D),// AppBar color
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
    return Column(
      children: [
        // ADDED: search bar right below the app bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 0),
          child: TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: "Search section...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final sessionData = controller.sessionData.value;

            // Show big loader only on the very first load (no data yet)
            if (controller.isLoading.value &&
                (sessionData.listData == null || sessionData.listData!.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
            }

            // CHANGED: using filteredSessionList instead of sessionData.listData directly
            final filteredList = controller.filteredSessionList;

            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchSessionData();
              },
              child: sessionData.listData == null || sessionData.listData!.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('🚫 No Section available')),
                ],
              )
                  : Padding(
                padding: EdgeInsets.all(16.r),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Text(
                      '📂All Sections',
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),
                    ...filteredList.map((item) {
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
              ),
            );
          }),
        ),
      ],
    );
  }
}