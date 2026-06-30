import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/createandmapcategory.dart';

class Createandmapcategoryview extends GetView<Createandmapcategorycontroller> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('🎓 Gallery Category'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_add_alt_1), text: 'Add Category'),
              Tab(icon: Icon(Icons.list), text: 'View Category'),


            ],
          ),
        ),
        body: const TabBarView(
          children: [

            AddStudentTab(),
            ViewStudentTab(

            ),
              
          ],
        ),
      ),
    );
  }
}

class AddStudentTab extends GetView<Createandmapcategorycontroller> {
  const AddStudentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Form(
       
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            /// -------------------------------------------------------
            ///          📁 Add Gallery Category Section
            /// -------------------------------------------------------
            Text(
              "📁 Add Gallery Category",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: TextFormField(
                controller: controller.galleryCategoryController,
                decoration: InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text(
                  "Add Category",
                  style: TextStyle(fontSize: 18.sp),
                ),
                onPressed: () {
                  if (controller.galleryCategoryController.text.isEmpty) {
                    Get.snackbar("⚠ Error", "Category name is required");
                  } else {
                    controller.postGalleryCategory();
                  }
                },
              ),
            ),

            // SizedBox(height: 30.h),
            // Divider(thickness: 2),
 ],
        ),
      ),
    );
  }

  // ---------------- UI Components ----------------

}
class ViewStudentTab extends StatefulWidget {
  const ViewStudentTab({super.key});

  @override
  State<ViewStudentTab> createState() => _ViewStudentTabState();
}

class _ViewStudentTabState extends State<ViewStudentTab> {
  final controller = Get.put(Createandmapcategorycontroller());

  @override
  void initState() {
    super.initState();
    controller.fetchGalleryCategories(); // Fetch categories on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.galleryCategories.isEmpty) {
        return const Center(
          child: Text(
            "No Categories Found",
            style: TextStyle(fontSize: 18),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.galleryCategories.length,
        itemBuilder: (context, index) {
          final item = controller.galleryCategories[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.blueAccent),
              title: Text(
                item.category ?? "Unnamed Category",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "ID: ${item.addCategoryId}",
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      );
    });
  }
}




