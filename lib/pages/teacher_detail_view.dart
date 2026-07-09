import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/teacher_detail_controller.dart';
import '../models/teacher_detail_model.dart';

class TeacherDetailScreen extends GetView<TeacherDetailController> {
  const TeacherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TeacherDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF97144D),
        foregroundColor: Colors.white,
        title: const Text(
          'Teacher Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: controller.fetchTeacherDetail,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(
                  controller.errorMsg.value,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.fetchTeacherDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final t = controller.teacherDetail.value;
        if (t == null) return const Center(child: Text("No data found"));

        return _TeacherDetailBody(teacher: t, ctrl: controller);
      }),
    );
  }
}

class _TeacherDetailBody extends StatelessWidget {
  final TeacherDetailView teacher;
  final TeacherDetailController ctrl;

  const _TeacherDetailBody({required this.teacher, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile + Document Images row ──────────────────────────
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile picture — tappable & zoomable
                      _ProfilePic(
                        imageUrl: ctrl.imageUrl(teacher.teacherPic),
                        name: teacher.name ?? '',
                      ),
                      const SizedBox(width: 20),
                      // Name + reg
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name ?? '-',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _Badge(text: teacher.teacherReg ?? '-'),
                            const SizedBox(height: 6),
                            if (teacher.designation != null)
                              Text(
                                teacher.designation!.trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFA83262),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 4),
                            _StatusChip(isActive: teacher.isActive ?? false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Document thumbnails ────────────────────────────────────
              if (_hasAnyDoc(teacher))
                _DocumentsRow(teacher: teacher, ctrl: ctrl),

              const SizedBox(height: 14),

              // ── Info sections ─────────────────────────────────────────
              _SectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _InfoRow('Father / Husband', teacher.fhname),
                  _InfoRow('Date of Birth', _fmt(teacher.dob)),
                  _InfoRow('Gender', teacher.gender),
                  _InfoRow('Blood Group', teacher.bloodGroup),
                  _InfoRow('Caste', teacher.caste),
                ],
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
                children: [
                  _InfoRow('Mobile No', teacher.mobileNo),
                  _InfoRow('E-Mail', teacher.emailid),
                  _InfoRow('Address', teacher.address),
                  _InfoRow('City', teacher.city),
                  _InfoRow('State', teacher.state),
                ],
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Professional Information',
                icon: Icons.work_outline,
                children: [
                  _InfoRow('Qualification', teacher.qualification),
                  _InfoRow('Specialization', teacher.specialization),
                  _InfoRow('Last Organization', teacher.lastOrganization),
                  _InfoRow('Total Experience', teacher.totalExperience != null
                      ? '${teacher.totalExperience} years'
                      : null),
                  _InfoRow('Designation', teacher.designation?.trim()),
                  _InfoRow('Date of Joining', _fmt(teacher.dateofJoining)),
                  _InfoRow('Salary', teacher.salary != null
                      ? '₹ ${teacher.salary}'
                      : null),
                ],
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Bank Details',
                icon: Icons.account_balance_outlined,
                children: [
                  _InfoRow('Bank Name', teacher.bankName),
                  _InfoRow('Account No', teacher.accountNo),
                  _InfoRow('IFSC Code', teacher.ifsccode),
                ],
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Record Info',
                icon: Icons.history_outlined,
                children: [
                  //_InfoRow('Created By', teacher.createBy),
                  _InfoRow('Create Date', _fmt(teacher.createDate)),
                  //_InfoRow('Updated By', teacher.updateBy),
                  _InfoRow('Update Date', _fmt(teacher.updateDate)),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAnyDoc(TeacherDetailView t) =>
      (t.idproof?.trim().isNotEmpty ?? false) ||
          (t.resume?.trim().isNotEmpty ?? false) ||
          (t.callLetter?.trim().isNotEmpty ?? false);

  String? _fmt(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.day.toString().padLeft(2, '0')}-${_m(dt.month)}-${dt.year}';
  }

  String _m(int m) {
    const mm = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    if (m < 1 || m > 12) return 'NA';
    return mm[m - 1];
  }
}

// ── Profile Picture Widget ─────────────────────────────────────────────────────
class _ProfilePic extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _ProfilePic({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
        : '?';

    return GestureDetector(
      onTap: imageUrl != null
          ? () => _showZoomableImage(context, imageUrl!, name)
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: imageUrl != null
            ? Image.network(
          imageUrl!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _AvatarFallback(initials: initials),
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : _LoadingAvatar(),
        )
            : _AvatarFallback(initials: initials),
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (_) => _ZoomableImageDialog(url: url, title: title),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;
  const _AvatarFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFF3D2DE),
        borderRadius: BorderRadius.all(Radius.circular(60)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF97144D),
        ),
      ),
    );
  }
}

class _LoadingAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(60),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
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

// ── Badge ──────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8AFC4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF97144D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Status Chip ────────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Document Thumbnails Row ────────────────────────────────────────────────────
class _DocumentsRow extends StatelessWidget {
  final TeacherDetailView teacher;
  final TeacherDetailController ctrl;

  const _DocumentsRow({required this.teacher, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final docs = <Map<String, String?>>[];
    if (teacher.idproof?.trim().isNotEmpty ?? false)
      docs.add({'label': 'ID Proof', 'url': ctrl.imageUrl(teacher.idproof)});
    if (teacher.resume?.trim().isNotEmpty ?? false)
      docs.add({'label': 'Resume', 'url': ctrl.imageUrl(teacher.resume)});
    if (teacher.callLetter?.trim().isNotEmpty ?? false)
      docs.add({'label': 'Call Letter', 'url': ctrl.imageUrl(teacher.callLetter)});

    if (docs.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, size: 18, color: Color(0xFFA83262)),
                const SizedBox(width: 6),
                const Text(
                  'Documents',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF97144D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: docs.map((d) => _DocThumb(label: d['label']!, url: d['url'])).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocThumb extends StatelessWidget {
  final String label;
  final String? url;

  const _DocThumb({required this.label, this.url});

  @override
  Widget build(BuildContext context) {
    final isPdf = url?.toLowerCase().endsWith('.pdf') ?? false;

    return GestureDetector(
      onTap: url != null
          ? () => _onTap(context, url!, label, isPdf)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade100,
              child: isPdf
                  ? Icon(Icons.picture_as_pdf, size: 36, color: Colors.red.shade400)
                  : (url != null
                  ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade400,
                ),
              )
                  : Icon(Icons.image_outlined, color: Colors.grey.shade400)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _onTap(BuildContext context, String url, String title, bool isPdf) async {
    if (isPdf) {
      // Open PDF in browser / external viewer
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
      return;
    }

    // Show zoomable image dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => _ZoomableImageDialog(url: url, title: title),
      );
    }
  }
}

// ── Section Card ───────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFFA83262)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF97144D),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Info Row ───────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              (value == null || value!.trim().isEmpty) ? '-' : value!.trim(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}