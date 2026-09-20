import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradeInfo {
  final String grade;
  final String description;
  final double gradePoint;
  final bool isPass;
  final Color color;
  final Color bgColor;

  const GradeInfo({
    required this.grade,
    required this.description,
    required this.gradePoint,
    required this.isPass,
    required this.color,
    required this.bgColor,
  });
}

class GradeCalculator {
  // Configurable passing threshold (in percentage)
  static const double passingPercentage = 40.0;

  static double calculatePercentage(double marksObtained, double maximumMarks) {
    if (maximumMarks <= 0) return 0.0;
    final percentage = (marksObtained / maximumMarks) * 100.0;
    return double.parse(percentage.toStringAsFixed(2));
  }

  static GradeInfo getGradeInfo(double percentage) {
    if (percentage >= 90.0) {
      return const GradeInfo(
        grade: 'A+',
        description: 'Outstanding',
        gradePoint: 10.0,
        isPass: true,
        color: AppColors.success,
        bgColor: AppColors.successBg,
      );
    } else if (percentage >= 80.0) {
      return const GradeInfo(
        grade: 'A',
        description: 'Excellent',
        gradePoint: 9.0,
        isPass: true,
        color: AppColors.success,
        bgColor: AppColors.successBg,
      );
    } else if (percentage >= 70.0) {
      return const GradeInfo(
        grade: 'B+',
        description: 'Very Good',
        gradePoint: 8.0,
        isPass: true,
        color: AppColors.primaryLight,
        bgColor: AppColors.infoBg,
      );
    } else if (percentage >= 60.0) {
      return const GradeInfo(
        grade: 'B',
        description: 'Good',
        gradePoint: 7.0,
        isPass: true,
        color: AppColors.primary,
        bgColor: AppColors.infoBg,
      );
    } else if (percentage >= 50.0) {
      return const GradeInfo(
        grade: 'C',
        description: 'Above Average',
        gradePoint: 6.0,
        isPass: true,
        color: AppColors.warning,
        bgColor: AppColors.warningBg,
      );
    } else if (percentage >= 40.0) {
      return const GradeInfo(
        grade: 'P',
        description: 'Pass',
        gradePoint: 5.0,
        isPass: true,
        color: AppColors.warning,
        bgColor: AppColors.warningBg,
      );
    } else {
      return const GradeInfo(
        grade: 'F',
        description: 'Fail',
        gradePoint: 0.0,
        isPass: false,
        color: AppColors.error,
        bgColor: AppColors.errorBg,
      );
    }
  }

  static String getGrade(double percentage) => getGradeInfo(percentage).grade;

  static String getResult(double percentage) {
    return percentage >= passingPercentage ? 'Pass' : 'Fail';
  }
}
