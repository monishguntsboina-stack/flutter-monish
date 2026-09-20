# Smart Student Assessment Management System

A Full Stack College Development Project built using **Flutter**, **Dart**, **Firebase Authentication**, and **Cloud Firestore** for managing student academic assessments, marks, grades, and performance reports.

---

## Complete Features

### 1. 📊 Dashboard Overview
- **Metric Cards**: Total Students, Total Subjects, Total Marks Entries, Overall Pass Percentage.
- **Recent Marks Activity**: Live data table showing student names, subjects, marks scored, automated grade badges, and dates.
- **Quick Action Bar**: Fast 1-click access to add students, register subjects, record marks, and generate reports.
- **Top Navigation Bar**: Search bar, notification alerts, and active user profile indicator with role badges.

### 2. 👨‍🎓 Student Management
- **Student Roster**: Full data table showing `#`, Roll Number, Name, Email, Phone, Department, and Year/Section.
- **Search & Filters**: Real-time filtering by Name, Roll Number, Student ID, Department, and Academic Year.
- **CRUD Operations**: Add new students, edit demographic/contact info, view academic transcripts, and delete with safety confirmation.
- **Pagination**: Scalable table pagination controls.

### 3. 📚 Subject Curriculum Management
- **Curriculum Roster**: Course codes, Subject Titles, Departments, Semesters, Max Marks, and Assigned Faculty.
- **CRUD Operations**: Add new courses, update details, assign faculty, and delete subjects.
- **Department Filters & Search**: Search by course code or faculty name.

### 4. 📝 Assessment Management
- **Assessment Categories**: Assignments, Quizzes, Mid Examinations, Projects, and Final Examinations.
- **Scheduling**: Dates, Maximum Marks, Description, and Subject linkages.
- **Filter & Management**: Filter by subject or assessment category.

### 5. ✍️ Marks Entry & Automated Evaluation
- **Interactive Form**:
  - Select Student (by Roll No / Name).
  - Select Subject.
  - Select Assessment.
  - Maximum Marks auto-fill.
  - Marks Obtained input.
  - **Live Real-time Computation**: Automated calculation of **Percentage**, **Grade (A+, A, B+, B, C, P, F)**, and **Pass/Fail Result**.
  - Assessment date and remarks.
- **Recent Entries Log**: Instant feedback showing recent mark entries with grade badges.

### 6. 📈 Student Performance & Results
- **Results Explorer**: Filter by Student, Subject, or Search query.
- **Data Table**: Roll No, Name, Subject, Assessment, Score, Grade, and Status.
- **Individual Student Transcript Modal**: Summary of cumulative average, passed exams ratio, and complete history.

### 7. 📄 Academic Reports & Analytics
- **Students Report**: Roster report generation and export.
- **Marks Report**: Consolidated mark sheet tabulation.
- **Statistical Result Analysis**: Overall pass rate, total evaluations, and Grade Distribution progress bars (A+, A, B, C, F).
- **Topper / Merit List**: Leaderboard ranking top scoring students per department and exam.

### 8. 👤 Profile & Account Settings
- **Profile Information**: Update name, phone, email, and view user role badge (Admin / Faculty).
- **Security**: Change password with validation and confirmation.

---

## Technology Stack

- **Flutter 3.x** & **Dart**
- **Firebase Authentication** (Email & Password)
- **Cloud Firestore** (NoSQL Database)
- **Material 3 UI** (Academic Navy & Modern Slate theme)
- **Provider** (Reactive State Management)
- **Google Fonts** (Inter Typography)
- **Intl** (Date formatting)

---

## How to Run

1. Open terminal in the project directory:
   ```bash
   cd smart_student_assessment
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on Chrome (Web):
   ```bash
   flutter run -d chrome
   ```
   Or on Android:
   ```bash
   flutter run -d android
   ```

---

## Live Firebase Linking (Optional)

```bash
# 1. Install Firebase tools
npm install -g firebase-tools

# 2. Login
firebase login

# 3. Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# 4. Configure within project
flutterfire configure
```
