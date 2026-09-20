class DepartmentModel {
  final String id;
  final String code; // e.g. CSE, IT, ECE, ME, AIDS
  final String name;
  final String hodName;
  final String contactEmail;
  final String blockBuilding;
  final int totalStudents;
  final int totalFaculty;
  final double averagePerformance;
  final String description;

  const DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    required this.hodName,
    required this.contactEmail,
    required this.blockBuilding,
    required this.totalStudents,
    required this.totalFaculty,
    required this.averagePerformance,
    required this.description,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DepartmentModel(
      id: docId,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      hodName: map['hodName'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      blockBuilding: map['blockBuilding'] ?? 'Main Block',
      totalStudents: (map['totalStudents'] as num?)?.toInt() ?? 0,
      totalFaculty: (map['totalFaculty'] as num?)?.toInt() ?? 0,
      averagePerformance: (map['averagePerformance'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'hodName': hodName,
      'contactEmail': contactEmail,
      'blockBuilding': blockBuilding,
      'totalStudents': totalStudents,
      'totalFaculty': totalFaculty,
      'averagePerformance': averagePerformance,
      'description': description,
    };
  }
}
