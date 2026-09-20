import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/department_model.dart';
import '../../../models/student_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/status_badge.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final DepartmentModel department;

  const DepartmentDetailScreen({super.key, required this.department});

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _studentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final deptStudents = firestoreService.getStudentsByDepartment(widget.department.name);
    final deptFaculty = firestoreService.getFacultyByDepartment(widget.department.name);
    final deptMarks = firestoreService.getMarksForDepartment(widget.department.name);

    final filteredStudents = deptStudents.where((s) {
      final q = _studentSearchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.rollNumber.toLowerCase().contains(q) ||
          s.studentId.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.department.code} - ${widget.department.name}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              'HOD: ${widget.department.hodName} • ${widget.department.blockBuilding}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.people_alt_rounded, size: 18), text: 'Students (${deptStudents.length})'),
            Tab(icon: const Icon(Icons.school_rounded, size: 18), text: 'Faculty (${deptFaculty.length})'),
            Tab(icon: const Icon(Icons.bar_chart_rounded, size: 18), text: 'Department Performance (${deptMarks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Department Students Only
          _buildDepartmentStudentsTab(context, firestoreService, filteredStudents),

          // Tab 2: Department Faculty Only
          _buildDepartmentFacultyTab(context, firestoreService, deptFaculty),

          // Tab 3: Department Marks & Analytics
          _buildDepartmentPerformanceTab(context, deptMarks),
        ],
      ),
    );
  }

  Widget _buildDepartmentStudentsTab(
    BuildContext context,
    FirestoreService firestoreService,
    List<StudentModel> students,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Action Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _studentSearchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.department.code} students by name, roll no...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentDialog(context, firestoreService),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Student to Dept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Students List
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_off_rounded, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No students enrolled in ${widget.department.code} yet.',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, idx) {
                        final student = students[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              student.name.isNotEmpty ? student.name[0] : 'S',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Roll No: ${student.rollNumber} • ${student.year} Sec-${student.section} • Phone: ${student.phone}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  student.studentId,
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete Student?'),
                                      content: Text('Remove ${student.name} from ${widget.department.code}?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await firestoreService.deleteStudent(student.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentFacultyTab(
    BuildContext context,
    FirestoreService firestoreService,
    List<UserModel> facultyList,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Faculty Members Assigned to ${widget.department.code}',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddFacultyDialog(context, firestoreService),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add Faculty to Dept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: facultyList.isEmpty
                ? Center(
                    child: Text(
                      'No faculty members assigned to ${widget.department.name} yet.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: 160,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: facultyList.length,
                    itemBuilder: (context, idx) {
                      final f = facultyList[idx];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                              child: const Icon(Icons.school_rounded, color: Color(0xFF0D9488), size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    f.name,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    f.designation ?? 'Professor',
                                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0D9488), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    f.qualification ?? 'M.Tech, Ph.D',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          f.email,
                                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentPerformanceTab(BuildContext context, List marksList) {
    if (marksList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_chart_outlined_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No marks recorded for ${widget.department.code} students yet.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    double totalPct = 0;
    int passCount = 0;
    for (final m in marksList) {
      totalPct += m.percentage;
      if (m.result.toLowerCase() == 'pass') passCount++;
    }
    final avg = (totalPct / marksList.length).toStringAsFixed(1);
    final passPct = ((passCount / marksList.length) * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile('Department Average', '$avg%', Icons.insights_rounded, AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile('Pass Rate', '$passPct%', Icons.verified_rounded, AppColors.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile('Total Evaluations', '${marksList.length}', Icons.assignment_turned_in_rounded, Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Recent Department Academic Evaluations',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                itemCount: marksList.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, idx) {
                  final mark = marksList[idx];
                  return ListTile(
                    title: Text(
                      '${mark.studentName} (${mark.studentRollNo})',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${mark.subjectName} • ${mark.assessmentName}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${mark.marksObtained}/${mark.maximumMarks} (${mark.percentage}%)',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge.grade(mark.grade),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, FirestoreService service) {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String year = '3rd Year';
    String section = 'A';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Student to ${widget.department.code}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameCtrl, label: 'Student Full Name', hintText: 'e.g. John Doe'),
              const SizedBox(height: 12),
              CustomTextField(controller: rollCtrl, label: 'Roll Number', hintText: 'e.g. 23CS010'),
              const SizedBox(height: 12),
              CustomTextField(controller: emailCtrl, label: 'Email', hintText: 'name@example.com'),
              const SizedBox(height: 12),
              CustomTextField(controller: phoneCtrl, label: 'Phone', hintText: '9876543210'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && rollCtrl.text.isNotEmpty) {
                final newStu = StudentModel(
                  id: 'stu_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: 'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : 'student@example.com',
                  phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '9876543210',
                  department: widget.department.name,
                  year: year,
                  section: section,
                  rollNumber: rollCtrl.text.trim(),
                );
                service.addStudent(newStu);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Student', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddFacultyDialog(BuildContext context, FirestoreService service) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final designationCtrl = TextEditingController(text: 'Assistant Professor');
    final qualificationCtrl = TextEditingController(text: 'M.Tech');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Faculty to ${widget.department.code}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameCtrl, label: 'Faculty Name', hintText: 'e.g. Dr. Jane Smith'),
              const SizedBox(height: 12),
              CustomTextField(controller: emailCtrl, label: 'Email', hintText: 'jane@assessment.edu'),
              const SizedBox(height: 12),
              CustomTextField(controller: phoneCtrl, label: 'Phone', hintText: '9876543210'),
              const SizedBox(height: 12),
              CustomTextField(controller: designationCtrl, label: 'Designation', hintText: 'e.g. Associate Professor'),
              const SizedBox(height: 12),
              CustomTextField(controller: qualificationCtrl, label: 'Qualification', hintText: 'e.g. M.Tech, Ph.D'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                final newFac = UserModel(
                  id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
                  employeeId: 'EMP-${widget.department.code}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: 'Faculty',
                  phone: phoneCtrl.text.trim(),
                  department: widget.department.name,
                  designation: designationCtrl.text.trim(),
                  qualification: qualificationCtrl.text.trim(),
                  createdAt: DateTime.now(),
                );
                service.addFaculty(newFac);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            child: const Text('Add Faculty', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
