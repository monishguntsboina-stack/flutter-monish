import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/grade_calculator.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/student_model.dart';
import '../../../models/subject_model.dart';
import '../../../models/assessment_model.dart';
import '../../../models/marks_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/status_badge.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marksObtainedController = TextEditingController();
  final _remarksController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');

  String? _selectedStudentId;
  String? _selectedSubjectId;
  String? _selectedAssessmentId;
  double _maximumMarks = 100.0;
  DateTime _entryDate = DateTime.now();

  // Calculated live values
  double _calculatedPercentage = 0.0;
  GradeInfo _calculatedGradeInfo = GradeCalculator.getGradeInfo(0.0);
  bool _isSaving = false;

  @override
  void dispose() {
    _marksObtainedController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final obt = double.tryParse(_marksObtainedController.text.trim()) ?? 0.0;
    final pct = GradeCalculator.calculatePercentage(obt, _maximumMarks);
    setState(() {
      _calculatedPercentage = pct;
      _calculatedGradeInfo = GradeCalculator.getGradeInfo(pct);
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _marksObtainedController.clear();
    _remarksController.clear();
    setState(() {
      _calculatedPercentage = 0.0;
      _calculatedGradeInfo = GradeCalculator.getGradeInfo(0.0);
    });
  }

  Future<void> _handleSaveMarks() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null || _selectedSubjectId == null || _selectedAssessmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Student, Subject, and Assessment.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final student = firestoreService.students.firstWhere((s) => s.id == _selectedStudentId);
    final subject = firestoreService.subjects.firstWhere((s) => s.id == _selectedSubjectId);
    final assessment = firestoreService.assessments.firstWhere((a) => a.id == _selectedAssessmentId);

    final marksObt = double.tryParse(_marksObtainedController.text.trim()) ?? 0.0;

    final newMark = MarksModel.calculate(
      id: '',
      studentId: student.id,
      studentRollNo: student.rollNumber,
      studentName: student.name,
      subjectId: subject.id,
      subjectName: subject.subjectName,
      assessmentId: assessment.id,
      assessmentName: assessment.name,
      marksObtained: marksObt,
      maximumMarks: _maximumMarks,
      remarks: _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null,
      createdAt: _entryDate,
    );

    await firestoreService.saveMarks(newMark);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Marks recorded for ${student.name} (${newMark.percentage}% - ${newMark.grade})!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _marksObtainedController.clear();
      _remarksController.clear();
      _recalculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final isDesktop = Responsive.isDesktop(context);

    final students = firestoreService.students;
    final subjects = firestoreService.subjects;
    final assessments = firestoreService.assessments;

    // Filter assessments by chosen subject
    final eligibleAssessments = _selectedSubjectId != null
        ? assessments.where((a) => a.subjectId == _selectedSubjectId).toList()
        : assessments;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Marks Entry & Evaluation',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record academic scores with automated grade point, percentage, and pass/fail evaluation.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Split Layout
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Form Panel
                Expanded(
                  flex: 6,
                  child: _buildMarksEntryForm(context, students, subjects, eligibleAssessments),
                ),
                const SizedBox(width: 24),
                // Right Recent Entries Panel
                Expanded(
                  flex: 4,
                  child: _buildRecentEntriesPanel(context, firestoreService),
                ),
              ],
            )
          else ...[
            _buildMarksEntryForm(context, students, subjects, eligibleAssessments),
            const SizedBox(height: 24),
            _buildRecentEntriesPanel(context, firestoreService),
          ],
        ],
      ),
    );
  }

  Widget _buildMarksEntryForm(
    BuildContext context,
    List<StudentModel> students,
    List<SubjectModel> subjects,
    List<AssessmentModel> eligibleAssessments,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Marks',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 20),

              // Select Student
              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Select Student *',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textSecondary),
                ),
                hint: const Text('Choose a student by Roll No or Name', style: TextStyle(fontSize: 13)),
                items: students
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.rollNumber} - ${s.name} (${s.department})', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStudentId = val),
                validator: (v) => v == null ? 'Please select a student' : null,
              ),
              const SizedBox(height: 16),

              // Select Subject
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Select Subject *',
                  prefixIcon: Icon(Icons.menu_book_rounded, size: 20, color: AppColors.textSecondary),
                ),
                hint: const Text('Choose subject', style: TextStyle(fontSize: 13)),
                items: subjects
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.subjectCode} - ${s.subjectName}', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                    _selectedAssessmentId = null;
                  });
                },
                validator: (v) => v == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),

              // Select Assessment
              DropdownButtonFormField<String>(
                value: _selectedAssessmentId,
                decoration: const InputDecoration(
                  labelText: 'Select Assessment *',
                  prefixIcon: Icon(Icons.assignment_outlined, size: 20, color: AppColors.textSecondary),
                ),
                hint: const Text('Choose assessment', style: TextStyle(fontSize: 13)),
                items: eligibleAssessments
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.name} (${a.type} - Max ${a.maximumMarks.toInt()})', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedAssessmentId = val;
                    if (val != null) {
                      final chosen = eligibleAssessments.firstWhere((a) => a.id == val);
                      _maximumMarks = chosen.maximumMarks;
                      _recalculate();
                    }
                  });
                },
                validator: (v) => v == null ? 'Please select an assessment' : null,
              ),
              const SizedBox(height: 16),

              // Marks Max & Marks Obtained
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: _maximumMarks.toInt().toString()),
                      label: 'Max Marks',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _marksObtainedController,
                      label: 'Marks Obtained *',
                      hintText: 'e.g. 85',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.score_rounded,
                      onChanged: (_) => _recalculate(),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null) return 'Must be a number';
                        if (numVal < 0 || numVal > _maximumMarks) {
                          return 'Between 0 and ${_maximumMarks.toInt()}';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Real-time Automated Calculation Result Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _calculatedGradeInfo.bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _calculatedGradeInfo.color.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Percentage', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '$_calculatedPercentage%',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _calculatedGradeInfo.color),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: AppColors.border),
                    Column(
                      children: [
                        const Text('Grade', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        StatusBadge.grade(_calculatedGradeInfo.grade),
                      ],
                    ),
                    Container(height: 30, width: 1, color: AppColors.border),
                    Column(
                      children: [
                        const Text('Result', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        StatusBadge.result(_calculatedGradeInfo.isPass ? 'Pass' : 'Fail'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _entryDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _entryDate = picked);
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
                          const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Text('Assessment Date: ${_dateFormat.format(_entryDate)}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remarks
              CustomTextField(
                controller: _remarksController,
                label: 'Remarks (Optional)',
                hintText: 'e.g. Excellent presentation, good analytical approach',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomButton(
                      text: 'Save Marks',
                      onPressed: _handleSaveMarks,
                      isLoading: _isSaving,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Reset',
                      onPressed: _resetForm,
                      isOutlined: true,
                      icon: Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntriesPanel(BuildContext context, FirestoreService firestoreService) {
    final recentMarks = firestoreService.marks;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Entries',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${recentMarks.length} Total',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),

            if (recentMarks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No marks entered yet.', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentMarks.take(6).length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final mark = recentMarks[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: mark.result == 'Pass' ? AppColors.successBg : AppColors.errorBg,
                          child: Text(
                            mark.studentName.isNotEmpty ? mark.studentName[0] : 'S',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mark.result == 'Pass' ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${mark.studentName} (${mark.studentRollNo})',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${mark.subjectName} • ${mark.assessmentName}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${mark.marksObtained.toInt()} / ${mark.maximumMarks.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            StatusBadge.grade(mark.grade),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
