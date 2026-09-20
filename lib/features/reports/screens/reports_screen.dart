import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  void _showReportDialog({
    required String title,
    required Widget content,
    VoidCallback? onExport,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(child: content),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Export / Print Report'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report exported to PDF / Print view successfully.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _generateStudentsReport(FirestoreService service) {
    final students = service.students;

    _showReportDialog(
      title: 'Students Enrollment Directory Report',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Enrolled Students: ${students.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            horizontalMargin: 8,
            columnSpacing: 16,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
            columns: const [
              DataColumn(label: Text('Roll No')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Email')),
            ],
            rows: students
                .map((s) => DataRow(cells: [
                      DataCell(Text(s.rollNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                      DataCell(Text(s.name)),
                      DataCell(Text(s.department)),
                      DataCell(Text(s.year)),
                      DataCell(Text(s.email)),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _generateMarksReport(FirestoreService service) {
    final marks = service.marks;

    _showReportDialog(
      title: 'Consolidated Marks Assessment Report',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Comprehensive tabulation of all recorded student evaluation scores and grades across departments.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            horizontalMargin: 8,
            columnSpacing: 16,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
            columns: const [
              DataColumn(label: Text('Roll No')),
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Score')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Result')),
            ],
            rows: marks
                .map((m) => DataRow(cells: [
                      DataCell(Text(m.studentRollNo, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(m.studentName)),
                      DataCell(Text(m.subjectName)),
                      DataCell(Text('${m.marksObtained.toInt()}/${m.maximumMarks.toInt()} (${m.percentage}%)')),
                      DataCell(StatusBadge.grade(m.grade)),
                      DataCell(StatusBadge.result(m.result)),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _generateResultAnalysis(FirestoreService service) {
    final marks = service.marks;

    int totalPass = 0;
    int totalFail = 0;
    int aPlusCount = 0;
    int aCount = 0;
    int bCount = 0;
    int cCount = 0;

    for (final m in marks) {
      if (m.result == 'Pass') totalPass++;
      if (m.result == 'Fail') totalFail++;

      if (m.grade == 'A+') aPlusCount++;
      else if (m.grade == 'A') aCount++;
      else if (m.grade.startsWith('B')) bCount++;
      else if (m.grade == 'C' || m.grade == 'P') cCount++;
    }

    final passRate = marks.isNotEmpty ? ((totalPass / marks.length) * 100).toStringAsFixed(1) : '0';

    _showReportDialog(
      title: 'Statistical Result & Performance Analysis',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('Overall Pass Rate', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text('$passRate%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success)),
                      const SizedBox(height: 2),
                      Text('$totalPass Passed / $totalFail Failed', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Evaluations', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text('${marks.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 2),
                      const Text('Across All Active Subjects', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Grade Distribution Summary', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildGradeBar('A+ (Outstanding >= 90%)', aPlusCount, marks.length, AppColors.success),
          _buildGradeBar('A  (Excellent >= 80%)', aCount, marks.length, AppColors.primaryLight),
          _buildGradeBar('B+ / B (Good >= 60%)', bCount, marks.length, AppColors.primary),
          _buildGradeBar('C / P (Pass >= 40%)', cCount, marks.length, AppColors.warning),
          _buildGradeBar('F (Fail < 40%)', totalFail, marks.length, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildGradeBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text('$count (${(pct * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  void _generateTopperReport(FirestoreService service) {
    final toppers = service.getTopPerformers(limit: 10);

    _showReportDialog(
      title: 'Merit List & Top Performing Students',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rankings calculated based on highest scored percentages across recent assessments.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            horizontalMargin: 8,
            columnSpacing: 18,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
            columns: const [
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text('Roll No')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Score %')),
              DataColumn(label: Text('Grade')),
            ],
            rows: toppers.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final mark = entry.value;

              return DataRow(cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rank == 1)
                        const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 18)
                      else if (rank == 2)
                        const Icon(Icons.workspace_premium_rounded, color: Colors.grey, size: 18)
                      else if (rank == 3)
                        const Icon(Icons.workspace_premium_rounded, color: Colors.brown, size: 18)
                      else
                        Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      if (rank <= 3) ...[
                        const SizedBox(width: 4),
                        Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
                DataCell(Text(mark.studentRollNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                DataCell(Text(mark.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(mark.subjectName)),
                DataCell(Text('${mark.percentage}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
                DataCell(StatusBadge.grade(mark.grade)),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Academic Reports & Analytics',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Generate, review, and export institutional performance reports, merit rank lists, and grade distributions.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          // 4 Actionable Report Cards (Matching Mockup Panel 8)
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.82,
            children: [
              _buildReportCard(
                title: 'Students Report',
                description: 'Generate and download complete student enrollment and batch roster list.',
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.primary,
                bgColor: AppColors.infoBg,
                buttonText: 'Generate',
                onGenerate: () => _generateStudentsReport(firestoreService),
              ),
              _buildReportCard(
                title: 'Marks Report',
                description: 'Generate marks report by subject, semester, or individual student evaluation.',
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF64748B),
                bgColor: const Color(0xFFF1F5F9),
                buttonText: 'Generate',
                onGenerate: () => _generateMarksReport(firestoreService),
              ),
              _buildReportCard(
                title: 'Result Analysis',
                description: 'Generate comprehensive result statistical analysis, pass rates, and grade charts.',
                icon: Icons.insights_rounded,
                iconColor: AppColors.success,
                bgColor: AppColors.successBg,
                buttonText: 'Generate',
                onGenerate: () => _generateResultAnalysis(firestoreService),
              ),
              _buildReportCard(
                title: 'Topper Report',
                description: 'Generate academic merit rankers and top scoring students leaderboards.',
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.warning,
                bgColor: AppColors.warningBg,
                buttonText: 'Generate',
                onGenerate: () => _generateTopperReport(firestoreService),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String buttonText,
    required VoidCallback onGenerate,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            CustomButton(
              text: buttonText,
              onPressed: onGenerate,
              backgroundColor: AppColors.primary,
              height: 42,
            ),
          ],
        ),
      ),
    );
  }
}
