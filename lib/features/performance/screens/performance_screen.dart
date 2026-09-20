import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/marks_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';
import '../../career/screens/career_screen.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStudentId;
  String? _selectedSubjectId;
  String? _selectedGrade;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentTranscriptModal(String studentId, FirestoreService service) {
    final student = service.students.firstWhere((s) => s.id == studentId);
    final marks = service.getMarksForStudent(studentId);

    double totalPct = 0;
    int passCount = 0;
    for (final m in marks) {
      totalPct += m.percentage;
      if (m.result == 'Pass') passCount++;
    }
    final avgPct = marks.isNotEmpty ? (totalPct / marks.length).toStringAsFixed(1) : '0.0';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('${student.name} - Performance Transcript', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Roll No', student.rollNumber),
                    _buildStatItem('Department', student.department),
                    _buildStatItem('Cumulative Avg', '$avgPct%'),
                    _buildStatItem('Passed Exams', '$passCount / ${marks.length}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (marks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No examination records available.'),
                )
              else
                ...marks.map((m) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: StatusBadge.grade(m.grade),
                      title: Text(m.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(m.assessmentName, style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${m.marksObtained.toInt()} / ${m.maximumMarks.toInt()} (${m.percentage}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 8),
                          StatusBadge.result(m.result),
                        ],
                      ),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: Text('${student.name} - Job Recommendations'),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    body: CareerScreen(initialStudentId: student.id),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.work_outline_rounded, size: 16),
            label: const Text('View Job Recommendations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<MarksModel>>(
      stream: firestoreService.getMarksStream(),
      builder: (context, snapshot) {
        final allMarks = snapshot.data ?? firestoreService.marks;

        // Apply filters
        final filteredMarks = allMarks.where((mark) {
          final query = _searchController.text.toLowerCase().trim();
          final matchesQuery = query.isEmpty ||
              mark.studentName.toLowerCase().contains(query) ||
              mark.studentRollNo.toLowerCase().contains(query) ||
              mark.subjectName.toLowerCase().contains(query);

          final matchesStudent = _selectedStudentId == null || mark.studentId == _selectedStudentId;
          final matchesSubject = _selectedSubjectId == null || mark.subjectId == _selectedSubjectId;
          final matchesGrade = _selectedGrade == null || mark.grade == _selectedGrade;

          return matchesQuery && matchesStudent && matchesSubject && matchesGrade;
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
                        'Student Results & Performance',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detailed scorecard, subject analysis, pass rates, and individual student transcripts',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Bar matching Mockup Panel 7
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
                      // Student filter
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: 'Select Student',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Students', style: TextStyle(fontSize: 13))),
                            ...firestoreService.students.map(
                              (s) => DropdownMenuItem(value: s.id, child: Text('${s.rollNumber} - ${s.name}', style: const TextStyle(fontSize: 13))),
                            ),
                          ],
                          onChanged: (val) => setState(() => _selectedStudentId = val),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Subject filter
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Select Subject',
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
                      const SizedBox(width: 12),

                      // Search text field
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search results...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Reset action
                      CustomButton(
                        text: 'Reset Filters',
                        onPressed: () {
                          setState(() {
                            _selectedStudentId = null;
                            _selectedSubjectId = null;
                            _selectedGrade = null;
                            _searchController.clear();
                          });
                        },
                        isOutlined: true,
                        width: 120,
                        height: 44,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Results Data Table
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
                      if (filteredMarks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.assessment_outlined, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text('No results match your filter selection.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
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
                                DataColumn(label: Text('Subject')),
                                DataColumn(label: Text('Assessment')),
                                DataColumn(label: Text('Marks')),
                                DataColumn(label: Text('Grade')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: filteredMarks.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final mark = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(index.toString(), style: const TextStyle(color: AppColors.textMuted))),
                                    DataCell(
                                      Text(
                                        mark.studentRollNo,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        mark.studentName,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(Text(mark.subjectName)),
                                    DataCell(Text(mark.assessmentName)),
                                    DataCell(
                                      Text(
                                        '${mark.marksObtained.toInt()} / ${mark.maximumMarks.toInt()} (${mark.percentage}%)',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(StatusBadge.grade(mark.grade)),
                                    DataCell(StatusBadge.result(mark.result)),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
                                        tooltip: 'View Student Transcript',
                                        onPressed: () => _showStudentTranscriptModal(mark.studentId, firestoreService),
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
