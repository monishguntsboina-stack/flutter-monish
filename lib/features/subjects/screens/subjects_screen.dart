import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/subject_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDepartment;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditSubjectDialog([SubjectModel? subject]) {
    final formKey = GlobalKey<FormState>();
    final isEdit = subject != null;

    final codeController = TextEditingController(text: subject?.subjectCode ?? 'CS10${DateTime.now().millisecond % 90 + 10}');
    final nameController = TextEditingController(text: subject?.subjectName ?? '');
    final facultyNameController = TextEditingController(text: subject?.facultyName ?? 'Dr. Ramesh Kumar');
    final maxMarksController = TextEditingController(text: (subject?.maxMarks ?? 100).toString());
    String department = subject?.department ?? AppConstants.departments.first;
    String year = subject?.year ?? AppConstants.academicYears[2];
    String semester = subject?.semester ?? AppConstants.semesters[4];

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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEdit ? Icons.edit_note_rounded : Icons.library_add_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Edit Subject Details' : 'Add New Subject',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: codeController,
                            label: 'Subject Code *',
                            hintText: 'e.g. CS101',
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            controller: maxMarksController,
                            label: 'Maximum Marks *',
                            hintText: 'e.g. 100',
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: nameController,
                      label: 'Subject Name *',
                      hintText: 'e.g. Data Structures & Algorithms',
                      prefixIcon: Icons.menu_book_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter subject name' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: facultyNameController,
                      label: 'Assigned Faculty *',
                      hintText: 'e.g. Dr. Ramesh Kumar',
                      prefixIcon: Icons.person_pin_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter faculty name' : null,
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
                            decoration: const InputDecoration(labelText: 'Year'),
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
                            value: semester,
                            decoration: const InputDecoration(labelText: 'Semester'),
                            items: AppConstants.semesters
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => semester = val);
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

                final updated = SubjectModel(
                  id: subject?.id ?? '',
                  subjectCode: codeController.text.trim(),
                  subjectName: nameController.text.trim(),
                  department: department,
                  year: year,
                  semester: semester,
                  facultyId: 'fac_assigned',
                  facultyName: facultyNameController.text.trim(),
                  maxMarks: int.tryParse(maxMarksController.text.trim()) ?? 100,
                );

                if (isEdit) {
                  await firestoreService.updateSubject(updated);
                } else {
                  await firestoreService.addSubject(updated);
                }

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Subject updated successfully!' : 'Subject added successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Update Subject' : 'Save Subject'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.subjectCode} - ${subject.subjectName}? All related assessments will be impacted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final firestoreService = Provider.of<FirestoreService>(context, listen: false);
              await firestoreService.deleteSubject(subject.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subject ${subject.subjectCode} deleted.'),
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

    return StreamBuilder<List<SubjectModel>>(
      stream: firestoreService.getSubjectsStream(),
      builder: (context, snapshot) {
        final allSubjects = snapshot.data ?? firestoreService.subjects;

        final filteredSubjects = allSubjects.where((subject) {
          final query = _searchController.text.toLowerCase().trim();
          final matchesQuery = query.isEmpty ||
              subject.subjectCode.toLowerCase().contains(query) ||
              subject.subjectName.toLowerCase().contains(query) ||
              (subject.facultyName?.toLowerCase().contains(query) ?? false);

          final matchesDept = _selectedDepartment == null || subject.department == _selectedDepartment;
          return matchesQuery && matchesDept;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subjects Curriculum',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage course codes, assigned faculty, and maximum mark allocations',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: '+ Add Subject',
                    onPressed: () => _showAddEditSubjectDialog(),
                    backgroundColor: AppColors.success,
                    icon: Icons.library_add_rounded,
                    width: 160,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filter
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
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search by subject code, course title, or faculty...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
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
                          onChanged: (val) => setState(() => _selectedDepartment = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Table
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
                      if (filteredSubjects.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text('No subjects match your search criteria.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
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
                                DataColumn(label: Text('Subject Code')),
                                DataColumn(label: Text('Subject Name')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Year / Sem')),
                                DataColumn(label: Text('Max Marks')),
                                DataColumn(label: Text('Faculty')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: filteredSubjects.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final subject = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(index.toString(), style: const TextStyle(color: AppColors.textMuted))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.infoBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          subject.subjectCode,
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        subject.subjectName,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(Text(subject.department)),
                                    DataCell(Text('${subject.year} - ${subject.semester}')),
                                    DataCell(Text(subject.maxMarks.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(subject.facultyName ?? 'Faculty'),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.warning),
                                            tooltip: 'Edit Subject',
                                            onPressed: () => _showAddEditSubjectDialog(subject),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                            tooltip: 'Delete Subject',
                                            onPressed: () => _confirmDelete(subject),
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
