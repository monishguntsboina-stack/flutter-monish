import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'app_sidebar.dart';

class AppBottomNavBar extends StatelessWidget {
  final SidebarItem currentItem;
  final ValueChanged<SidebarItem> onItemSelected;
  final VoidCallback onMorePressed;

  const AppBottomNavBar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
    required this.onMorePressed,
  });

  bool _checkIsMoreActive(bool isAdmin) {
    if (isAdmin) {
      return currentItem == SidebarItem.subjects ||
          currentItem == SidebarItem.assessments ||
          currentItem == SidebarItem.marksEntry ||
          currentItem == SidebarItem.performance ||
          currentItem == SidebarItem.career ||
          currentItem == SidebarItem.reports ||
          currentItem == SidebarItem.profile;
    } else {
      return currentItem == SidebarItem.subjects ||
          currentItem == SidebarItem.assessments ||
          currentItem == SidebarItem.career ||
          currentItem == SidebarItem.reports ||
          currentItem == SidebarItem.profile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.currentUserModel?.isAdmin == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                inactiveIcon: Icons.dashboard_outlined,
                label: 'Home',
                isSelected: currentItem == SidebarItem.dashboard,
                onTap: () => onItemSelected(SidebarItem.dashboard),
              ),
              if (isAdmin) ...[
                _buildNavItem(
                  icon: Icons.apartment_rounded,
                  inactiveIcon: Icons.apartment_outlined,
                  label: 'Depts',
                  isSelected: currentItem == SidebarItem.departments,
                  onTap: () => onItemSelected(SidebarItem.departments),
                ),
                _buildNavItem(
                  icon: Icons.school_rounded,
                  inactiveIcon: Icons.school_outlined,
                  label: 'Faculty',
                  isSelected: currentItem == SidebarItem.faculty,
                  onTap: () => onItemSelected(SidebarItem.faculty),
                ),
              ] else ...[
                _buildNavItem(
                  icon: Icons.fact_check_rounded,
                  inactiveIcon: Icons.fact_check_outlined,
                  label: 'Marks',
                  isSelected: currentItem == SidebarItem.marksEntry,
                  onTap: () => onItemSelected(SidebarItem.marksEntry),
                ),
                _buildNavItem(
                  icon: Icons.insights_rounded,
                  inactiveIcon: Icons.insights_outlined,
                  label: 'Results',
                  isSelected: currentItem == SidebarItem.performance,
                  onTap: () => onItemSelected(SidebarItem.performance),
                ),
              ],
              _buildNavItem(
                icon: Icons.people_alt_rounded,
                inactiveIcon: Icons.people_outline_rounded,
                label: 'Students',
                isSelected: currentItem == SidebarItem.students,
                onTap: () => onItemSelected(SidebarItem.students),
              ),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                inactiveIcon: Icons.grid_view_outlined,
                label: 'More',
                isSelected: _checkIsMoreActive(isAdmin),
                onTap: onMorePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? icon : inactiveIcon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
