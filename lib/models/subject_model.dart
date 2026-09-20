import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String subjectCode; // e.g., CS101
  final String subjectName; // e.g., Data Structures
  final String department;
  final String year;
  final String semester;
  final String facultyId;
  final String? facultyName;
  final int maxMarks;
  final DateTime? createdAt;

  SubjectModel({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.department,
    required this.year,
    required this.semester,
    required this.facultyId,
    this.facultyName,
    this.maxMarks = 100,
    this.createdAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubjectModel(
      id: documentId,
      subjectCode: map['subjectCode'] ?? '',
      subjectName: map['subjectName'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'],
      maxMarks: map['maxMarks'] is int ? map['maxMarks'] : int.tryParse(map['maxMarks']?.toString() ?? '100') ?? 100,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'department': department,
      'year': year,
      'semester': semester,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'maxMarks': maxMarks,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  SubjectModel copyWith({
    String? id,
    String? subjectCode,
    String? subjectName,
    String? department,
    String? year,
    String? semester,
    String? facultyId,
    String? facultyName,
    int? maxMarks,
    DateTime? createdAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      department: department ?? this.department,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      maxMarks: maxMarks ?? this.maxMarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
