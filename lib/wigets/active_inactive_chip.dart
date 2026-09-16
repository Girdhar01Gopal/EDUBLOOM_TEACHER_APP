import 'package:flutter/material.dart';

/// Reads a backend "action" field (String "1"/"0", "Active"/"Inactive", or int 1/0)
/// the same way the rest of the app already does for Student/Staff/Teacher.
bool parseIsActive(dynamic action) {
  final v = action?.toString().trim().toLowerCase() ?? '';
  return v == '1' || v == 'active' || v == 'true';
}

/// Called when a screen has no backend endpoint yet to persist the toggle.
/// Currently a no-op (snackbar disabled) — flip this back on, or wire the
/// real API in, once the backend endpoint for [moduleName] exists.
void showActiveInactiveApiPending(String moduleName) {}

/// Same pill used for Student/Staff/Teacher Active/Inactive status, reused
/// everywhere else so every list looks and behaves consistently.
class ActiveInactiveChip extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const ActiveInactiveChip({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF43A047) : Colors.red.shade400;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
