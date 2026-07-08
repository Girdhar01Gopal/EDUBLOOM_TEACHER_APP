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

  const ModuleDisplayMeta({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.emoji = '',
    this.route,
  });
}

const Map<String, ModuleDisplayMeta> moduleDisplayMeta = {
  'Dashboard': ModuleDisplayMeta(
      icon: Icons.dashboard_rounded, color: Color(0xFF00897B), bgColor: Color(0xFFE0F2F1),
      emoji: '🏠', route: RouteName.dashboard_screen),
  'Master': ModuleDisplayMeta(
      icon: Icons.tune_rounded, color: Color(0xFF3949AB), bgColor: Color(0xFFE8EAF6),
      emoji: '⚙️', route: RouteName.master),
  'Student': ModuleDisplayMeta(
      icon: Icons.groups_rounded, color: Color(0xFF1E88E5), bgColor: Color(0xFFE3F2FD),
      emoji: '🎓', route: RouteName.addstudentmaster),
  'Teachers': ModuleDisplayMeta(
      icon: Icons.person_pin_rounded, color: Color(0xFF43A047), bgColor: Color(0xFFE8F5E9),
      emoji: '👩‍🏫', route: RouteName.teacher),
  'Staff': ModuleDisplayMeta(
      icon: Icons.people_alt_rounded, color: Color(0xFF6D4C41), bgColor: Color(0xFFEFEBE9),
      emoji: '🪪', route: RouteName.staffView),
  'FeePayments': ModuleDisplayMeta(
      icon: Icons.account_balance_wallet_rounded, color: Color(0xFFFFB300), bgColor: Color(0xFFFFF8E1),
      emoji: '💰', route: RouteName.feesmaster),
  'FeePaymentDaycare': ModuleDisplayMeta(
      icon: Icons.account_balance_wallet_rounded, color: Color(0xFFFFB300), bgColor: Color(0xFFFFF8E1),
      emoji: '💰', route: RouteName.feesmaster),
  'DailyActivity': ModuleDisplayMeta(
      icon: Icons.directions_run_rounded, color: Color(0xFF14B8A6), bgColor: Color(0xFFE0F2F1),
      emoji: '🎨', route: RouteName.activitymaster),
  'Communication': ModuleDisplayMeta(
      icon: Icons.forum_rounded, color: Color(0xFF8E24AA), bgColor: Color(0xFFF3E5F5),
      emoji: '💬', route: RouteName.communicationview),
  'Gallery': ModuleDisplayMeta(
      icon: Icons.photo_library_rounded, color: Color(0xFF00ACC1), bgColor: Color(0xFFE0F7FA),
      emoji: '🖼️'),
  'FrontDesk': ModuleDisplayMeta(
      icon: Icons.meeting_room_rounded, color: Color(0xFF00838F), bgColor: Color(0xFFE0F7FA),
      emoji: '🛎️'),
  'Product': ModuleDisplayMeta(
      icon: Icons.inventory_2_rounded, color: Color(0xFF546E7A), bgColor: Color(0xFFECEFF1),
      emoji: '📦', route: RouteName.products),
  'Certification': ModuleDisplayMeta(
      icon: Icons.workspace_premium_rounded, color: Color(0xFF6D4C41), bgColor: Color(0xFFEFEBE9),
      emoji: '📜', route: RouteName.mastercertificate),
  'Expenses': ModuleDisplayMeta(
      icon: Icons.receipt_long_rounded, color: Color(0xFFD81B60), bgColor: Color(0xFFFCE4EC),
      emoji: '🧾', route: RouteName.masterexpenses),
  'Report': ModuleDisplayMeta(
      icon: Icons.insert_chart_rounded, color: Color(0xFFE53935), bgColor: Color(0xFFFFEBEE),
      emoji: '📊', route: RouteName.reports),
  'User': ModuleDisplayMeta(
      icon: Icons.manage_accounts_rounded, color: Color(0xFF8E24AA), bgColor: Color(0xFFECEFF1),
      emoji: '👤', route: RouteName.userdetails),
  'Result': ModuleDisplayMeta(
      icon: Icons.emoji_events_rounded, color: Color(0xFFF43F5E), bgColor: Color(0xFFFDECEF),
      emoji: '🏆', route: RouteName.results),
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
