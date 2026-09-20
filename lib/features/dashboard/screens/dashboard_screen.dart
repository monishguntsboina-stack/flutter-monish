import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/marks_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/app_sidebar.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../students/screens/students_screen.dart';
import '../../subjects/screens/subjects_screen.dart';
import '../../assessments/screens/assessments_screen.dart';
import '../../marks/screens/marks_entry_screen.dart';
import '../../performance/screens/performance_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../departments/screens/departments_screen.dart';
import '../../faculty/screens/faculty_screen.dart';
import '../../career/screens/career_screen.dart';
import '../widgets/metric_card.dart';
import '../widgets/recent_activity_table.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/top_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SidebarItem _currentItem = SidebarItem.dashboard;

  String _getPageTitle() {
    switch (_currentItem) {
      case SidebarItem.dashboard:
        return 'Dashboard Overview';
      case SidebarItem.departments:
        return 'College Departments Hub';
      case SidebarItem.faculty:
        return 'Faculty Directory & Management';
      case SidebarItem.students:
        return 'Students Directory';
      case SidebarItem.subjects:
        return 'Subject Management';
      case SidebarItem.assessments:
        return 'Assessment Management';
      case SidebarItem.marksEntry:
        return 'Marks Entry & Evaluation';
      case SidebarItem.performance:
        return 'Results & Performance';
      case SidebarItem.career:
        return 'Career & Job Recommendations';
      case SidebarItem.reports:
        return 'Reports & Analytics';
      case SidebarItem.profile:
        return 'Profile & Settings';
    }
  }

  Widget _buildBodyContent(FirestoreService firestoreService) {
    switch (_currentItem) {
      case SidebarItem.dashboard:
        return _buildDashboardOverview(firestoreService);
      case SidebarItem.departments:
        return const DepartmentsScreen();
      case SidebarItem.faculty:
        return const FacultyScreen();
      case SidebarItem.students:
        return const StudentsScreen();
      case SidebarItem.subjects:
        return const SubjectsScreen();
      case SidebarItem.assessments:
        return const AssessmentsScreen();
      case SidebarItem.marksEntry:
        return const MarksEntryScreen();
      case SidebarItem.performance:
        return const PerformanceScreen();
      case SidebarItem.career:
        return const CareerScreen();
      case SidebarItem.reports:
        return const ReportsScreen();
      case SidebarItem.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final isDesktop = Responsive.isDesktop(context);

    return PopScope(
      canPop: _currentItem == SidebarItem.dashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentItem != SidebarItem.dashboard) {
          setState(() {
            _currentItem = SidebarItem.dashboard;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.scaffoldBg,
        drawer: !isDesktop
            ? Drawer(
                child: AppSidebar(
                  currentItem: _currentItem,
                  onItemSelected: (item) {
                    setState(() {
                      _currentItem = item;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              )
            : null,
        bottomNavigationBar: !isDesktop
            ? AppBottomNavBar(
                currentItem: _currentItem,
                onItemSelected: (item) {
                  setState(() {
                    _currentItem = item;
                  });
                },
                onMorePressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        body: Row(
          children: [
            // Fixed Sidebar on Desktop
            if (isDesktop)
              AppSidebar(
                currentItem: _currentItem,
                onItemSelected: (item) {
                  setState(() {
                    _currentItem = item;
                  });
                },
              ),

            // Main Screen Area
            Expanded(
              child: Column(
                children: [
                  TopNavbar(
                    title: _getPageTitle(),
                    showBackButton: !isDesktop && _currentItem != SidebarItem.dashboard,
                    onBackPressed: () {
                      setState(() {
                        _currentItem = SidebarItem.dashboard;
                      });
                    },
                    onProfilePressed: () {
                      setState(() {
                        _currentItem = SidebarItem.profile;
                      });
                    },
                    onMenuPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Expanded(
                    child: _buildBodyContent(firestoreService),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverview(FirestoreService firestoreService) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;
    final isAdmin = user?.isAdmin == true;

    return FutureBuilder<DashboardStats>(
      future: firestoreService.getDashboardStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            const DashboardStats(
              totalStudents: 256,
              totalSubjects: 18,
              totalAssessments: 42,
              totalMarksEntries: 1245,
              averagePerformance: 82.4,
              passPercentage: 87.45,
            );

        return StreamBuilder<List<MarksModel>>(
          stream: firestoreService.getRecentMarksStream(),
          builder: (context, marksSnapshot) {
            final recentMarks = marksSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role-specific Welcome Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isAdmin
                          ? const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF065F46), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isAdmin ? const Color(0xFF1E3A8A) : const Color(0xFF065F46)).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isAdmin
                                        ? 'PSCMR Central Administration'
                                        : 'PSCMR Faculty Academic Workspace',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: isMobile ? 16 : 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isAdmin
                                    ? 'Welcome ${user?.name ?? "Administrator"}. You have full institutional oversight over departments, faculty directory, student enrollment, and career placement.'
                                    : 'Welcome ${user?.name ?? "Faculty Member"} (${user?.department ?? "All Departments"}). Record exam marks, analyze student results, and match eligible jobs.',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isMobile ? 12 : 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAdmin ? 'Administrator' : (user?.department ?? 'Faculty'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Admin Quick Department Strip
                  if (isAdmin) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'College Departments',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _currentItem = SidebarItem.departments),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: const Text('View All Hubs', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDeptChip('CSE', 'Computer Science', const Color(0xFF2563EB)),
                          const SizedBox(width: 12),
                          _buildDeptChip('IT', 'Information Tech', const Color(0xFF0D9488)),
                          const SizedBox(width: 12),
                          _buildDeptChip('ECE', 'Electronics & Comm', const Color(0xFFD97706)),
                          const SizedBox(width: 12),
                          _buildDeptChip('ME', 'Mechanical Engg', const Color(0xFFDC2626)),
                          const SizedBox(width: 12),
                          _buildDeptChip('AI&DS', 'Artificial Intelligence', const Color(0xFF7C3AED)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Metric Cards Grid tailored by role
                  _buildMetricCards(context, stats, isAdmin),
                  const SizedBox(height: 24),

                  // Recent Activity and Quick Actions
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: RecentActivityTable(
                            marks: recentMarks,
                            onViewAll: () => setState(() => _currentItem = SidebarItem.performance),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: QuickActionsPanel(
                            isAdmin: isAdmin,
                            onAddStudent: () => setState(() => _currentItem = SidebarItem.students),
                            onAddSubject: () => setState(() => _currentItem = SidebarItem.subjects),
                            onEnterMarks: () => setState(() => _currentItem = SidebarItem.marksEntry),
                            onGenerateReport: () => setState(() => _currentItem = SidebarItem.reports),
                            onOpenDepartments: () => setState(() => _currentItem = SidebarItem.departments),
                            onOpenFaculty: () => setState(() => _currentItem = SidebarItem.faculty),
                            onOpenCareer: () => setState(() => _currentItem = SidebarItem.career),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    RecentActivityTable(
                      marks: recentMarks,
                      onViewAll: () => setState(() => _currentItem = SidebarItem.performance),
                    ),
                    const SizedBox(height: 20),
                    QuickActionsPanel(
                      isAdmin: isAdmin,
                      onAddStudent: () => setState(() => _currentItem = SidebarItem.students),
                      onAddSubject: () => setState(() => _currentItem = SidebarItem.subjects),
                      onEnterMarks: () => setState(() => _currentItem = SidebarItem.marksEntry),
                      onGenerateReport: () => setState(() => _currentItem = SidebarItem.reports),
                      onOpenDepartments: () => setState(() => _currentItem = SidebarItem.departments),
                      onOpenFaculty: () => setState(() => _currentItem = SidebarItem.faculty),
                      onOpenCareer: () => setState(() => _currentItem = SidebarItem.career),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeptChip(String code, String name, Color accentColor) {
    return InkWell(
      onTap: () {
        setState(() => _currentItem = SidebarItem.departments);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                code,
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards(BuildContext context, DashboardStats stats, bool isAdmin) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 1200 ? 4 : (width > 700 ? 2 : 1);

    final List<MetricCard> cards;

    if (isAdmin) {
      cards = [
        MetricCard(
          title: 'Departments',
          value: '5',
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          subtitle: 'CSE, IT, ECE, ME, AI&DS',
          isPositive: true,
        ),
        MetricCard(
          title: 'Faculty Members',
          value: '4',
          icon: Icons.school_rounded,
          iconColor: const Color(0xFF0D9488),
          iconBgColor: const Color(0xFFF0FDFA),
          subtitle: 'Active professors & lecturers',
          isPositive: true,
        ),
        MetricCard(
          title: 'Total Students',
          value: stats.totalStudents.toString(),
          icon: Icons.people_alt_rounded,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.infoBg,
          subtitle: 'Enrolled across all branches',
          isPositive: true,
        ),
        MetricCard(
          title: 'Pass Percentage',
          value: '${stats.passPercentage}%',
          icon: Icons.insights_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBgColor: const Color(0xFFE0F2FE),
          subtitle: 'Institutional pass rate',
          isPositive: stats.passPercentage >= 75.0,
        ),
      ];
    } else {
      cards = [
        MetricCard(
          title: 'Total Students',
          value: stats.totalStudents.toString(),
          icon: Icons.people_alt_rounded,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.infoBg,
          subtitle: 'Students in your department',
          isPositive: true,
        ),
        MetricCard(
          title: 'Course Subjects',
          value: stats.totalSubjects.toString(),
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.success,
          iconBgColor: AppColors.successBg,
          subtitle: 'Assigned teaching curriculum',
          isPositive: true,
        ),
        MetricCard(
          title: 'Marks Entries',
          value: stats.totalMarksEntries.toString(),
          icon: Icons.assignment_turned_in_rounded,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warningBg,
          subtitle: 'Recorded semester assessments',
          isPositive: true,
        ),
        MetricCard(
          title: 'Pass Percentage',
          value: '${stats.passPercentage}%',
          icon: Icons.insights_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBgColor: const Color(0xFFE0F2FE),
          subtitle: 'Evaluated subjects pass rate',
          isPositive: stats.passPercentage >= 75.0,
        ),
      ];
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossAxisCount == 1 ? 2.8 : (crossAxisCount == 2 ? 2.2 : 1.9),
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}
