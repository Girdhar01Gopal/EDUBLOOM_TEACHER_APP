import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/totalstudentcontroller.dart';
import 'Total_class_students_screen.dart';
import 'daycare_class_students_screen.dart';

class Totalstudentview extends GetView<Totalstudentcontroller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
        title: const Text(
          'Total Students',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.vehicleDocumentList.isEmpty &&
            controller.totalDaycareCount.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: [
            // ── Normal class wise cards ──────────────────
            ...controller.vehicleDocumentList
                .where((entry) =>
            (entry.className ?? '').trim().toLowerCase() != 'daycare')
                .map((entry) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => ClassStudentsScreen(
                    className: entry.className ?? '',
                  ));
                },
                child: _buildCard(
                  label: entry.className ?? 'N/A',
                  count: '${entry.totalStudent ?? 0}',
                  isDaycare: false,
                ),
              );
            }).toList(),

            // ── Daycare card ─────────────────────────────
            GestureDetector(
              onTap: () {
                Get.to(() => const DaycareClassStudentsScreen(
                  className: '',
                  showAll: true,
                ));
              },
              child: _buildCard(
                label: '🧒 Day Care Students',
                count: '${controller.totalDaycareCount.value}',
                isDaycare: true,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCard({
    required String label,
    required String count,
    required bool isDaycare,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDaycare
                ? Colors.orange.withOpacity(0.12)
                : Colors.teal.withOpacity(0.10),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDaycare
              ? Colors.orange.shade100
              : Colors.teal.shade50,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
          isDaycare ? Colors.orange[700] : Colors.teal[800],
          radius: 24,
          child: Text(
            isDaycare
                ? 'DC'
                : (() {
              final name = label;
              if (name.length >= 2) return name.substring(0, 2);
              return name;
            })(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDaycare
                  ? Colors.orange[800]
                  : const Color(0xFF1A2B3C)),
        ),
        trailing: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDaycare
                ? Colors.orange.withOpacity(0.12)
                : Colors.green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDaycare
                  ? Colors.orange.shade300
                  : Colors.green.shade300,
              width: 1,
            ),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDaycare
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
            ),
          ),
        ),
      ),
    );
  }
}