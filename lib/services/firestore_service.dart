import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/assessment_model.dart';
import '../models/marks_model.dart';
import '../models/department_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/grade_calculator.dart';

class DashboardStats {
  final int totalStudents;
  final int totalSubjects;
  final int totalAssessments;
  final int totalMarksEntries;
  final int totalFaculty;
  final int totalDepartments;
  final double averagePerformance;
  final double passPercentage;

  const DashboardStats({
    required this.totalStudents,
    required this.totalSubjects,
    required this.totalAssessments,
    required this.totalMarksEntries,
    this.totalFaculty = 6,
    this.totalDepartments = 5,
    required this.averagePerformance,
    required this.passPercentage,
  });
}

class FirestoreService extends ChangeNotifier {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  FirestoreService() {
    _initFirebase();
  }

  void _initFirebase() {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
      }
    } catch (e) {
      debugPrint('Firestore initialization notice: $e');
      _isFirebaseAvailable = false;
    }
  }

  // Pre-configured College Departments
  final List<DepartmentModel> _departments = [
    const DepartmentModel(
      id: 'dept_cse',
      code: 'CSE',
      name: 'Computer Science & Engineering',
      hodName: 'Dr. Ramesh Kumar',
      contactEmail: 'cse.hod@pscmr.ac.in',
      blockBuilding: 'APJ Abdul Kalam Block (3rd Floor)',
      totalStudents: 5,
      totalFaculty: 2,
      averagePerformance: 88.5,
      description: 'Focuses on Software Engineering, Data Structures, Algorithms, Cloud Computing, and Mobile Systems.',
    ),
    const DepartmentModel(
      id: 'dept_it',
      code: 'IT',
      name: 'Information Technology',
      hodName: 'Dr. Sanjay Gupta',
      contactEmail: 'it.hod@pscmr.ac.in',
      blockBuilding: 'Sir MV Block (2nd Floor)',
      totalStudents: 2,
      totalFaculty: 1,
      averagePerformance: 81.2,
      description: 'Focuses on Database Systems, Information Security, Web Architecture, and Enterprise Systems.',
    ),
    const DepartmentModel(
      id: 'dept_ece',
      code: 'ECE',
      name: 'Electronics & Communication',
      hodName: 'Prof. K. Venkatesh',
      contactEmail: 'ece.hod@pscmr.ac.in',
      blockBuilding: 'JC Bose Block (1st Floor)',
      totalStudents: 1,
      totalFaculty: 1,
      averagePerformance: 76.0,
      description: 'Focuses on Embedded Systems, VLSI Design, IoT, Wireless Networks, and Signal Processing.',
    ),
    const DepartmentModel(
      id: 'dept_me',
      code: 'ME',
      name: 'Mechanical Engineering',
      hodName: 'Dr. P. Murali Krishna',
      contactEmail: 'me.hod@pscmr.ac.in',
      blockBuilding: 'Visvesvaraya Workshop Complex',
      totalStudents: 1,
      totalFaculty: 1,
      averagePerformance: 79.4,
      description: 'Focuses on CAD/CAM Modeling, Thermodynamics, Mechatronics, and Robotics Automation.',
    ),
    const DepartmentModel(
      id: 'dept_aids',
      code: 'AI&DS',
      name: 'Artificial Intelligence & Data Science',
      hodName: 'Prof. S. Lakshmi',
      contactEmail: 'aids.hod@pscmr.ac.in',
      blockBuilding: 'Aryabhata Innovation Lab (4th Floor)',
      totalStudents: 1,
      totalFaculty: 1,
      averagePerformance: 84.0,
      description: 'Focuses on Machine Learning, Deep Neural Networks, Natural Language Processing, and Big Data Analytics.',
    ),
  ];

  // Pre-configured Faculty Directory
  final List<UserModel> _faculty = [
    UserModel(
      id: 'fac_1',
      employeeId: 'EMP-CSE-01',
      name: 'Dr. Ramesh Kumar',
      email: 'ramesh@assessment.edu',
      role: 'Faculty',
      phone: '9876543220',
      department: 'Computer Science & Engineering',
      designation: 'Professor & HOD',
      qualification: 'M.Tech, Ph.D (CSE)',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    UserModel(
      id: 'fac_2',
      employeeId: 'EMP-CSE-02',
      name: 'Prof. Ananya Sen',
      email: 'ananya@assessment.edu',
      role: 'Faculty',
      phone: '9876543221',
      department: 'Computer Science & Engineering',
      designation: 'Associate Professor',
      qualification: 'M.Tech (Software Engg)',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    UserModel(
      id: 'fac_3',
      employeeId: 'EMP-IT-01',
      name: 'Dr. Sanjay Gupta',
      email: 'sanjay@assessment.edu',
      role: 'Faculty',
      phone: '9876543222',
      department: 'Information Technology',
      designation: 'Professor & HOD',
      qualification: 'M.Tech, Ph.D (IT)',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    UserModel(
      id: 'fac_4',
      employeeId: 'EMP-ECE-01',
      name: 'Prof. K. Venkatesh',
      email: 'venkatesh@assessment.edu',
      role: 'Faculty',
      phone: '9876543223',
      department: 'Electronics & Communication',
      designation: 'Associate Professor',
      qualification: 'M.Tech (VLSI & Embedded)',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    UserModel(
      id: 'fac_5',
      employeeId: 'EMP-ME-01',
      name: 'Dr. P. Murali Krishna',
      email: 'murali@assessment.edu',
      role: 'Faculty',
      phone: '9876543224',
      department: 'Mechanical Engineering',
      designation: 'Professor & HOD',
      qualification: 'M.Tech, Ph.D (Thermal & CAD)',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    UserModel(
      id: 'fac_6',
      employeeId: 'EMP-AIDS-01',
      name: 'Prof. S. Lakshmi',
      email: 'lakshmi@assessment.edu',
      role: 'Faculty',
      phone: '9876543225',
      department: 'Artificial Intelligence & Data Science',
      designation: 'Assistant Professor',
      qualification: 'M.Tech (Data Science)',
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
    ),
  ];

  // In-memory persistent students roster
  final List<StudentModel> _students = [
    StudentModel(
      id: 'stu_1',
      studentId: 'STU2024001',
      name: 'Ravi Kumar',
      email: 'ravi@example.com',
      phone: '9876543210',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'A',
      rollNumber: '23CS001',
    ),
    StudentModel(
      id: 'stu_2',
      studentId: 'STU2024002',
      name: 'Priya Sharma',
      email: 'priya@example.com',
      phone: '9876543211',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'A',
      rollNumber: '23CS002',
    ),
    StudentModel(
      id: 'stu_3',
      studentId: 'STU2024003',
      name: 'Amit Singh',
      email: 'amit@example.com',
      phone: '9876543212',
      department: 'Information Technology',
      year: '3rd Year',
      section: 'B',
      rollNumber: '23IT001',
    ),
    StudentModel(
      id: 'stu_4',
      studentId: 'STU2024004',
      name: 'Sneha Patel',
      email: 'sneha@example.com',
      phone: '9876543213',
      department: 'Computer Science & Engineering',
      year: '2nd Year',
      section: 'A',
      rollNumber: '23CS004',
    ),
    StudentModel(
      id: 'stu_5',
      studentId: 'STU2024005',
      name: 'Vikram Joshi',
      email: 'vikram@example.com',
      phone: '9876543214',
      department: 'Electronics & Communication',
      year: '3rd Year',
      section: 'A',
      rollNumber: '23EC001',
    ),
    StudentModel(
      id: 'stu_6',
      studentId: 'STU2024006',
      name: 'Neha Verma',
      email: 'neha@example.com',
      phone: '9876543215',
      department: 'Information Technology',
      year: '4th Year',
      section: 'B',
      rollNumber: '23IT002',
    ),
    StudentModel(
      id: 'stu_7',
      studentId: 'STU2024007',
      name: 'Aditya Reddy',
      email: 'aditya@example.com',
      phone: '9876543216',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'B',
      rollNumber: '23CS007',
    ),
    StudentModel(
      id: 'stu_8',
      studentId: 'STU2024008',
      name: 'Ananya Roy',
      email: 'ananya@example.com',
      phone: '9876543217',
      department: 'Mechanical Engineering',
      year: '2nd Year',
      section: 'A',
      rollNumber: '23ME001',
    ),
    StudentModel(
      id: 'stu_9',
      studentId: 'STU2024009',
      name: 'Karthik Nambiar',
      email: 'karthik@example.com',
      phone: '9876543218',
      department: 'Artificial Intelligence & Data Science',
      year: '2nd Year',
      section: 'A',
      rollNumber: '23AI001',
    ),
  ];

  final List<SubjectModel> _subjects = [
    SubjectModel(
      id: 'sub_1',
      subjectCode: 'CS101',
      subjectName: 'Data Structures & Algorithms',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      semester: 'Semester 5',
      facultyId: 'fac_1',
      facultyName: 'Dr. Ramesh Kumar',
      maxMarks: 100,
    ),
    SubjectModel(
      id: 'sub_2',
      subjectCode: 'CS102',
      subjectName: 'Web Development & Cloud',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      semester: 'Semester 5',
      facultyId: 'fac_2',
      facultyName: 'Prof. Ananya Sen',
      maxMarks: 100,
    ),
    SubjectModel(
      id: 'sub_3',
      subjectCode: 'IT103',
      subjectName: 'Database Management Systems',
      department: 'Information Technology',
      year: '3rd Year',
      semester: 'Semester 5',
      facultyId: 'fac_3',
      facultyName: 'Dr. Sanjay Gupta',
      maxMarks: 100,
    ),
    SubjectModel(
      id: 'sub_4',
      subjectCode: 'CS104',
      subjectName: 'Operating Systems',
      department: 'Computer Science & Engineering',
      year: '2nd Year',
      semester: 'Semester 4',
      facultyId: 'fac_1',
      facultyName: 'Dr. Ramesh Kumar',
      maxMarks: 100,
    ),
    SubjectModel(
      id: 'sub_5',
      subjectCode: 'EC105',
      subjectName: 'Computer Networks & IoT',
      department: 'Electronics & Communication',
      year: '3rd Year',
      semester: 'Semester 6',
      facultyId: 'fac_4',
      facultyName: 'Prof. K. Venkatesh',
      maxMarks: 100,
    ),
    SubjectModel(
      id: 'sub_6',
      subjectCode: 'ME106',
      subjectName: 'CAD/CAM Modeling & Robotics',
      department: 'Mechanical Engineering',
      year: '2nd Year',
      semester: 'Semester 4',
      facultyId: 'fac_5',
      facultyName: 'Dr. P. Murali Krishna',
      maxMarks: 100,
    ),
  ];

  final List<AssessmentModel> _assessments = [
    AssessmentModel(
      id: 'asm_1',
      name: 'Mid Examination 1',
      type: AppConstants.typeMidExam,
      subjectId: 'sub_1',
      subjectName: 'Data Structures & Algorithms',
      maximumMarks: 100,
      date: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Covers Trees, Graphs, Sorting, and Dynamic Programming algorithms.',
    ),
    AssessmentModel(
      id: 'asm_2',
      name: 'Full Stack Project 1',
      type: AppConstants.typeProject,
      subjectId: 'sub_2',
      subjectName: 'Web Development & Cloud',
      maximumMarks: 100,
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Development of responsive web application with backend API integration.',
    ),
    AssessmentModel(
      id: 'asm_3',
      name: 'DBMS Quiz 2',
      type: AppConstants.typeQuiz,
      subjectId: 'sub_3',
      subjectName: 'Database Management Systems',
      maximumMarks: 50,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'SQL Queries, Normalization forms 1NF to BCNF, and Indexing.',
    ),
    AssessmentModel(
      id: 'asm_4',
      name: 'OS Architecture Assignment',
      type: AppConstants.typeAssignment,
      subjectId: 'sub_4',
      subjectName: 'Operating Systems',
      maximumMarks: 50,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Process Synchronization, Semaphores, and Deadlock Avoidance.',
    ),
    AssessmentModel(
      id: 'asm_5',
      name: 'Networks Final Exam',
      type: AppConstants.typeFinalExam,
      subjectId: 'sub_5',
      subjectName: 'Computer Networks & IoT',
      maximumMarks: 100,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Comprehensive evaluation of TCP/IP, OSI model, and Routing protocols.',
    ),
  ];

  final List<MarksModel> _marks = [
    MarksModel(
      id: 'mark_1',
      studentId: 'stu_1',
      studentRollNo: '23CS001',
      studentName: 'Ravi Kumar',
      subjectId: 'sub_1',
      subjectName: 'Data Structures & Algorithms',
      assessmentId: 'asm_1',
      assessmentName: 'Mid Examination 1',
      marksObtained: 85,
      maximumMarks: 100,
      percentage: 85.0,
      grade: 'A',
      result: 'Pass',
      remarks: 'Excellent algorithmic intuition and clean syntax',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MarksModel(
      id: 'mark_2',
      studentId: 'stu_2',
      studentRollNo: '23CS002',
      studentName: 'Priya Sharma',
      subjectId: 'sub_2',
      subjectName: 'Web Development & Cloud',
      assessmentId: 'asm_2',
      assessmentName: 'Full Stack Project 1',
      marksObtained: 92,
      maximumMarks: 100,
      percentage: 92.0,
      grade: 'A+',
      result: 'Pass',
      remarks: 'Outstanding UI design and seamless state management',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MarksModel(
      id: 'mark_3',
      studentId: 'stu_3',
      studentRollNo: '23IT001',
      studentName: 'Amit Singh',
      subjectId: 'sub_3',
      subjectName: 'Database Management Systems',
      assessmentId: 'asm_3',
      assessmentName: 'DBMS Quiz 2',
      marksObtained: 39,
      maximumMarks: 50,
      percentage: 78.0,
      grade: 'B+',
      result: 'Pass',
      remarks: 'Strong SQL query optimization',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MarksModel(
      id: 'mark_4',
      studentId: 'stu_4',
      studentRollNo: '23CS004',
      studentName: 'Sneha Patel',
      subjectId: 'sub_4',
      subjectName: 'Operating Systems',
      assessmentId: 'asm_4',
      assessmentName: 'OS Architecture Assignment',
      marksObtained: 44,
      maximumMarks: 50,
      percentage: 88.0,
      grade: 'A',
      result: 'Pass',
      remarks: 'Well formulated solutions for deadlock avoidance',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    MarksModel(
      id: 'mark_5',
      studentId: 'stu_5',
      studentRollNo: '23EC001',
      studentName: 'Vikram Joshi',
      subjectId: 'sub_5',
      subjectName: 'Computer Networks & IoT',
      assessmentId: 'asm_5',
      assessmentName: 'Networks Final Exam',
      marksObtained: 76,
      maximumMarks: 100,
      percentage: 76.0,
      grade: 'B+',
      result: 'Pass',
      remarks: 'Good grasp of network layers',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MarksModel(
      id: 'mark_6',
      studentId: 'stu_6',
      studentRollNo: '23IT002',
      studentName: 'Neha Verma',
      subjectId: 'sub_3',
      subjectName: 'Database Management Systems',
      assessmentId: 'asm_3',
      assessmentName: 'DBMS Quiz 2',
      marksObtained: 32,
      maximumMarks: 50,
      percentage: 64.0,
      grade: 'B',
      result: 'Pass',
      remarks: 'Needs improvement in relational algebra',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    MarksModel(
      id: 'mark_7',
      studentId: 'stu_7',
      studentRollNo: '23CS007',
      studentName: 'Aditya Reddy',
      subjectId: 'sub_2',
      subjectName: 'Web Development & Cloud',
      assessmentId: 'asm_2',
      assessmentName: 'Full Stack Project 1',
      marksObtained: 96,
      maximumMarks: 100,
      percentage: 96.0,
      grade: 'A+',
      result: 'Pass',
      remarks: 'Class top project score, exceptional architecture',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    MarksModel(
      id: 'mark_8',
      studentId: 'stu_8',
      studentRollNo: '23ME001',
      studentName: 'Ananya Roy',
      subjectId: 'sub_6',
      subjectName: 'CAD/CAM Modeling & Robotics',
      assessmentId: 'asm_2',
      assessmentName: 'Full Stack Project 1',
      marksObtained: 82,
      maximumMarks: 100,
      percentage: 82.0,
      grade: 'A',
      result: 'Pass',
      remarks: 'Solid 3D model simulation',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  // ================= DASHBOARD AGGREGATES =================

  Future<DashboardStats> getDashboardStats() async {
    if (_firestore != null) {
      try {
        final studentsSnap = await _firestore!.collection(AppConstants.colStudents).get();
        final subjectsSnap = await _firestore!.collection(AppConstants.colSubjects).get();
        final assessmentsSnap = await _firestore!.collection(AppConstants.colAssessments).get();
        final marksSnap = await _firestore!.collection(AppConstants.colMarks).get();

        if (studentsSnap.docs.isNotEmpty || marksSnap.docs.isNotEmpty) {
          final totalStudents = studentsSnap.docs.isNotEmpty ? studentsSnap.docs.length : _students.length;
          final totalSubjects = subjectsSnap.docs.isNotEmpty ? subjectsSnap.docs.length : _subjects.length;
          final totalAssessments = assessmentsSnap.docs.isNotEmpty ? assessmentsSnap.docs.length : _assessments.length;
          final totalMarksEntries = marksSnap.docs.isNotEmpty ? marksSnap.docs.length : _marks.length;

          double totalPct = 0;
          int passCount = 0;

          final marksList = marksSnap.docs.isNotEmpty
              ? marksSnap.docs.map((d) => MarksModel.fromMap(d.data(), d.id)).toList()
              : _marks;

          for (final mark in marksList) {
            totalPct += mark.percentage;
            if (mark.result.toLowerCase() == 'pass') passCount++;
          }

          final avgPerf = marksList.isNotEmpty ? (totalPct / marksList.length) : 0.0;
          final passPct = marksList.isNotEmpty ? ((passCount / marksList.length) * 100.0) : 0.0;

          return DashboardStats(
            totalStudents: totalStudents,
            totalSubjects: totalSubjects,
            totalAssessments: totalAssessments,
            totalMarksEntries: totalMarksEntries,
            totalFaculty: _faculty.length,
            totalDepartments: _departments.length,
            averagePerformance: double.parse(avgPerf.toStringAsFixed(1)),
            passPercentage: double.parse(passPct.toStringAsFixed(1)),
          );
        }
      } catch (e) {
        debugPrint('Firestore aggregation notice: $e');
      }
    }

    // Compute live stats from in-memory fallback
    double totalPct = 0;
    int passCount = 0;
    for (final mark in _marks) {
      totalPct += mark.percentage;
      if (mark.result.toLowerCase() == 'pass') passCount++;
    }
    final avgPerf = _marks.isNotEmpty ? (totalPct / _marks.length) : 82.4;
    final passPct = _marks.isNotEmpty ? ((passCount / _marks.length) * 100.0) : 87.45;

    return DashboardStats(
      totalStudents: _students.length,
      totalSubjects: _subjects.length,
      totalAssessments: _assessments.length,
      totalMarksEntries: _marks.length,
      totalFaculty: _faculty.length,
      totalDepartments: _departments.length,
      averagePerformance: double.parse(avgPerf.toStringAsFixed(1)),
      passPercentage: double.parse(passPct.toStringAsFixed(1)),
    );
  }

  Stream<List<MarksModel>> getRecentMarksStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection(AppConstants.colMarks)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots()
            .map((snapshot) {
              if (snapshot.docs.isEmpty) return _marks;
              return snapshot.docs.map((doc) => MarksModel.fromMap(doc.data(), doc.id)).toList();
            });
      } catch (e) {
        return Stream.value(_marks);
      }
    }
    return Stream.value(_marks);
  }

  // ================= DEPARTMENTS MANAGEMENT =================

  List<DepartmentModel> get departments => List.unmodifiable(_departments);

  Stream<List<DepartmentModel>> getDepartmentsStream() {
    return Stream.value(_departments);
  }

  DepartmentModel? getDepartmentByCode(String code) {
    try {
      return _departments.firstWhere(
        (d) => d.code.toLowerCase() == code.toLowerCase() || d.name.toLowerCase().contains(code.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  // ================= FACULTY MANAGEMENT =================

  List<UserModel> get faculty => List.unmodifiable(_faculty);

  Stream<List<UserModel>> getFacultyStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection(AppConstants.colUsers)
            .where('role', isEqualTo: 'Faculty')
            .snapshots()
            .map((snap) {
              if (snap.docs.isEmpty) return _faculty;
              return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
            });
      } catch (_) {
        return Stream.value(_faculty);
      }
    }
    return Stream.value(_faculty);
  }

  List<UserModel> getFacultyByDepartment(String departmentName) {
    final search = departmentName.toLowerCase();
    return _faculty.where((f) {
      final dept = (f.department ?? '').toLowerCase();
      return dept.contains(search) || search.contains(dept);
    }).toList();
  }

  Future<void> addFaculty(UserModel member) async {
    final newFaculty = member.id.isEmpty
        ? member.copyWith(id: 'fac_${DateTime.now().millisecondsSinceEpoch}')
        : member;
    _faculty.insert(0, newFaculty);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colUsers).doc(newFaculty.id).set(newFaculty.toMap());
      } catch (e) {
        debugPrint('Firestore addFaculty notice: $e');
      }
    }
  }

  Future<void> updateFaculty(UserModel member) async {
    final idx = _faculty.indexWhere((f) => f.id == member.id);
    if (idx != -1) {
      _faculty[idx] = member;
      notifyListeners();
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colUsers).doc(member.id).update(member.toMap());
      } catch (e) {
        debugPrint('Firestore updateFaculty notice: $e');
      }
    }
  }

  Future<void> deleteFaculty(String facultyId) async {
    _faculty.removeWhere((f) => f.id == facultyId);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colUsers).doc(facultyId).delete();
      } catch (e) {
        debugPrint('Firestore deleteFaculty notice: $e');
      }
    }
  }

  // ================= STUDENT CRUD & DEPARTMENT FILTER =================

  List<StudentModel> get students => List.unmodifiable(_students);

  Stream<List<StudentModel>> getStudentsStream() {
    if (_firestore != null) {
      try {
        return _firestore!.collection(AppConstants.colStudents).snapshots().map((snapshot) {
          if (snapshot.docs.isEmpty) return _students;
          return snapshot.docs.map((doc) => StudentModel.fromMap(doc.data(), doc.id)).toList();
        });
      } catch (e) {
        return Stream.value(_students);
      }
    }
    return Stream.value(_students);
  }

  List<StudentModel> getStudentsByDepartment(String departmentName) {
    final search = departmentName.toLowerCase();
    return _students.where((s) {
      final dept = s.department.toLowerCase();
      return dept.contains(search) || search.contains(dept);
    }).toList();
  }

  Future<void> addStudent(StudentModel student) async {
    final newStudent = student.id.isEmpty
        ? student.copyWith(id: 'stu_${DateTime.now().millisecondsSinceEpoch}')
        : student;

    _students.insert(0, newStudent);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colStudents).doc(newStudent.id).set(newStudent.toMap());
      } catch (e) {
        debugPrint('Firestore addStudent synced to local cache: $e');
      }
    }
  }

  Future<void> updateStudent(StudentModel student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colStudents).doc(student.id).update(student.toMap());
      } catch (e) {
        debugPrint('Firestore updateStudent synced to local cache: $e');
      }
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    _marks.removeWhere((m) => m.studentId == studentId);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colStudents).doc(studentId).delete();
      } catch (e) {
        debugPrint('Firestore deleteStudent: $e');
      }
    }
  }

  // ================= SUBJECT CRUD =================

  List<SubjectModel> get subjects => List.unmodifiable(_subjects);

  Stream<List<SubjectModel>> getSubjectsStream() {
    if (_firestore != null) {
      try {
        return _firestore!.collection(AppConstants.colSubjects).snapshots().map((snapshot) {
          if (snapshot.docs.isEmpty) return _subjects;
          return snapshot.docs.map((doc) => SubjectModel.fromMap(doc.data(), doc.id)).toList();
        });
      } catch (e) {
        return Stream.value(_subjects);
      }
    }
    return Stream.value(_subjects);
  }

  List<SubjectModel> getSubjectsByDepartment(String departmentName) {
    final search = departmentName.toLowerCase();
    return _subjects.where((sub) {
      final dept = sub.department.toLowerCase();
      return dept.contains(search) || search.contains(dept);
    }).toList();
  }

  Future<void> addSubject(SubjectModel subject) async {
    final newSubject = subject.id.isEmpty
        ? subject.copyWith(id: 'sub_${DateTime.now().millisecondsSinceEpoch}')
        : subject;

    _subjects.insert(0, newSubject);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colSubjects).doc(newSubject.id).set(newSubject.toMap());
      } catch (e) {
        debugPrint('Firestore addSubject: $e');
      }
    }
  }

  Future<void> updateSubject(SubjectModel subject) async {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
      notifyListeners();
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colSubjects).doc(subject.id).update(subject.toMap());
      } catch (e) {
        debugPrint('Firestore updateSubject: $e');
      }
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.id == subjectId);
    _assessments.removeWhere((a) => a.subjectId == subjectId);
    _marks.removeWhere((m) => m.subjectId == subjectId);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colSubjects).doc(subjectId).delete();
      } catch (e) {
        debugPrint('Firestore deleteSubject: $e');
      }
    }
  }

  // ================= ASSESSMENT CRUD =================

  List<AssessmentModel> get assessments => List.unmodifiable(_assessments);

  Stream<List<AssessmentModel>> getAssessmentsStream() {
    if (_firestore != null) {
      try {
        return _firestore!.collection(AppConstants.colAssessments).snapshots().map((snapshot) {
          if (snapshot.docs.isEmpty) return _assessments;
          return snapshot.docs.map((doc) => AssessmentModel.fromMap(doc.data(), doc.id)).toList();
        });
      } catch (e) {
        return Stream.value(_assessments);
      }
    }
    return Stream.value(_assessments);
  }

  Future<void> addAssessment(AssessmentModel assessment) async {
    final newAssessment = assessment.id.isEmpty
        ? assessment.copyWith(id: 'asm_${DateTime.now().millisecondsSinceEpoch}')
        : assessment;

    _assessments.insert(0, newAssessment);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colAssessments).doc(newAssessment.id).set(newAssessment.toMap());
      } catch (e) {
        debugPrint('Firestore addAssessment: $e');
      }
    }
  }

  Future<void> updateAssessment(AssessmentModel assessment) async {
    final index = _assessments.indexWhere((a) => a.id == assessment.id);
    if (index != -1) {
      _assessments[index] = assessment;
      notifyListeners();
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colAssessments).doc(assessment.id).update(assessment.toMap());
      } catch (e) {
        debugPrint('Firestore updateAssessment: $e');
      }
    }
  }

  Future<void> deleteAssessment(String assessmentId) async {
    _assessments.removeWhere((a) => a.id == assessmentId);
    _marks.removeWhere((m) => m.assessmentId == assessmentId);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colAssessments).doc(assessmentId).delete();
      } catch (e) {
        debugPrint('Firestore deleteAssessment: $e');
      }
    }
  }

  // ================= MARKS CRUD & EVALUATION =================

  List<MarksModel> get marks => List.unmodifiable(_marks);

  Stream<List<MarksModel>> getMarksStream() {
    if (_firestore != null) {
      try {
        return _firestore!.collection(AppConstants.colMarks).snapshots().map((snapshot) {
          if (snapshot.docs.isEmpty) return _marks;
          return snapshot.docs.map((doc) => MarksModel.fromMap(doc.data(), doc.id)).toList();
        });
      } catch (e) {
        return Stream.value(_marks);
      }
    }
    return Stream.value(_marks);
  }

  Future<void> saveMarks(MarksModel mark) async {
    final existingIndex = _marks.indexWhere((m) =>
        m.id == mark.id || (m.studentId == mark.studentId && m.assessmentId == mark.assessmentId));

    if (existingIndex != -1) {
      _marks[existingIndex] = mark;
    } else {
      final newMark = mark.id.isEmpty
          ? MarksModel.calculate(
              id: 'mark_${DateTime.now().millisecondsSinceEpoch}',
              studentId: mark.studentId,
              studentRollNo: mark.studentRollNo,
              studentName: mark.studentName,
              subjectId: mark.subjectId,
              subjectName: mark.subjectName,
              assessmentId: mark.assessmentId,
              assessmentName: mark.assessmentName,
              marksObtained: mark.marksObtained,
              maximumMarks: mark.maximumMarks,
              remarks: mark.remarks,
              createdAt: mark.createdAt ?? DateTime.now(),
            )
          : mark;
      _marks.insert(0, newMark);
    }

    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colMarks).doc(mark.id.isNotEmpty ? mark.id : null).set(mark.toMap());
      } catch (e) {
        debugPrint('Firestore saveMarks: $e');
      }
    }
  }

  Future<void> deleteMark(String markId) async {
    _marks.removeWhere((m) => m.id == markId);
    notifyListeners();

    if (_firestore != null) {
      try {
        await _firestore!.collection(AppConstants.colMarks).doc(markId).delete();
      } catch (e) {
        debugPrint('Firestore deleteMark: $e');
      }
    }
  }

  // ================= REPORT & DEPARTMENT ANALYTICS =================

  List<MarksModel> getTopPerformers({int limit = 5}) {
    final sorted = List<MarksModel>.from(_marks)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    return sorted.take(limit).toList();
  }

  List<MarksModel> getImprovementRequiredStudents() {
    return _marks.where((m) => m.percentage < GradeCalculator.passingPercentage || m.result == 'Fail').toList();
  }

  List<MarksModel> getMarksForStudent(String studentId) {
    return _marks.where((m) => m.studentId == studentId).toList();
  }

  List<MarksModel> getMarksForSubject(String subjectId) {
    return _marks.where((m) => m.subjectId == subjectId).toList();
  }

  List<MarksModel> getMarksForDepartment(String departmentName) {
    final deptStudents = getStudentsByDepartment(departmentName).map((s) => s.id).toSet();
    return _marks.where((m) => deptStudents.contains(m.studentId)).toList();
  }

  double getDepartmentAveragePerformance(String departmentName) {
    final deptMarks = getMarksForDepartment(departmentName);
    if (deptMarks.isEmpty) return 80.0;
    double total = 0;
    for (final m in deptMarks) {
      total += m.percentage;
    }
    return double.parse((total / deptMarks.length).toStringAsFixed(1));
  }
}
