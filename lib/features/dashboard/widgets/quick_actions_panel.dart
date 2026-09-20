import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionsPanel extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onAddStudent;
  final VoidCallback? onAddSubject;
  final VoidCallback? onEnterMarks;
  final VoidCallback? onGenerateReport;
  final VoidCallback? onOpenDepartments;
  final VoidCallback? onOpenFaculty;
  final VoidCallback? onOpenCareer;

  const QuickActionsPanel({
    super.key,
    this.isAdmin = false,
    this.onAddStudent,
    this.onAddSubject,
    this.onEnterMarks,
    this.onGenerateReport,
    this.onOpenDepartments,
    this.onOpenFaculty,
    this.onOpenCareer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Admin Quick Actions' : 'Faculty Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),

            if (isAdmin) ...[
              _buildActionButton(
                title: 'Department Hub',
                icon: Icons.apartment_rounded,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: onOpenDepartments,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Faculty Directory',
                icon: Icons.school_rounded,
                color: const Color(0xFF0D9488),
                bgColor: const Color(0xFFF0FDFA),
                onTap: onOpenFaculty,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Add New Student',
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                bgColor: AppColors.infoBg,
                onTap: onAddStudent,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Career & Job Matches',
                icon: Icons.work_outline_rounded,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                onTap: onOpenCareer,
              ),
            ] else ...[
              _buildActionButton(
                title: 'Enter Marks',
                icon: Icons.edit_calendar_rounded,
                color: AppColors.warning,
                bgColor: AppColors.warningBg,
                onTap: onEnterMarks,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Manage Students',
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                bgColor: AppColors.infoBg,
                onTap: onAddStudent,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Career & Job Matches',
                icon: Icons.work_outline_rounded,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                onTap: onOpenCareer,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Performance Report',
                icon: Icons.assessment_rounded,
                color: AppColors.purple,
                bgColor: AppColors.purpleBg,
                onTap: onGenerateReport,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: bgColor.withOpacity(0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
