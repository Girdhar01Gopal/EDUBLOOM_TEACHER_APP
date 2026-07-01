import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../controller/session_controller.dart';
import '../models/session_model.dart';

// ✅ NEW: Strict formatter for YYYY-YY (e.g., 2025-26)
class SessionInputFormatter extends TextInputFormatter {
  static final RegExp _validPartial = RegExp(r'^\d{0,4}(-\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;

    // only digits and hyphen
    text = text.replaceAll(RegExp(r'[^0-9-]'), '');

    // hard max length (2025-26 = 7)
    if (text.length > 7) return oldValue;

    // auto insert dash after 4 digits if user keeps typing
    if (text.length > 4 && !text.contains('-')) {
      text = '${text.substring(0, 4)}-${text.substring(4)}';
    }

    // allow only one dash and correct positions
    if (!_validPartial.hasMatch(text)) return oldValue;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class SessionScreen extends GetView<SessionController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            '📘 Session Management',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF6E0F38),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add, color: Colors.white), text: 'Add Session'),
              Tab(icon: Icon(Icons.view_list, color: Colors.white), text: 'View Sessions'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
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

class PostSessionTab extends GetView<SessionController> {
  const PostSessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗓️ Add New Session',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),

          /// ✅ STRICT VALIDATION TEXTFIELD: ONLY YYYY-YY (2025-26)
          TextField(
            controller: controller.sessionController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              SessionInputFormatter(), // ✅ NEW
            ],
            decoration: InputDecoration(
              labelText: 'Enter Session',
              hintText: 'e.g., 2025-26',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 30.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                // ✅ final check before API call
                final val = controller.sessionController.text.trim();
                final ok = RegExp(r'^\d{4}-\d{2}$').hasMatch(val);
                if (!ok) {
                  Get.snackbar(
                    'Invalid',
                    'Session format must be like 2025-26',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                await controller.postSession();
                Get.snackbar(
                  'Success',
                  'Session added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.send, color: Colors.white),
              label: Text(
                'Submit',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                backgroundColor: Colors.pink.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewSessionTab extends GetView<SessionController> {
  const ViewSessionTab({super.key});

  // ✅ ONLY UI formatting helper (logic untouched)
  String _formatToDDMMYYYY(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return "-";
    try {
      final dt = DateTime.parse(isoDate);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return "$dd-$mm-$yyyy";
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final sessionData = controller.sessionData.value;

      if (sessionData.listData == null || sessionData.listData!.isEmpty) {
        return const Center(child: Text('🚫 No sessions available'));
      }

      final List<sListDdata> sortedSessions =
      List<sListDdata>.from(sessionData.listData!);
      sortedSessions.sort((a, b) => (b.sessionId ?? 0).compareTo(a.sessionId ?? 0));

      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: ListView(
                children: [
                  Text(
                    '📌 Current Session',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.deepPurple, size: 30),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            sessionData.currentSession!.session.toString(),
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  Text(
                    '📂 Previous Sessions',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),

                  ...sortedSessions.map((session) {
                    final bool isCurrent =
                        session.sessionId == controller.selectedSessionId.value;

                    // ✅ Action -> Active/Inactive (same logic)
                    final String actionVal = (session.action ?? "0").toString();
                    final bool isActive = actionVal == "1";

                    // ✅ Created date formatted dd-mm-yyyy
                    final String createdDate = _formatToDDMMYYYY(session.createDate);

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade300, Colors.pink.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: isCurrent,
                          onChanged: (_) {
                            controller.selectedSessionId.value = session.sessionId!;
                            controller.tempSelectedSession.value = session;
                          },
                        ),

                        // ✅ Session + created date below
                        title: Text(
                          session.session.toString(),
                          style: TextStyle(fontSize: 18.sp, color: Colors.white),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            "Created: $createdDate",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),

                        // ✅ Action + tick + edit
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isActive ? Icons.check_circle : Icons.cancel,
                                  color: isActive ? Colors.greenAccent : Colors.redAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  isActive ? "Active" : "Inactive",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10.w),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                controller.openEditSessionDialog(session);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          Obx(() {
            if (controller.tempSelectedSession.value == null) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () async {
                  await controller.updateCurrentSession(
                    controller.tempSelectedSession.value!,
                  );
                },
                child: Text(
                  "Make This Current Session",
                  style: TextStyle(fontSize: 18.sp, color: Colors.white),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}