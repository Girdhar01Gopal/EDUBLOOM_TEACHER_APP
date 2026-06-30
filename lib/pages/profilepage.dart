import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../controller/profile_page_controller.dart';
import '../infrastructures/routes/page_constants.dart';

class ProfilePage extends GetView<ProfilePageController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
               Get.offAllNamed(RouteName.login_screen);
              },
            )
          ],
        ),
       body: Obx(() {
        if (controller.name.value.isEmpty || controller.role.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //  Basic Profile Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF268ac5),
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(controller.name.value.isNotEmpty ? controller.name.value : 'N/A',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     Padding(
                      //       padding: EdgeInsets.only(left: 65.w),
                      //       child: Text('Role: ${controller.role.value.isNotEmpty ? controller.role.value : 'N/A'}',
                      //           style: TextStyle(color: Colors.grey[600])),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📞 Contact Info
              _buildSectionCard(
                title: 'Details',
                icon: Icons.pages,
                items: [
                  _buildTile('UserName', controller.username.value),
                  _buildTile('School-id', controller.schoolid.value),
                  _buildTile('Seasion', controller.seassion.value),
                ],
              ),

              const SizedBox(height: 20),

              // 📄 Document Info
              // You can add more sections here if needed
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              flex: 5,
              child: Text(value ?? 'N/A',
                  style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
