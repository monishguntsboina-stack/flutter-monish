import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/grade_calculator.dart';

class MarksModel {
  final String id;
  final String studentId;
  final String studentRollNo;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String assessmentId;
  final String assessmentName;
  final double marksObtained;
  final double maximumMarks;
  final double percentage;
  final String grade;
  final String result; // 'Pass' or 'Fail'
  final String? remarks;
  final DateTime? createdAt;

  MarksModel({
    required this.id,
    required this.studentId,
    required this.studentRollNo,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.assessmentId,
    required this.assessmentName,
    required this.marksObtained,
    required this.maximumMarks,
    required this.percentage,
    required this.grade,
    required this.result,
    this.remarks,
    this.createdAt,
  });

  factory MarksModel.calculate({
    required String id,
    required String studentId,
    required String studentRollNo,
    required String studentName,
    required String subjectId,
    required String subjectName,
    required String assessmentId,
    required String assessmentName,
    required double marksObtained,
    required double maximumMarks,
    String? remarks,
    DateTime? createdAt,
  }) {
    final pct = GradeCalculator.calculatePercentage(marksObtained, maximumMarks);
    final grd = GradeCalculator.getGrade(pct);
    final res = GradeCalculator.getResult(pct);

    return MarksModel(
      id: id,
      studentId: studentId,
      studentRollNo: studentRollNo,
      studentName: studentName,
      subjectId: subjectId,
      subjectName: subjectName,
      assessmentId: assessmentId,
      assessmentName: assessmentName,
      marksObtained: marksObtained,
      maximumMarks: maximumMarks,
      percentage: pct,
      grade: grd,
      result: res,
      remarks: remarks,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory MarksModel.fromMap(Map<String, dynamic> map, String documentId) {
    final marksObt = (map['marksObtained'] is num)
        ? (map['marksObtained'] as num).toDouble()
        : double.tryParse(map['marksObtained']?.toString() ?? '0') ?? 0.0;
    final maxMarks = (map['maximumMarks'] is num)
        ? (map['maximumMarks'] as num).toDouble()
        : double.tryParse(map['maximumMarks']?.toString() ?? '100') ?? 100.0;
    final pct = (map['percentage'] is num)
        ? (map['percentage'] as num).toDouble()
        : GradeCalculator.calculatePercentage(marksObt, maxMarks);

    return MarksModel(
      id: documentId,
      studentId: map['studentId'] ?? '',
      studentRollNo: map['studentRollNo'] ?? '',
      studentName: map['studentName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      assessmentId: map['assessmentId'] ?? '',
      assessmentName: map['assessmentName'] ?? '',
      marksObtained: marksObt,
      maximumMarks: maxMarks,
      percentage: pct,
      grade: map['grade'] ?? GradeCalculator.getGrade(pct),
      result: map['result'] ?? GradeCalculator.getResult(pct),
      remarks: map['remarks'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentRollNo': studentRollNo,
      'studentName': studentName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'assessmentId': assessmentId,
      'assessmentName': assessmentName,
      'marksObtained': marksObtained,
      'maximumMarks': maximumMarks,
      'percentage': percentage,
      'grade': grade,
      'result': result,
      'remarks': remarks,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
