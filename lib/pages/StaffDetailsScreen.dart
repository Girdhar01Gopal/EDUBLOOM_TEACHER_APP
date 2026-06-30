import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/StaffDetailsController.dart';

class StaffDetailsScreen extends StatelessWidget {
  StaffDetailsScreen({super.key});

  final StaffDetailsController controller = Get.put(StaffDetailsController());

  void copyToClipboard(String title, String value) {
    if (value.trim().isEmpty || value == "-") return;

    Clipboard.setData(ClipboardData(text: value));

    Get.snackbar(
      "Copied",
      "$title copied",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(10),
    );
  }

  Widget detailRow(String title, String value, {bool enableCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (enableCopy && value != "-")
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => copyToClipboard(title, value),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fileChip({
    required String title,
    required bool visible,
    required VoidCallback onTap,
  }) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.insert_drive_file_outlined,
                size: 20,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// PDF → browser mein open, image → zoomable dialog
  Future<void> openFile(BuildContext context, String title, String url) async {
    if (url.trim().isEmpty) return;

    final isPdf = url.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open PDF: $url')),
          );
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => _ZoomableImageDialog(url: url, title: title),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      appBar: AppBar(
        title: const Text(
          "Staff details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final staff = controller.staffData.value;

        if (staff == null) {
          return RefreshIndicator(
            onRefresh: controller.fetchStaffDetails,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: Text("No staff data found")),
              ],
            ),
          );
        }

        final imageUrl = controller.getFullImageUrl(staff.staffPic);
        final idProofUrl = controller.getFullImageUrl(staff.idproof);
        final resumeUrl = controller.getFullImageUrl(staff.callLetter);

        return RefreshIndicator(
          onRefresh: controller.fetchStaffDetails,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Me",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Profile pic — tap to zoom ──────────────────────
                      GestureDetector(
                        onTap: imageUrl.isNotEmpty
                            ? () => showDialog(
                          context: context,
                          builder: (_) => _ZoomableImageDialog(
                            url: imageUrl,
                            title: controller.valueOrDash(staff.name),
                          ),
                        )
                            : null,
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade100,
                          ),
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, size: 40),
                            ),
                          )
                              : const Icon(Icons.person, size: 40),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // ── Document chips ─────────────────────────────────
                      Column(
                        children: [
                          fileChip(
                            title: "Idproof",
                            visible: controller.hasFile(staff.idproof),
                            onTap: () => openFile(context, "ID Proof", idProofUrl),
                          ),
                          fileChip(
                            title: "Resume",
                            visible: controller.hasFile(staff.callLetter),
                            onTap: () => openFile(context, "Resume", resumeUrl),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    controller.valueOrDash(staff.name),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  detailRow("Name", controller.valueOrDash(staff.name)),
                  detailRow("Staff Type", controller.valueOrDash(staff.staffType)),
                  detailRow("Gender", controller.valueOrDash(staff.gender)),
                  detailRow("Father Name", controller.valueOrDash(staff.fhname)),
                  detailRow("Date Of Birth", controller.formatDate(staff.dob)),
                  detailRow("Blood Group", controller.valueOrDash(staff.bloodGroup)),
                  detailRow("Email", controller.valueOrDash(staff.emailid), enableCopy: true),
                  detailRow("Joining Date", controller.formatDate(staff.dateofJoining)),
                  detailRow("Mobile No", controller.valueOrDash(staff.mobileNo), enableCopy: true),
                  detailRow("Address", controller.valueOrDash(staff.address), enableCopy: true),
                  detailRow("City", controller.valueOrDash(staff.city)),
                  detailRow("UserId", controller.valueOrDash(staff.userName), enableCopy: true),
                  detailRow("Password", controller.valueOrDash(staff.password), enableCopy: true),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Zoomable Image Dialog ──────────────────────────────────────────────────────
class _ZoomableImageDialog extends StatelessWidget {
  final String url;
  final String title;

  const _ZoomableImageDialog({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Flexible(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Image failed to load',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Pinch to zoom • Drag to pan',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}