import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/marks_model.dart';
import '../../../widgets/status_badge.dart';

class RecentActivityTable extends StatelessWidget {
  final List<MarksModel> marks;
  final VoidCallback? onViewAll;

  const RecentActivityTable({
    super.key,
    required this.marks,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Marks Entries',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),

            // Table Content
            if (marks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.assignment_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text(
                        'No assessment marks entered yet.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 500),
                  child: DataTable(
                    horizontalMargin: 8,
                    columnSpacing: 24,
                    headingTextStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    dataTextStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    columns: const [
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Marks')),
                      DataColumn(label: Text('Grade')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: marks.take(6).map((mark) {
                      final formattedDate = mark.createdAt != null
                          ? dateFormat.format(mark.createdAt!)
                          : 'Today';

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.infoBg,
                                  child: Text(
                                    mark.studentName.isNotEmpty ? mark.studentName[0] : 'S',
                                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  mark.studentName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(mark.subjectName)),
                          DataCell(
                            Text(
                              '${mark.marksObtained.toInt()} / ${mark.maximumMarks.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(StatusBadge.grade(mark.grade)),
                          DataCell(
                            Text(
                              formattedDate,
                              style: const TextStyle(color: AppColors.textSecondary),
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
    );
  }
}
