import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/assessment_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  String? _selectedSubjectId;
  String? _selectedType;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  void _showAddEditAssessmentDialog([AssessmentModel? assessment]) {
    final formKey = GlobalKey<FormState>();
    final isEdit = assessment != null;
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final nameController = TextEditingController(text: assessment?.name ?? '');
    final maxMarksController = TextEditingController(text: (assessment?.maximumMarks ?? 100).toInt().toString());
    final descriptionController = TextEditingController(text: assessment?.description ?? '');
    DateTime selectedDate = assessment?.date ?? DateTime.now();

    String selectedSubjectId = assessment?.subjectId ??
        (firestoreService.subjects.isNotEmpty ? firestoreService.subjects.first.id : '');
    String selectedType = assessment?.type ?? AppConstants.typeMidExam;

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
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEdit ? Icons.edit_calendar_rounded : Icons.assignment_add,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Edit Assessment' : 'Create Assessment',
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
                    CustomTextField(
                      controller: nameController,
                      label: 'Assessment Title *',
                      hintText: 'e.g. Mid Examination 1 / Project Milestone',
                      prefixIcon: Icons.title_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedSubjectId.isNotEmpty ? selectedSubjectId : null,
                      decoration: const InputDecoration(labelText: 'Subject *'),
                      items: firestoreService.subjects
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.subjectCode} - ${s.subjectName}', style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSubjectId = val);
                      },
                      validator: (v) => v == null ? 'Please select a subject' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: const InputDecoration(labelText: 'Assessment Type'),
                            items: AppConstants.assessmentTypes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: maxMarksController,
                            label: 'Max Marks *',
                            hintText: 'e.g. 100',
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Date picker field
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: 10),
                                Text(
                                  'Date: ${_dateFormat.format(selectedDate)}',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: descriptionController,
                      label: 'Description / Topics Covered',
                      hintText: 'e.g. Chapters 1-4, Binary Search Trees and Sorting Algorithms',
                      maxLines: 2,
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
                final subjectObj = firestoreService.subjects.firstWhere(
                  (s) => s.id == selectedSubjectId,
                  orElse: () => firestoreService.subjects.first,
                );

                final updated = AssessmentModel(
                  id: assessment?.id ?? '',
                  name: nameController.text.trim(),
                  type: selectedType,
                  subjectId: selectedSubjectId,
                  subjectName: subjectObj.subjectName,
                  maximumMarks: double.tryParse(maxMarksController.text.trim()) ?? 100.0,
                  date: selectedDate,
                  description: descriptionController.text.trim(),
                );

                if (isEdit) {
                  await firestoreService.updateAssessment(updated);
                } else {
                  await firestoreService.addAssessment(updated);
                }

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Assessment updated successfully!' : 'Assessment published successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Update' : 'Publish Assessment'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AssessmentModel assessment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text('Are you sure you want to delete ${assessment.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final firestoreService = Provider.of<FirestoreService>(context, listen: false);
              await firestoreService.deleteAssessment(assessment.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assessment ${assessment.name} deleted.'),
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

    return StreamBuilder<List<AssessmentModel>>(
      stream: firestoreService.getAssessmentsStream(),
      builder: (context, snapshot) {
        final allAssessments = snapshot.data ?? firestoreService.assessments;

        final filteredAssessments = allAssessments.where((a) {
          final matchesSubject = _selectedSubjectId == null || a.subjectId == _selectedSubjectId;
          final matchesType = _selectedType == null || a.type == _selectedType;
          return matchesSubject && matchesType;
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
                        'Assessment Management',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule examinations, assignments, quizzes, and project evaluations',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: '+ New Assessment',
                    onPressed: () => _showAddEditAssessmentDialog(),
                    backgroundColor: AppColors.purple,
                    icon: Icons.assignment_add,
                    width: 180,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter row
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
                        child: DropdownButtonFormField<String?>(
                          value: _selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Subject',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Subjects', style: TextStyle(fontSize: 13))),
                            ...firestoreService.subjects.map(
                              (s) => DropdownMenuItem(value: s.id, child: Text('${s.subjectCode} - ${s.subjectName}', style: const TextStyle(fontSize: 13))),
                            ),
                          ],
                          onChanged: (val) => setState(() => _selectedSubjectId = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Assessment Type',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Types', style: TextStyle(fontSize: 13))),
                            ...AppConstants.assessmentTypes.map(
                              (t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))),
                            ),
                          ],
                          onChanged: (val) => setState(() => _selectedType = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cards Grid
              if (filteredAssessments.isEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.assignment_late_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No assessments found matching the selected filter.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredAssessments.length,
                  itemBuilder: (context, index) {
                    final assessment = filteredAssessments[index];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.purpleBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    assessment.type,
                                    style: const TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.warning),
                                      tooltip: 'Edit',
                                      onPressed: () => _showAddEditAssessmentDialog(assessment),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                      tooltip: 'Delete',
                                      onPressed: () => _confirmDelete(assessment),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assessment.name,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assessment.subjectName ?? 'Subject',
                                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  assessment.description.isNotEmpty ? assessment.description : 'No description provided.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      _dateFormat.format(assessment.date),
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Max Marks: ${assessment.maximumMarks.toInt()}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
