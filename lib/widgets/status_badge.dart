import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? bgColor;
  final bool isPass;
  final bool isGrade;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.bgColor,
    this.isPass = false,
    this.isGrade = false,
  });

  factory StatusBadge.result(String result) {
    final pass = result.toLowerCase() == 'pass';
    return StatusBadge(
      text: result,
      color: pass ? AppColors.success : AppColors.error,
      bgColor: pass ? AppColors.successBg : AppColors.errorBg,
      isPass: pass,
    );
  }

  factory StatusBadge.role(String role) {
    final isAdmin = role.toLowerCase() == 'admin';
    return StatusBadge(
      text: role,
      color: isAdmin ? AppColors.primary : AppColors.purple,
      bgColor: isAdmin ? AppColors.infoBg : AppColors.purpleBg,
    );
  }

  factory StatusBadge.grade(String grade) {
    Color c;
    Color bg;
    if (grade.startsWith('A') || grade == 'O') {
      c = AppColors.success;
      bg = AppColors.successBg;
    } else if (grade.startsWith('B')) {
      c = AppColors.primary;
      bg = AppColors.infoBg;
    } else if (grade == 'C' || grade == 'P') {
      c = AppColors.warning;
      bg = AppColors.warningBg;
    } else {
      c = AppColors.error;
      bg = AppColors.errorBg;
    }
    return StatusBadge(
      text: grade,
      color: c,
      bgColor: bg,
      isGrade: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveBgColor = bgColor ?? AppColors.infoBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: effectiveColor.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: effectiveColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
