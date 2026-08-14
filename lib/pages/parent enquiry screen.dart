import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/parent enquiry controller.dart';
import '../models/parent_View enquiry model.dart';

class EnquiryScreen extends GetView<EnquiryController> {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: Get.back,
          ),
          title: Text(
            "Parent Enquiries",
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          backgroundColor: teal,
          elevation: 4,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'View Enquiry'),
              Tab(text: 'Search Enquiry'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ViewEnquiryTab(teal: teal),
            _SearchEnquiryTab(teal: teal),
          ],
        ),
      ),
    );
  }
}

// ---------------- Search Enquiry Tab (date filter) ----------------

class _SearchEnquiryTab extends GetView<EnquiryController> {
  final Color teal;
  const _SearchEnquiryTab({required this.teal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Card ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _dateField(
                    label: "Start Date",
                    value: controller.fmtUi(controller.startDate.value),
                    onTap: () => controller.pickStartDate(context),
                  )),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() => _dateField(
                    label: "End Date",
                    value: controller.fmtUi(controller.endDate.value),
                    onTap: () => controller.pickEndDate(context),
                  )),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: controller.fetchSearchEnquiry,
                    child: Text(
                      "🔎 Search",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── Enquiry List ─────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isSearchLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.searchError.value.isNotEmpty) {
                return _ErrorView(
                  message: controller.searchError.value,
                  onRetry: controller.fetchSearchEnquiry,
                );
              }
              if (controller.searchEnquiryList.isEmpty) {
                return const Center(child: Text("No data found"));
              }
              return RefreshIndicator(
                onRefresh: controller.fetchSearchEnquiry,
                child: ListView.builder(
                  itemCount: controller.searchEnquiryList.length,
                  itemBuilder: (context, index) {
                    final item = controller.searchEnquiryList[index];
                    return _EnquiryCard(
                      id: item.id ?? 0,
                      title: item.title?.toString() ?? item.className ?? 'Enquiry',
                      message: item.message ?? '',
                      studentName: item.studentName?.toString(),
                      className: item.className,
                      section: item.section,
                      createDate: item.createDate,
                      reply: item.reply,
                      isReplied: item.isReplied,
                      parentId: item.parentID?.toString(),
                      classId: item.classId,
                      sectionId: item.sectionId,
                      type: item.type?.toString(),
                      subject: item.subject?.toString(),
                      teacherReg: item.teacherReg?.toString(),
                      createBy: item.createBy?.toString(),
                      replyId: item.replyId,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0x22000000)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style:
                    TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- View Enquiry Tab ----------------

class _ViewEnquiryTab extends GetView<EnquiryController> {
  final Color teal;
  const _ViewEnquiryTab({required this.teal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        if (controller.isViewLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.viewError.value.isNotEmpty) {
          return _ErrorView(
            message: controller.viewError.value,
            onRetry: controller.fetchViewEnquiry,
          );
        }
        if (controller.viewEnquiryList.isEmpty) {
          return const Center(child: Text("No data found"));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchViewEnquiry,
          child: ListView.builder(
            itemCount: controller.viewEnquiryList.length,
            itemBuilder: (context, index) {
              final ViewEnquiryModel item = controller.viewEnquiryList[index];
              return _EnquiryCard(
                id: item.id ?? 0,
                title: item.title ?? item.className ?? 'Enquiry',
                message: item.message ?? '',
                studentName: item.studentName,
                className: item.className,
                section: item.section,
                createDate: item.createDate,
                reply: item.reply,
                isReplied: item.isReplied,
                parentId: item.parentID?.toString(),
                classId: item.classId,
                sectionId: item.sectionId,
                type: item.type?.toString(),
                subject: item.subject?.toString(),
                teacherReg: item.teacherReg?.toString(),
                createBy: item.createBy?.toString(),
                replyId: item.replyId,
              );
            },
          ),
        );
      }),
    );
  }
}

// ---------------- Shared Card Widget ----------------

class _EnquiryCard extends GetView<EnquiryController> {
  final int id;
  final String title;
  final String message;
  final String? studentName;
  final String? className;
  final String? section;
  final DateTime? createDate;
  final String? reply;
  final bool isReplied;

  // PostEnquiry body ke liye zaroori extra fields
  final String? parentId;
  final int? classId;
  final int? sectionId;
  final String? type;
  final String? subject;
  final String? teacherReg;
  final String? createBy;
  final int? replyId;

  const _EnquiryCard({
    required this.id,
    required this.title,
    required this.message,
    required this.isReplied,
    this.studentName,
    this.className,
    this.section,
    this.createDate,
    this.reply,
    this.parentId,
    this.classId,
    this.sectionId,
    this.type,
    this.subject,
    this.teacherReg,
    this.createBy,
    this.replyId,
  });

  Color get _statusColor => isReplied ? Colors.green : Colors.red;

  // ---------- Reply dialog ----------
  void _openReplyDialog(BuildContext context) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reply'),
          content: TextField(
            controller: replyController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Please write your reply here ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Obx(() {
              final sending = controller.isReplying(id);
              return ElevatedButton(
                onPressed: sending
                    ? null
                    : () async {
                  final success = await controller.sendReply(
                    enquiryId: id,
                    replyText: replyController.text,
                    parentId: parentId,
                    studentName: studentName,
                    classId: classId,
                    sectionId: sectionId,
                    title: title,
                    type: type,
                    subject: subject,
                    teacherReg: teacherReg,
                    createBy: createBy,
                    originalMessage: message,
                    replyId: replyId,
                  );
                  if (success) {
                    Navigator.of(dialogContext).pop();
                  } else if (controller.replyError.value.isNotEmpty) {
                    Get.snackbar('Error', controller.replyError.value);
                  }
                },
                child: sending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Send'),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: _statusColor, width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Text(
                  isReplied ? 'Replied' : 'Pending',
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(message, style: TextStyle(fontSize: 13.sp)),
            SizedBox(height: 6.h),
            if (studentName != null)
              Text('Student: $studentName',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            if (className != null || section != null)
              Text('Class: ${className ?? '-'} ${section ?? ''}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            if (createDate != null)
              Text('Date: ${createDate!.toLocal()}'.split('.').first,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            if (isReplied && reply != null && reply!.isNotEmpty) ...[
              const Divider(),
              Text(
                'Reply: $reply',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            if (!isReplied) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openReplyDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF97144D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: const Icon(Icons.reply, size: 16, color: Colors.white),
                  label: Text(
                    'Reply',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 10.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}