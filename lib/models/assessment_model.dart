import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentModel {
  final String id;
  final String name;
  final String type; // Assignment, Quiz, Mid Examination, Project, Final Examination
  final String subjectId;
  final String? subjectName;
  final double maximumMarks;
  final DateTime date;
  final String description;
  final DateTime? createdAt;

  AssessmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subjectId,
    this.subjectName,
    required this.maximumMarks,
    required this.date,
    required this.description,
    this.createdAt,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssessmentModel(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'Assignment',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'],
      maximumMarks: (map['maximumMarks'] is num)
          ? (map['maximumMarks'] as num).toDouble()
          : double.tryParse(map['maximumMarks']?.toString() ?? '100') ?? 100.0,
      date: map['date'] != null
          ? (map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'maximumMarks': maximumMarks,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  AssessmentModel copyWith({
    String? id,
    String? name,
    String? type,
    String? subjectId,
    String? subjectName,
    double? maximumMarks,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      maximumMarks: maximumMarks ?? this.maximumMarks,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
