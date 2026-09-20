class AppConstants {
  static const String appName = 'Smart Student Assessment Management System';
  static const String appShortName = 'SmartAssessment';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleAdmin = 'Admin';
  static const String roleFaculty = 'Faculty';
  static const List<String> userRoles = [roleAdmin, roleFaculty];

  // Assessment Types
  static const String typeAssignment = 'Assignment';
  static const String typeQuiz = 'Quiz';
  static const String typeMidExam = 'Mid Examination';
  static const String typeProject = 'Project';
  static const String typeFinalExam = 'Final Examination';

  static const List<String> assessmentTypes = [
    typeAssignment,
    typeQuiz,
    typeMidExam,
    typeProject,
    typeFinalExam,
  ];

  // Departments
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
  ];

  // Years & Semesters
  static const List<String> academicYears = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  static const List<String> sections = ['A', 'B', 'C', 'D'];
  static const List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colStudents = 'students';
  static const String colSubjects = 'subjects';
  static const String colAssessments = 'assessments';
  static const String colMarks = 'marks';
}
