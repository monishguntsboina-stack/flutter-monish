import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class StudentsScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const StudentsScreen({super.key, this.onBackToDashboard});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;
  int _currentPage = 1;
  final int _rowsPerPage = 6;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditStudentDialog([StudentModel? student]) {
    final formKey = GlobalKey<FormState>();
    final isEdit = student != null;

    final studentIdController = TextEditingController(text: student?.studentId ?? 'STU202400${DateTime.now().millisecond % 100}');
    final rollNumberController = TextEditingController(text: student?.rollNumber ?? '23CS00${DateTime.now().millisecond % 90 + 10}');
    final nameController = TextEditingController(text: student?.name ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');
    String department = student?.department ?? AppConstants.departments.first;
    String year = student?.year ?? AppConstants.academicYears[2];
    String section = student?.section ?? AppConstants.sections.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Edit Student Details' : 'Add New Student',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: rollNumberController,
                            label: 'Roll Number *',
                            hintText: 'e.g. 23CS001',
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: studentIdController,
                            label: 'Student ID *',
                            hintText: 'e.g. STU2024001',
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: nameController,
                      label: 'Full Name *',
                      hintText: 'e.g. Ravi Kumar',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter student full name' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: emailController,
                            label: 'Email Address *',
                            hintText: 'e.g. ravi@example.com',
                            prefixIcon: Icons.email_outlined,
                            validator: (v) => v?.contains('@') != true ? 'Enter valid email' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            hintText: 'e.g. 9876543210',
                            prefixIcon: Icons.phone_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: department,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: AppConstants.departments
                          .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => department = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: year,
                            decoration: const InputDecoration(labelText: 'Academic Year'),
                            items: AppConstants.academicYears
                                .map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => year = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: section,
                            decoration: const InputDecoration(labelText: 'Section'),
                            items: AppConstants.sections
                                .map((s) => DropdownMenuItem(value: s, child: Text('Section $s', style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => section = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final firestoreService = Provider.of<FirestoreService>(context, listen: false);

                final updated = StudentModel(
                  id: student?.id ?? '',
                  studentId: studentIdController.text.trim(),
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  department: department,
                  year: year,
                  section: section,
                  rollNumber: rollNumberController.text.trim(),
                );

                if (isEdit) {
                  await firestoreService.updateStudent(updated);
                } else {
                  await firestoreService.addStudent(updated);
                }

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Student updated successfully!' : 'Student added successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Update Student' : 'Save Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(StudentModel student) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final studentMarks = firestoreService.getMarksForStudent(student.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 20,
              child: Text(
                student.name.isNotEmpty ? student.name[0] : 'S',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
                  Text('${student.rollNumber} | ${student.department}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _buildDetailRow('Student ID', student.studentId),
              _buildDetailRow('Email', student.email),
              _buildDetailRow('Phone', student.phone.isNotEmpty ? student.phone : 'N/A'),
              _buildDetailRow('Year & Section', '${student.year} - Section ${student.section}'),
              const SizedBox(height: 16),
              Text('Academic Assessments Log', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              if (studentMarks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No marks recorded yet for this student.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                )
              else
                ...studentMarks.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${m.subjectName} (${m.assessmentName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          Text('${m.marksObtained.toInt()}/${m.maximumMarks.toInt()} (${m.grade})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmDelete(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record'),
        content: Text('Are you sure you want to delete ${student.name} (${student.rollNumber})? This will also remove associated marks.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final firestoreService = Provider.of<FirestoreService>(context, listen: false);
              await firestoreService.deleteStudent(student.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student ${student.name} removed successfully.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.getStudentsStream(),
      builder: (context, snapshot) {
        final allStudents = snapshot.data ?? firestoreService.students;

        // Filtering
        final filteredStudents = allStudents.where((student) {
          final query = _searchController.text.toLowerCase().trim();
          final matchesQuery = query.isEmpty ||
              student.name.toLowerCase().contains(query) ||
              student.rollNumber.toLowerCase().contains(query) ||
              student.studentId.toLowerCase().contains(query);

          final matchesDept = _selectedDepartment == null || student.department == _selectedDepartment;
          final matchesYear = _selectedYear == null || student.year == _selectedYear;

          return matchesQuery && matchesDept && matchesYear;
        }).toList();

        // Pagination
        final totalPages = (filteredStudents.length / _rowsPerPage).ceil();
        final effectivePage = _currentPage > totalPages && totalPages > 0 ? totalPages : _currentPage;
        final startIndex = (effectivePage - 1) * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage) > filteredStudents.length
            ? filteredStudents.length
            : startIndex + _rowsPerPage;

        final paginatedStudents = filteredStudents.isEmpty
            ? <StudentModel>[]
            : filteredStudents.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students Directory',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total ${allStudents.length} students enrolled across all departments',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: '+ Add Student',
                    onPressed: () => _showAddEditStudentDialog(),
                    icon: Icons.person_add_alt_1_rounded,
                    width: 160,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filter Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Search Input
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() => _currentPage = 1),
                          decoration: InputDecoration(
                            hintText: 'Search by student name, roll number, or ID...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _currentPage = 1);
                                    },
                                  )
                                : null,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Department Filter
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Departments', style: TextStyle(fontSize: 13))),
                            ...AppConstants.departments.map(
                              (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedDepartment = val;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Year Filter
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Years', style: TextStyle(fontSize: 13))),
                            ...AppConstants.academicYears.map(
                              (y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 13))),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedYear = val;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Data Table Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (paginatedStudents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text('No students match your filter criteria.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 800),
                            child: DataTable(
                              horizontalMargin: 12,
                              columnSpacing: 28,
                              headingTextStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                              dataTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Roll No')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Year / Sec')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: paginatedStudents.asMap().entries.map((entry) {
                                final index = startIndex + entry.key + 1;
                                final student = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(index.toString(), style: const TextStyle(color: AppColors.textMuted))),
                                    DataCell(
                                      Text(
                                        student.rollNumber,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ),
                                    DataCell(
                                      InkWell(
                                        onTap: () => _showStudentDetails(student),
                                        child: Text(
                                          student.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(student.email)),
                                    DataCell(Text(student.phone.isNotEmpty ? student.phone : '-')),
                                    DataCell(Text(student.department)),
                                    DataCell(Text('${student.year} (${student.section})')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.secondary),
                                            tooltip: 'View Details',
                                            onPressed: () => _showStudentDetails(student),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.warning),
                                            tooltip: 'Edit Student',
                                            onPressed: () => _showAddEditStudentDialog(student),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                            tooltip: 'Delete Student',
                                            onPressed: () => _confirmDelete(student),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),

                      // Pagination Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredStudents.isEmpty ? 0 : startIndex + 1} - $endIndex of ${filteredStudents.length} entries',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                                onPressed: effectivePage > 1
                                    ? () => setState(() => _currentPage = effectivePage - 1)
                                    : null,
                              ),
                              for (int i = 1; i <= (totalPages == 0 ? 1 : totalPages); i++)
                                InkWell(
                                  onTap: () => setState(() => _currentPage = i),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: effectivePage == i ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: effectivePage == i ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      i.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: effectivePage == i ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                                onPressed: effectivePage < totalPages
                                    ? () => setState(() => _currentPage = effectivePage + 1)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
