import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String studentId; // e.g., STU2024001
  final String name;
  final String email;
  final String phone;
  final String department;
  final String year;
  final String section;
  final String rollNumber; // e.g., 23CS001
  final DateTime? createdAt;

  StudentModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    required this.section,
    required this.rollNumber,
    this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StudentModel(
      id: documentId,
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      section: map['section'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
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
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'year': year,
      'section': section,
      'rollNumber': rollNumber,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  StudentModel copyWith({
    String? id,
    String? studentId,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? year,
    String? section,
    String? rollNumber,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
