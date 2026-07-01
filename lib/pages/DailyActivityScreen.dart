import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/DailyActivityController.dart';

// ─────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────

const _kPrimary    = Color(0xFF97144D); // Axis Bank Maroon
const _kAccent     = Color(0xFFC2185B); // Maroon Accent
const _kDanger     = Color(0xFFEF4444); // Red
const _kYellow     = Color(0xFFF59E0B); // Amber (stars)
const _kBg         = Color(0xFFFDF0F5); // Maroon 50
const _kCard       = Color(0xFFFFFFFF);
const _kTextDark   = Color(0xFF4A0E29); // Maroon 900
const _kTextMuted  = Color(0xFF6B7280);
const _kBorder     = Color(0xFFF3CCDD); // Maroon 100

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class DailyActivityScreen extends GetView<DailyActivityController> {
  const DailyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _AppBar(),
          _TabBar(),
          Expanded(
            child: Obx(() => controller.currentTab.value == 0
                ? const _AddTab()
                : const _ViewTab()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────

class _AppBar extends GetView<DailyActivityController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF97144D), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Color(0x4097144D), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    _todayLabel(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.totalStudentsRated} Rated',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ─────────────────────────────────────────────
// TAB BAR
// ─────────────────────────────────────────────

class _TabBar extends GetView<DailyActivityController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(() => Row(
        children: [
          _TabButton(label: '➕  Add Activity', index: 0, selected: controller.currentTab.value == 0),
          const SizedBox(width: 12),
          _TabButton(label: '📊  View Report', index: 1, selected: controller.currentTab.value == 1),
        ],
      )),
    );
  }
}

class _TabButton extends GetView<DailyActivityController> {
  final String label;
  final int index;
  final bool selected;
  const _TabButton({required this.label, required this.index, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.currentTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? _kPrimary : _kBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _kTextMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// ADD TAB
// ═════════════════════════════════════════════

class _AddTab extends GetView<DailyActivityController> {
  const _AddTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Section 1: School Type + Class ──
          _SectionCard(
            title: 'School Type & Class',
            icon: Icons.school_rounded,
            child: Column(
              children: [
                // School Type Dropdown
                Obx(() => _StyledDropdown<String>(
                  label: 'School Type',
                  hint: 'Select School Type',
                  icon: Icons.account_balance_rounded,
                  value: controller.selectedSchoolType.value,
                  items: const [
                    DropdownMenuItem(value: 'daycare',   child: Text('🧸  Day Care')),
                    DropdownMenuItem(value: 'preschool', child: Text('🎒  Pre School')),
                  ],
                  onChanged: (v) { if (v != null) controller.onSchoolTypeChanged(v); },
                )),
                const SizedBox(height: 14),
                // Class Dropdown (preschool only)
                Obx(() {
                  if (controller.selectedSchoolType.value == 'daycare') {
                    return const SizedBox.shrink();
                  }
                  return _StyledDropdown<String>(
                    label: 'Class',
                    hint: 'Select Class',
                    icon: Icons.class_rounded,
                    value: controller.selectedClass.value.isEmpty ? null : controller.selectedClass.value,
                    items: controller.classOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) { if (v != null) controller.onClassChanged(v); },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Section 2: Students ──
          _SectionCard(
            title: 'Select Student',
            icon: Icons.people_rounded,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: _kPrimary)),
                );
              }
              if (controller.displayedStudents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('please select school type first', style: TextStyle(color: _kTextMuted)),
                );
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.displayedStudents
                    .map((s) => _StudentChip(student: s))
                    .toList(),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Section 3: Activity Details ──
          Obx(() {
            if (controller.selectedStudent.value == null) return const SizedBox.shrink();
            return Column(
              children: [
                // Remark
                _SectionCard(
                  title: 'Remark',
                  icon: Icons.comment_rounded,
                  child: TextField(
                    onChanged: controller.onRemarkChanged,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: _kTextDark),
                    decoration: InputDecoration(
                      hintText: 'please write remark for today...',
                      hintStyle: TextStyle(color: _kTextMuted, fontSize: 13),
                      filled: true,
                      fillColor: _kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kPrimary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stars Rating
                _SectionCard(
                  title: 'Star Rating',
                  icon: Icons.star_rounded,
                  child: Obx(() => _StarRating(
                    value: controller.stars.value,
                    onTap: controller.onStarTapped,
                  )),
                ),
                const SizedBox(height: 16),

                // Mood
                _SectionCard(
                  title: 'Mood',
                  icon: Icons.mood_rounded,
                  child: Obx(() => Row(
                    children: [
                      _MoodChip(label: '😊  Good', value: 'good', selected: controller.mood.value == 'good', color: _kAccent),
                      const SizedBox(width: 12),
                      _MoodChip(label: '😔  Bad',  value: 'bad',  selected: controller.mood.value == 'bad',  color: _kDanger),
                    ],
                  )),
                ),
                const SizedBox(height: 16),

                // IQ Level
                _SectionCard(
                  title: 'IQ Level',
                  icon: Icons.psychology_rounded,
                  child: Obx(() => _LevelSelector(
                    value: controller.iqLevel.value,
                    labels: const ['Very Low', 'Low', 'Average', 'High', 'Excellent'],
                    onTap: controller.onIqLevelChanged,
                    color: const Color(0xFF97144D),
                  )),
                ),
                const SizedBox(height: 16),

                // Learning Skill
                _SectionCard(
                  title: 'Learning Skill',
                  icon: Icons.auto_awesome_rounded,
                  child: Obx(() => _LevelSelector(
                    value: controller.learningSkill.value,
                    labels: const ['Beginner', 'Basic', 'Developing', 'Good', 'Advanced'],
                    onTap: controller.onLearningSkillChanged,
                    color: _kAccent,
                  )),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Obx(() => GestureDetector(
                  onTap: controller.canSubmit ? controller.submitActivity : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: controller.canSubmit
                          ? const LinearGradient(colors: [Color(0xFF97144D), Color(0xFFC2185B)])
                          : null,
                      color: controller.canSubmit ? null : _kBorder,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: controller.canSubmit
                          ? [const BoxShadow(color: Color(0x5097144D), blurRadius: 12, offset: Offset(0, 4))]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save_rounded, color: controller.canSubmit ? Colors.white : _kTextMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Save Activity',
                          style: TextStyle(
                            color: controller.canSubmit ? Colors.white : _kTextMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 32),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// VIEW TAB
// ═════════════════════════════════════════════

class _ViewTab extends GetView<DailyActivityController> {
  const _ViewTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insert_chart_outlined_rounded, size: 56, color: _kPrimary),
              ),
              const SizedBox(height: 20),
              const Text('no activity found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextDark)),
              const SizedBox(height: 6),
              Text('first add activity from add tab ', style: TextStyle(fontSize: 13, color: _kTextMuted)),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Summary Row ──
            Row(
              children: [
                _StatCard(value: '${controller.totalStudentsRated}', label: 'Total\nRated', icon: Icons.people_rounded, color: _kPrimary),
                const SizedBox(width: 12),
                _StatCard(value: controller.averageStars.toStringAsFixed(1), label: 'Avg\nStars', icon: Icons.star_rounded, color: _kYellow),
                const SizedBox(width: 12),
                _StatCard(value: '${controller.goodCount()}', label: 'Good\nMood', icon: Icons.mood_rounded, color: _kAccent),
                const SizedBox(width: 12),
                _StatCard(value: '${controller.badCount()}', label: 'Bad\nMood', icon: Icons.sentiment_dissatisfied_rounded, color: _kDanger),
              ],
            ),
            const SizedBox(height: 20),

            // ── Entry List ──
            ...controller.entries.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return _ActivityCard(entry: e, onDelete: () => controller.deleteEntry(i));
            }),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _kPrimary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextDark, letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _StyledDropdown({required this.label, required this.hint, required this.icon, this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(hint, style: TextStyle(color: _kTextMuted, fontSize: 13)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kPrimary),
              items: items,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: _kTextDark, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentChip extends GetView<DailyActivityController> {
  final StudentModel student;
  const _StudentChip({required this.student});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedStudent.value?.id == student.id;
      return GestureDetector(
        onTap: () => controller.onStudentSelected(student),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _kPrimary : _kBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? _kPrimary : _kBorder, width: 1.5),
            boxShadow: selected
                ? [const BoxShadow(color: Color(0x3597144D), blurRadius: 8, offset: Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: selected ? Colors.white.withOpacity(0.25) : _kPrimary.withOpacity(0.12),
                child: Text(
                  student.avatarInitials,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : _kPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                student.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _kTextDark,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onTap;
  const _StarRating({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onTap(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? _kYellow : _kBorder,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}

class _MoodChip extends GetView<DailyActivityController> {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  const _MoodChip({required this.label, required this.value, required this.selected, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onMoodSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : _kBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? color : _kTextMuted),
          ),
        ),
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final int value;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final Color color;
  const _LevelSelector({required this.value, required this.labels, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(5, (i) {
            final active = i < value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  height: 36,
                  decoration: BoxDecoration(
                    color: active ? color : _kBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? color : _kBorder, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: active ? Colors.white : _kTextMuted, fontSize: 13),
                  ),
                ),
              ),
            );
          }),
        ),
        if (value > 0) ...[
          const SizedBox(height: 8),
          Text(
            labels[value - 1],
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityEntry entry;
  final VoidCallback onDelete;
  const _ActivityCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const iqLabels = ['Very Low', 'Low', 'Average', 'High', 'Excellent'];
    const skillLabels = ['Beginner', 'Basic', 'Developing', 'Good', 'Advanced'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _kPrimary.withOpacity(0.1),
                child: Text(
                  entry.studentName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kTextDark)),
                    Text('${entry.className}  •  ${_timeLabel(entry.date)}',
                        style: const TextStyle(color: _kTextMuted, fontSize: 11)),
                  ],
                ),
              ),
              // Mood badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: entry.mood == 'good' ? _kAccent.withOpacity(0.1) : _kDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.mood == 'good' ? '😊 Good' : '😔 Bad',
                  style: TextStyle(
                    color: entry.mood == 'good' ? _kAccent : _kDanger,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded, color: _kDanger, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 12),

          // Stars
          Row(
            children: [
              const Text('Rating: ', style: TextStyle(color: _kTextMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              ...List.generate(5, (i) => Icon(
                i < entry.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < entry.stars ? _kYellow : _kBorder,
                size: 18,
              )),
            ],
          ),
          const SizedBox(height: 8),

          // Remark
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(8)),
            child: Text(
              '"${entry.remark}"',
              style: const TextStyle(fontSize: 12, color: _kTextDark, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 10),

          // IQ + Learning
          Row(
            children: [
              _MiniTag(
                label: 'IQ: ${iqLabels[entry.iqLevel - 1]}',
                color: const Color(0xFF97144D),
                icon: Icons.psychology_rounded,
              ),
              const SizedBox(width: 8),
              _MiniTag(
                label: 'Skill: ${skillLabels[entry.learningSkill - 1]}',
                color: _kAccent,
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniTag({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}