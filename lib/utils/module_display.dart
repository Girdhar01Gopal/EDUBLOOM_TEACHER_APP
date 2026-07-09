import 'package:flutter/material.dart';
import '../infrastructures/routes/page_constants.dart';

/// How a module tile should look and where it should navigate, keyed by the
/// API's `activityName` for a top-level module (see GetUserAccessApp).
class ModuleDisplayMeta {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String emoji;
  final String? route;
  final String? label; // custom display text; falls back to activityName if null
  final bool hidden;    // if true, don't render as its own tile (duplicate/merged entry)

  const ModuleDisplayMeta({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.emoji = '',
    this.route,
    this.label,
    this.hidden = false,
  });
}

const Map<String, ModuleDisplayMeta> moduleDisplayMeta = {
  'Dashboard': ModuleDisplayMeta(
      icon: Icons.dashboard_rounded, color: Color(0xFF00897B), bgColor: Color(0xFFE0F2F1),
      emoji: '🏠', route: RouteName.dashboard_screen, label: "Dashboard"),
  'Master': ModuleDisplayMeta(
      icon: Icons.tune_rounded, color: Color(0xFF3949AB), bgColor: Color(0xFFE8EAF6),
      emoji: '⚙️', route: RouteName.master, label: "Master's"),
  'Student': ModuleDisplayMeta(
      icon: Icons.groups_rounded, color: Color(0xFF1E88E5), bgColor: Color(0xFFE3F2FD),
      emoji: '🎓', route: RouteName.addstudentmaster, label: "Student's"),
  'Teachers': ModuleDisplayMeta(
      icon: Icons.person_pin_rounded, color: Color(0xFF43A047), bgColor: Color(0xFFE8F5E9),
      emoji: '👩‍🏫', route: RouteName.teacher, label: "Teacher's"),
  'Staff': ModuleDisplayMeta(
      icon: Icons.people_alt_rounded, color: Color(0xFF6D4C41), bgColor: Color(0xFFEFEBE9),
      emoji: '🪪', route: RouteName.staffView, label: "Staff"),
  'FeePayments': ModuleDisplayMeta(
      icon: Icons.account_balance_wallet_rounded, color: Color(0xFFFFB300), bgColor: Color(0xFFFFF8E1),
      emoji: '💰', route: RouteName.feesmaster, label: "Fee's"),
  'FeePaymentDaycare': ModuleDisplayMeta(
      icon: Icons.account_balance_wallet_rounded, color: Color(0xFFFFB300), bgColor: Color(0xFFFFF8E1),
      emoji: '💰', route: RouteName.feesmaster, hidden: true),
  'DailyActivity': ModuleDisplayMeta(
      icon: Icons.directions_run_rounded, color: Color(0xFF14B8A6), bgColor: Color(0xFFE0F2F1),
      emoji: '🎨', route: RouteName.activitymaster, label: "Activity's"),
  'Communication': ModuleDisplayMeta(
      icon: Icons.forum_rounded, color: Color(0xFF8E24AA), bgColor: Color(0xFFF3E5F5),
      emoji: '💬', route: RouteName.communicationview, label: "Communication's"),
  'Gallery': ModuleDisplayMeta(
      icon: Icons.photo_library_rounded, color: Color(0xFF00ACC1), bgColor: Color(0xFFE0F7FA),
      emoji: '🖼️', route: RouteName.activitymaster, hidden: true),
  'FrontDesk': ModuleDisplayMeta(
      icon: Icons.meeting_room_rounded, color: Color(0xFF00838F), bgColor: Color(0xFFE0F7FA),
      emoji: '🛎️'),
  'Product': ModuleDisplayMeta(
      icon: Icons.inventory_2_rounded, color: Color(0xFF546E7A), bgColor: Color(0xFFECEFF1),
      emoji: '📦', route: RouteName.products, label: "Product's"),
  'Certification': ModuleDisplayMeta(
      icon: Icons.workspace_premium_rounded, color: Color(0xFF6D4C41), bgColor: Color(0xFFEFEBE9),
      emoji: '📜', route: RouteName.mastercertificate, label: "Certification's"),
  'Expenses': ModuleDisplayMeta(
      icon: Icons.receipt_long_rounded, color: Color(0xFFD81B60), bgColor: Color(0xFFFCE4EC),
      emoji: '🧾', route: RouteName.masterexpenses, label: "Expense's"),
  'Report': ModuleDisplayMeta(
      icon: Icons.insert_chart_rounded, color: Color(0xFFE53935), bgColor: Color(0xFFFFEBEE),
      emoji: '📊', route: RouteName.reports, label: "Report's"),
  'User': ModuleDisplayMeta(
      icon: Icons.manage_accounts_rounded, color: Color(0xFF8E24AA), bgColor: Color(0xFFECEFF1),
      emoji: '👤', route: RouteName.userdetails, label: "User Access"),
  'Result': ModuleDisplayMeta(
      icon: Icons.emoji_events_rounded, color: Color(0xFFF43F5E), bgColor: Color(0xFFFDECEF),
      emoji: '🏆', route: RouteName.results, label: "Result's"),
  'Leads': ModuleDisplayMeta(
      icon: Icons.trending_up_rounded, color: Color(0xFF0EA5E9), bgColor: Color(0xFFE0F2FE),
      emoji: '📈'),
};

const ModuleDisplayMeta defaultModuleDisplayMeta = ModuleDisplayMeta(
  icon: Icons.apps_rounded,
  color: Color(0xFF64748B),
  bgColor: Color(0xFFF1F5F9),
  emoji: '🔷',
);

ModuleDisplayMeta displayMetaFor(String activityName) =>
    moduleDisplayMeta[activityName] ?? defaultModuleDisplayMeta;

/// Text to show on the tile — uses `label` if set, else the raw activityName.
String displayLabelFor(String activityName) =>
    displayMetaFor(activityName).label ?? activityName;