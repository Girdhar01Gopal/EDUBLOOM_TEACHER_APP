import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/staff_detail_conroller.dart';
import '../models/staff_detail_model.dart';

// Axis Bank brand color (maroon) — replaces teal everywhere in this file
const Color kAxisMaroon = Color(0xFF97144D);

class StaffDetailScreen extends GetView<StaffDetailController> {
  const StaffDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: kAxisMaroon,
        foregroundColor: Colors.white,
        title: const Text(
          'Staff Detail',
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
              onPressed: controller.fetchStaffDetail,
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
                  onPressed: controller.fetchStaffDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final s = controller.staffDetail.value;
        if (s == null) return const Center(child: Text("No data found"));

        return _StaffDetailBody(staff: s, ctrl: controller);
      }),
    );
  }
}

class _StaffDetailBody extends StatelessWidget {
  final StaffDetailModel staff;
  final StaffDetailController ctrl;

  const _StaffDetailBody({required this.staff, required this.ctrl});

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
              // ── Profile Card ─────────────────────────────────────────────
              _card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfilePic(
                      imageUrl: ctrl.imageUrl(staff.staffPic),
                      name: staff.name ?? '',
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (staff.name ?? '-').trim(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (staff.staffReg != null) _Badge(text: staff.staffReg!),
                          const SizedBox(height: 6),
                          if (staff.staffType != null)
                            Text(
                              staff.staffType!.trim(),
                              style: TextStyle(
                                fontSize: 14,
                                color: kAxisMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          _StatusChip(isActive: staff.isActive ?? true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Document thumbnails ──────────────────────────────────────
              if (_hasAnyDoc(staff)) _DocumentsRow(staff: staff, ctrl: ctrl),

              if (_hasAnyDoc(staff)) const SizedBox(height: 14),

              // ── Personal Information ─────────────────────────────────────
              _SectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _InfoRow('Father / Husband', staff.fhname),
                  _InfoRow('Date of Birth', ctrl.formatDate(staff.dob)),
                  _InfoRow('Gender', staff.gender),
                  _InfoRow('Blood Group', staff.bloodGroup),
                  _InfoRow('Caste', staff.caste),
                  // _InfoRow('Aadhar No', staff.aadharNo),
                ],
              ),

              const SizedBox(height: 12),

              // ── Contact Information ──────────────────────────────────────
              _SectionCard(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
                children: [
                  _InfoRow('Mobile No', staff.mobileNo),
                  _InfoRow('E-Mail', staff.emailid),
                  _InfoRow('Address', staff.address),
                  _InfoRow('City', staff.city),
                  _InfoRow('State', staff.state),
                ],
              ),

              const SizedBox(height: 12),

              // ── Professional Information ─────────────────────────────────
              _SectionCard(
                title: 'Professional Information',
                icon: Icons.work_outline,
                children: [
                  _InfoRow('Staff Type', staff.staffType),
                  // _InfoRow('Qualification', staff.qualification),
                  // _InfoRow('Specialization', staff.specialization),
                  // _InfoRow('Last Organization', staff.lastOrganization),
                  // _InfoRow('Total Experience',
                  //     staff.totalExperience != null ? '${staff.totalExperience} years' : null),
                  _InfoRow('Date of Joining', ctrl.formatDate(staff.dateofJoining)),
                  _InfoRow('Licence No', staff.licenceNo),
                  // _InfoRow('Salary',
                  //     staff.salary != null ? '₹ ${staff.salary}' : null),
                ],
              ),

              // const SizedBox(height: 12),
              //
              // // ── Bank Details ─────────────────────────────────────────────
              // _SectionCard(
              //   title: 'Bank Details',
              //   icon: Icons.account_balance_outlined,
              //   children: [
              //     _InfoRow('Bank Name', staff.bankName),
              //     _InfoRow('Account No', staff.accountNo),
              //     _InfoRow('IFSC Code', staff.ifsccode),
              //   ],
              // ),

              // const SizedBox(height: 12),
              //
              // // ── Login Credentials ────────────────────────────────────────
              // _SectionCard(
              //   title: 'Login Credentials',
              //   icon: Icons.lock_outline,
              //   children: [
              //     _InfoRow('User ID', staff.userName),
              //     _InfoRow('Password', staff.password ?? staff.tpassword),
              //   ],
              // ),

              const SizedBox(height: 12),

              // ── Record Info ──────────────────────────────────────────────
              _SectionCard(
                title: 'Record Info',
                icon: Icons.history_outlined,
                children: [
                  // _InfoRow('Created By', staff.createBy),
                  _InfoRow('Create Date', ctrl.formatDate(staff.createDate)),
                  // _InfoRow('Updated By', staff.updateBy),
                  _InfoRow('Update Date', ctrl.formatDate(staff.updateDate)),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAnyDoc(StaffDetailModel s) =>
      (s.idproof?.trim().isNotEmpty ?? false) ||
          (s.licenceImages?.trim().isNotEmpty ?? false) ||
          (s.callLetter?.trim().isNotEmpty ?? false);
}

// ── Shared card wrapper ────────────────────────────────────────────────────────
Widget _card({required Widget child}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

// ── Profile Picture ────────────────────────────────────────────────────────────
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
          ? () => showDialog(
        context: context,
        builder: (_) => _ZoomableImageDialog(url: imageUrl!, title: name),
      )
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
}

class _AvatarFallback extends StatelessWidget {
  final String initials;
  const _AvatarFallback({required this.initials});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: kAxisMaroon.withOpacity(0.12),
        borderRadius: BorderRadius.circular(60),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kAxisMaroon),
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
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(60)),
      alignment: Alignment.center,
      child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
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
        color: kAxisMaroon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAxisMaroon.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: kAxisMaroon, fontWeight: FontWeight.w600),
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
        border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200),
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

// ── Documents Row ──────────────────────────────────────────────────────────────
class _DocumentsRow extends StatelessWidget {
  final StaffDetailModel staff;
  final StaffDetailController ctrl;
  const _DocumentsRow({required this.staff, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final docs = <Map<String, String?>>[];
    if (staff.idproof?.trim().isNotEmpty ?? false)
      docs.add({'label': 'ID Proof', 'url': ctrl.imageUrl(staff.idproof)});
    if (staff.licenceImages?.trim().isNotEmpty ?? false)
      docs.add({'label': 'Licence', 'url': ctrl.imageUrl(staff.licenceImages)});
    if (staff.callLetter?.trim().isNotEmpty ?? false)
      docs.add({'label': 'Call Letter', 'url': ctrl.imageUrl(staff.callLetter)});

    if (docs.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: kAxisMaroon),
              const SizedBox(width: 6),
              Text(
                'Documents',
                style: TextStyle(fontWeight: FontWeight.w700, color: kAxisMaroon, fontSize: 14),
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
      onTap: url != null ? () => _onTap(context, url!, label, isPdf) : null,
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
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
              )
                  : Icon(Icons.image_outlined, color: Colors.grey.shade400)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _onTap(BuildContext context, String url, String title, bool isPdf) async {
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
      return;
    }

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
  const _SectionCard({required this.title, required this.icon, required this.children});

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
                Icon(icon, size: 18, color: kAxisMaroon),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kAxisMaroon),
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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              (value == null || value!.trim().isEmpty) ? '-' : value!.trim(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}