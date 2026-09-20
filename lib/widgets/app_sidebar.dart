import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

enum SidebarItem {
  dashboard,
  departments,
  faculty,
  students,
  subjects,
  assessments,
  marksEntry,
  performance,
  career,
  reports,
  profile,
}

class AppSidebar extends StatelessWidget {
  final SidebarItem currentItem;
  final ValueChanged<SidebarItem>? onItemSelected;

  const AppSidebar({
    super.key,
    required this.currentItem,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;
    final isAdmin = user?.isAdmin == true;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo and Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(
                      'assets/images/college_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PSCMR Assessment',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isAdmin ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFF059669).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isAdmin ? 'ADMIN PORTAL' : 'FACULTY PORTAL',
                              style: GoogleFonts.inter(
                                color: isAdmin ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 12),

          // Navigation Links tailored to role
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  context,
                  item: SidebarItem.dashboard,
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                ),

                // Admin-specific items
                if (isAdmin) ...[
                  _buildNavItem(
                    context,
                    item: SidebarItem.departments,
                    title: 'Departments',
                    icon: Icons.apartment_rounded,
                  ),
                  _buildNavItem(
                    context,
                    item: SidebarItem.faculty,
                    title: 'Faculty Directory',
                    icon: Icons.school_rounded,
                  ),
                ],

                // Faculty-specific priority item
                if (!isAdmin) ...[
                  _buildNavItem(
                    context,
                    item: SidebarItem.marksEntry,
                    title: 'Marks Entry',
                    icon: Icons.edit_note_rounded,
                  ),
                  _buildNavItem(
                    context,
                    item: SidebarItem.assessments,
                    title: 'Assessments',
                    icon: Icons.assignment_rounded,
                  ),
                ],

                _buildNavItem(
                  context,
                  item: SidebarItem.students,
                  title: isAdmin ? 'All Students' : 'My Students',
                  icon: Icons.people_alt_rounded,
                ),

                if (isAdmin) ...[
                  _buildNavItem(
                    context,
                    item: SidebarItem.subjects,
                    title: 'Curriculum & Subjects',
                    icon: Icons.menu_book_rounded,
                  ),
                  _buildNavItem(
                    context,
                    item: SidebarItem.assessments,
                    title: 'Assessments',
                    icon: Icons.assignment_rounded,
                  ),
                  _buildNavItem(
                    context,
                    item: SidebarItem.marksEntry,
                    title: 'Marks Overview',
                    icon: Icons.edit_note_rounded,
                  ),
                ],

                _buildNavItem(
                  context,
                  item: SidebarItem.performance,
                  title: 'Performance & Results',
                  icon: Icons.insights_rounded,
                ),

                // Career Guidance & Job Matching
                _buildNavItem(
                  context,
                  item: SidebarItem.career,
                  title: 'Career & Job Matching',
                  icon: Icons.work_outline_rounded,
                ),

                _buildNavItem(
                  context,
                  item: SidebarItem.reports,
                  title: 'Reports & Analytics',
                  icon: Icons.bar_chart_rounded,
                ),
                _buildNavItem(
                  context,
                  item: SidebarItem.profile,
                  title: 'Profile & Settings',
                  icon: Icons.manage_accounts_rounded,
                ),
              ],
            ),
          ),

          // User Footer Profile & Logout
          const Divider(color: Color(0xFF1E293B), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155), width: 0.8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Admin User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.role ?? 'Administrator',
                          style: TextStyle(
                            color: user?.isAdmin == true ? const Color(0xFF60A5FA) : const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    tooltip: 'Logout',
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to sign out from the system?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await authService.signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required SidebarItem item,
    required String title,
    required IconData icon,
  }) {
    final isSelected = currentItem == item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (onItemSelected != null) {
              onItemSelected!(item);
            }
          },
          hoverColor: AppColors.sidebarHover,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.sidebarActiveText : AppColors.sidebarText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: isSelected ? AppColors.sidebarActiveText : AppColors.sidebarText,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
