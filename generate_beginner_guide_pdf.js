const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');

const OUTPUT_PATH = 'C:\\Users\\IND\\Desktop\\PSCMR_Smart_Assessment_Beginner_Code_Guide.pdf';
const LOGO_PATH = path.join(__dirname, 'assets', 'images', 'college_logo.png');

console.log('Generating PSCMR Smart Assessment Beginner Code Guide PDF...');

const doc = new PDFDocument({
  size: 'A4',
  margins: { top: 50, bottom: 60, left: 50, right: 50 },
  bufferPages: true,
  autoFirstPage: true
});

const writeStream = fs.createWriteStream(OUTPUT_PATH);
doc.pipe(writeStream);

// Color Palette
const PRIMARY = '#1E3A8A';       // Navy
const PRIMARY_LIGHT = '#3B82F6'; // Blue
const SECONDARY = '#059669';     // Emerald
const DARK_BG = '#0F172A';       // Slate 900
const TEXT_DARK = '#1E293B';     // Slate 800
const TEXT_MUTED = '#64748B';    // Slate 500
const BORDER_COLOR = '#CBD5E1';  // Slate 300
const LIGHT_BG = '#F8FAFC';      // Slate 50
const ACCENT_ORANGE = '#D97706';

function checkPageSpace(doc, neededHeight) {
  if (doc.y + neededHeight > doc.page.height - 70) {
    doc.addPage();
  }
}

function drawHeader(title) {
  doc.rect(50, 40, doc.page.width - 100, 3).fill(PRIMARY);
  doc.fontSize(8).fillColor(TEXT_MUTED).text(title, 50, 28, { align: 'right' });
  doc.y = 55;
}

function addTitleH1(title) {
  checkPageSpace(doc, 60);
  doc.moveDown(0.8);
  const startY = doc.y;
  doc.roundedRect(50, startY, doc.page.width - 100, 28, 4).fill(PRIMARY);
  doc.fillColor('#FFFFFF').fontSize(12).font('Helvetica-Bold').text(title, 60, startY + 8);
  doc.y = startY + 36;
  doc.moveDown(0.3);
}

function addSectionH2(title) {
  checkPageSpace(doc, 45);
  doc.moveDown(0.6);
  doc.fillColor(PRIMARY).fontSize(11).font('Helvetica-Bold').text(title);
  const lineY = doc.y + 2;
  doc.moveTo(50, lineY).lineTo(doc.page.width - 50, lineY).strokeColor(BORDER_COLOR).lineWidth(0.8).stroke();
  doc.y = lineY + 6;
}

function addSubSectionH3(title) {
  checkPageSpace(doc, 30);
  doc.moveDown(0.4);
  doc.fillColor(SECONDARY).fontSize(10).font('Helvetica-Bold').text(title);
  doc.moveDown(0.2);
}

function addParagraph(text) {
  checkPageSpace(doc, 25);
  doc.fillColor(TEXT_DARK).fontSize(9).font('Helvetica').lineGap(2.5).text(text, {
    align: 'justify'
  });
  doc.moveDown(0.3);
}

function addBullet(bulletText, boldPrefix = '') {
  checkPageSpace(doc, 20);
  doc.fontSize(9).lineGap(2);
  const indent = 65;
  doc.fillColor(PRIMARY_LIGHT).text('• ', 55, doc.y, { continued: false });
  doc.y -= 11;
  if (boldPrefix) {
    doc.font('Helvetica-Bold').fillColor(TEXT_DARK).text(boldPrefix + ' ', indent, doc.y, { continued: true });
    doc.font('Helvetica').fillColor(TEXT_DARK).text(bulletText);
  } else {
    doc.font('Helvetica').fillColor(TEXT_DARK).text(bulletText, indent);
  }
  doc.moveDown(0.2);
}

function addCalloutBox(title, message, isTip = false) {
  checkPageSpace(doc, 65);
  doc.moveDown(0.4);
  const boxY = doc.y;
  const boxWidth = doc.page.width - 100;
  const boxBg = isTip ? '#ECFDF5' : '#EFF6FF';
  const boxBorder = isTip ? '#10B981' : '#3B82F6';
  
  doc.roundedRect(50, boxY, boxWidth, 48, 4).fill(boxBg);
  doc.roundedRect(50, boxY, 4, 48, 2).fill(boxBorder);
  
  doc.fillColor(boxBorder).fontSize(9.5).font('Helvetica-Bold').text((isTip ? '✓ ' : 'ℹ ') + title, 62, boxY + 8);
  doc.fillColor(TEXT_DARK).fontSize(8.5).font('Helvetica').text(message, 62, boxY + 22, { width: boxWidth - 24 });
  
  doc.y = boxY + 56;
}

function addCodeBlock(codeText, title = '') {
  const lines = codeText.split('\n');
  const blockHeight = lines.length * 11 + (title ? 28 : 18);
  checkPageSpace(doc, Math.min(blockHeight, 220));

  doc.moveDown(0.3);
  const startY = doc.y;
  const boxWidth = doc.page.width - 100;

  doc.roundedRect(50, startY, boxWidth, blockHeight, 4).fill(DARK_BG);

  let currentY = startY + 8;
  if (title) {
    doc.fillColor('#94A3B8').fontSize(8).font('Helvetica-Bold').text('// ' + title, 60, currentY);
    currentY += 14;
    doc.moveTo(50, currentY - 4).lineTo(50 + boxWidth, currentY - 4).strokeColor('#334155').lineWidth(0.5).stroke();
  }

  doc.font('Courier').fontSize(7.8).lineGap(1.2);
  for (const line of lines) {
    if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
      doc.fillColor('#64748B').text(line, 60, currentY);
    } else if (line.includes('function ') || line.includes('const ') || line.includes('let ') || line.includes('var ') || line.includes('return ') || line.includes('class ')) {
      doc.fillColor('#A78BFA').text(line, 60, currentY);
    } else if (line.includes('if ') || line.includes('else ') || line.includes('Math.') || line.includes('localStorage.')) {
      doc.fillColor('#F43F5E').text(line, 60, currentY);
    } else {
      doc.fillColor('#E2E8F0').text(line, 60, currentY);
    }
    currentY += 11;
  }

  doc.y = startY + blockHeight + 8;
}

function addTable(headers, rows, colWidths) {
  const startX = 50;
  const totalWidth = colWidths.reduce((a, b) => a + b, 0);

  const rowHeights = rows.map(row => {
    let maxH = 20;
    row.forEach((cell, i) => {
      doc.fontSize(8).font('Helvetica');
      const textH = doc.heightOfString(cell, { width: colWidths[i] - 12 }) + 10;
      if (textH > maxH) maxH = textH;
    });
    return maxH;
  });

  const totalTableHeight = 22 + rowHeights.reduce((a, b) => a + b, 0);
  checkPageSpace(doc, Math.min(totalTableHeight, 160));
  doc.moveDown(0.4);

  let startY = doc.y;

  doc.rect(startX, startY, totalWidth, 22).fill(PRIMARY);
  let curX = startX;
  headers.forEach((h, i) => {
    doc.fillColor('#FFFFFF').fontSize(8.5).font('Helvetica-Bold').text(h, curX + 6, startY + 6, { width: colWidths[i] - 12 });
    curX += colWidths[i];
  });
  startY += 22;

  rows.forEach((row, rIdx) => {
    const rHeight = rowHeights[rIdx];
    if (startY + rHeight > doc.page.height - 65) {
      doc.addPage();
      startY = 55;
    }
    const isAlt = rIdx % 2 === 1;
    doc.rect(startX, startY, totalWidth, rHeight).fill(isAlt ? LIGHT_BG : '#FFFFFF');
    doc.rect(startX, startY, totalWidth, rHeight).strokeColor(BORDER_COLOR).lineWidth(0.5).stroke();

    let cellX = startX;
    row.forEach((cell, cIdx) => {
      doc.fillColor(TEXT_DARK).fontSize(8).font('Helvetica').text(cell, cellX + 6, startY + 5, { width: colWidths[cIdx] - 12 });
      cellX += colWidths[cIdx];
    });
    startY += rHeight;
  });

  doc.y = startY + 10;
}

// ==========================================
// 1. COVER PAGE
// ==========================================
doc.rect(0, 0, doc.page.width, doc.page.height).fill('#F8FAFC');

// Banner
doc.rect(0, 0, doc.page.width, 135).fill(PRIMARY);
doc.rect(0, 131, doc.page.width, 6).fill(SECONDARY);

doc.fillColor('#FFFFFF').fontSize(17).font('Helvetica-Bold').text('PSCMR COLLEGE OF ENGINEERING & TECHNOLOGY', 50, 38, { align: 'center' });
doc.fontSize(9.5).font('Helvetica').text('Department of Computer Science & Engineering | FSD Academic Project', 50, 62, { align: 'center' });
doc.fontSize(9.5).font('Helvetica-Oblique').text('Kothapeta, Vijayawada - 520001, Andhra Pradesh', 50, 76, { align: 'center' });

if (fs.existsSync(LOGO_PATH)) {
  doc.image(LOGO_PATH, (doc.page.width - 95) / 2, 160, { width: 95 });
}

// Title Card
doc.rect(50, 285, doc.page.width - 100, 175).fill('#FFFFFF');
doc.rect(50, 285, doc.page.width - 100, 175).strokeColor(BORDER_COLOR).lineWidth(1).stroke();
doc.rect(50, 285, doc.page.width - 100, 6).fill(PRIMARY_LIGHT);

doc.fillColor(PRIMARY).fontSize(20).font('Helvetica-Bold').text('PSCMR SMART ASSESSMENT\nBEGINNER PROJECT CODE GUIDE', 65, 305, { align: 'center', lineGap: 4 });
doc.fillColor(TEXT_MUTED).fontSize(10.5).font('Helvetica').text('Complete Line-by-Line Code, File Architecture & Calculation Formula Handbook', 65, 360, { align: 'center' });

// Badges
doc.roundedRect(90, 395, 180, 24, 12).fill('#EFF6FF');
doc.fillColor(PRIMARY).fontSize(8.5).font('Helvetica-Bold').text('Target: Web & JNTUK Standard', 90, 402, { align: 'center', width: 180 });

doc.roundedRect(300, 395, 200, 24, 12).fill('#ECFDF5');
doc.fillColor(SECONDARY).fontSize(8.5).font('Helvetica-Bold').text('G. Monish (24KT1A4715) & Team', 300, 402, { align: 'center', width: 200 });

// Metadata Card
const metaY = 485;
doc.rect(50, metaY, doc.page.width - 100, 195).fill('#FFFFFF');
doc.rect(50, metaY, doc.page.width - 100, 195).strokeColor(BORDER_COLOR).lineWidth(0.8).stroke();

doc.fillColor(PRIMARY).fontSize(11).font('Helvetica-Bold').text('Project Architecture & Source Reference Details', 70, metaY + 14);
doc.moveTo(70, metaY + 30).lineTo(doc.page.width - 70, metaY + 30).strokeColor(BORDER_COLOR).lineWidth(0.5).stroke();

const metaDetails = [
  ['Project Name:', 'PSCMR_Smart_Assessment_Beginner (HTML5 / Bootstrap 5 / Vanilla JS)'],
  ['Core Modules:', 'Single Login Portal, Admin Hub, Faculty Workspace, Student Transcript'],
  ['Examination Standard:', 'JNTUK Autonomous Regulations (Mid-1 + Mid-2 + 80:20 Rule + Lab Evaluator)'],
  ['Student Context:', 'G. Monish (24KT1A4715), S. Yathendranadh (24KT1A4751) - CSE 3rd Year'],
  ['Data Architecture:', 'Local Storage Handler with Seed Data Sync (SEED_STUDENTS & SEED_FACULTY)'],
  ['Career Engine:', 'Department Cutoff Matching (CSE, IT, ECE, ME, AI&DS) + CTC Estimation'],
  ['Launch Command:', 'open_project.bat (Launches project in any web browser without server)']
];

let curMetaY = metaY + 40;
metaDetails.forEach(([lbl, val]) => {
  doc.fillColor(TEXT_DARK).fontSize(8).font('Helvetica-Bold').text(lbl, 70, curMetaY, { width: 140 });
  doc.font('Helvetica').fillColor(TEXT_MUTED).text(val, 215, curMetaY, { width: doc.page.width - 285 });
  curMetaY += 20;
});

doc.fillColor(TEXT_MUTED).fontSize(8).font('Helvetica').text('PSCMR College of Engineering & Technology — Student Learning Manual', 50, doc.page.height - 35, { align: 'center' });

// ==========================================
// 2. FILE TREE & ARCHITECTURE OVERVIEW
// ==========================================
doc.addPage();
drawHeader('Section 1 — Explorer File Tree & Project Structure');
addTitleH1('1. EXPLORER FILE TREE & ARCHITECTURE OVERVIEW');

addParagraph('This section breaks down the exact folder and file structure shown in your VS Code Explorer sidebar for the "PSCMR_Smart_Assessment_Beginner" workspace.');

addTable(
  ['File / Folder Name', 'Technology', 'Primary Purpose in System'],
  [
    ['css/style.css', 'CSS3 & Bootstrap 5', 'Contains global styling, color tokens (#1E3A8A Navy, #059669 Emerald), cards, tables, and responsiveness'],
    ['js/app.js', 'Vanilla JavaScript', 'Global application controller: manages user session, login state, role redirection, and toast notifications'],
    ['js/calculator.js', 'Vanilla JavaScript', 'Mathematical engine: JNTUK internal evaluation, Unit scaling (/30 to /15), 80:20 rule, and letter grading'],
    ['js/data.js', 'Vanilla JavaScript', 'Data storage manager: pre-seeded student/faculty arrays, LocalStorage reading, writing, and auto-sync'],
    ['index.html', 'HTML5', 'Project landing and gateway page with direct links to Admin, Faculty, and Student portals'],
    ['login.html', 'HTML5', 'Unified single login portal where entering email/password routes to Admin or Faculty automatically'],
    ['admin-dashboard.html', 'HTML5', 'College Administrator Hub: department filters (CSE, IT, ECE, ME, AI&DS), college statistics, and faculty oversight'],
    ['teacher-dashboard.html', 'HTML5', 'Faculty Workspace: assigned courses, quick marks entry button, and student performance insights'],
    ['student-dashboard.html', 'HTML5', 'Student View: personal scorecard, semester transcript, marks breakdown, and job recommendations'],
    ['students.html', 'HTML5', 'Student Directory: searchable table of all enrolled students with department dropdown filter'],
    ['add-student.html', 'HTML5', 'Student Enrollment Form: validates and adds new student records into LocalStorage'],
    ['faculty.html', 'HTML5', 'Faculty Directory: list of professors, designations (HOD, Assoc Prof), employee IDs, and department tags'],
    ['marks-entry.html', 'HTML5', 'Faculty Marks Form: dynamic mid examination calculator with live preview of scaled marks'],
    ['academic-records.html', 'HTML5', 'Academic Transcript Archive: detailed subject-wise marks table with GPA and pass status'],
    ['results.html', 'HTML5', 'Analytics & Reports: pass percentage breakdown, high-performing students, and career matching radar'],
    ['open_project.bat', 'Windows Batch Script', '1-Click launcher script to immediately open the system in Google Chrome or Microsoft Edge']
  ],
  [120, 110, 265]
);

addCalloutBox('Client-Side Architecture', 'The project is built purely using HTML5, Bootstrap 5, and Vanilla JavaScript. It requires zero database servers or backend installations to run. All data is saved persistently in the browser\'s LocalStorage.', true);

// ==========================================
// 3. CODE WALKTHROUGH: JS/CALCULATOR.JS
// ==========================================
doc.addPage();
drawHeader('Section 2 — Examination Calculation Engine (js/calculator.js)');
addTitleH1('2. THE MATHEMATICAL CORE: JS/CALCULATOR.JS');

addParagraph('The file "js/calculator.js" is the most important calculation script in the project. It implements the official JNTUK / Autonomous College Examination Standards.');

addSubSectionH3('2.1 How Mid Examinations are Evaluated (The 30-Mark Scale)');
addParagraph('In each semester, students write two Mid-Term Examinations (Mid-1 and Mid-2). Each Mid examination consists of 3 components:');
addBullet('Subjective Units Test: Max 30 marks (Questions from Units 1, 2, 3 for Mid-1; Units 3, 4, 5 for Mid-2). This is scaled down to /15.', '1. Unit Test (/15):');
addBullet('Objective Assessment: Max 10 marks testing multiple choice and conceptual questions.', '2. Objective Test (/10):');
addBullet('Continuous Assignment: Max 5 marks for classroom assignment submissions.', '3. Assignment (/5):');

addCodeBlock(
`// Formula: Converting 30 Unit Marks to 15 Scale
convertUnitsTo15(total30) {
  const val = parseFloat(total30) || 0;
  return +((val / 30) * 15).toFixed(2);
},

// Formula: Total Mid Internal Marks (Max 30)
calcMidInternal(converted15, obj10, assignment5) {
  const c = Math.min(15, parseFloat(converted15) || 0);
  const o = Math.min(10, parseFloat(obj10) || 0);
  const a = Math.min(5, parseFloat(assignment5) || 0);
  return +(Math.min(30, c + o + a)).toFixed(2);
}`,
'js/calculator.js — Mid Scaling Functions'
);

addSubSectionH3('2.2 The JNTUK 80:20 Weighted Mid Rule');
addParagraph('Instead of simply averaging Mid-1 and Mid-2, the academic regulation applies the 80:20 Rule: 80% weightage is given to the higher score and 20% weightage to the lower score:');

addCodeBlock(
`// The JNTUK 80:20 Rule Formula:
// Final Mid = (Higher Mid * 0.8) + (Lower Mid * 0.2)
calcWeightedMid(mid1Internal, mid2Internal) {
  const m1 = parseFloat(mid1Internal) || 0;
  const m2 = parseFloat(mid2Internal) || 0;
  const higher = Math.max(m1, m2);
  const lower = Math.min(m1, m2);
  const weighted = (higher * 0.8) + (lower * 0.2);
  return {
    higherMid: +higher.toFixed(2),
    lowerMid: +lower.toFixed(2),
    finalInternal: +weighted.toFixed(2)
  };
}`,
'js/calculator.js — 80:20 Weighted Calculation'
);

addSubSectionH3('2.3 Step-by-Step Numerical Example (For Demonstration)');
addParagraph('Suppose student G. Monish (24KT1A4715) scores:');
addBullet('Mid-1 Internal: 27 / 30 marks', 'Mid-1 Score:');
addBullet('Mid-2 Internal: 21 / 30 marks', 'Mid-2 Score:');
addBullet('Higher Mid = 27 (Weight 80%) -> 27 * 0.8 = 21.6', 'Step 1:');
addBullet('Lower Mid = 21 (Weight 20%) -> 21 * 0.2 = 4.2', 'Step 2:');
addBullet('Final Weighted Internal = 21.6 + 4.2 = 25.8 / 30 marks', 'Result:');

// ==========================================
// 4. CODE WALKTHROUGH: JS/DATA.JS
// ==========================================
doc.addPage();
drawHeader('Section 3 — Data Management & LocalStorage (js/data.js)');
addTitleH1('3. DATA MANAGEMENT & LOCALSTORAGE: JS/DATA.JS');

addParagraph('The file "js/data.js" acts as the client-side database. It initializes default college seed data and provides utility functions to save, update, and fetch records from browser LocalStorage.');

addSubSectionH3('3.1 Pre-seeded Student Records (SEED_STUDENTS)');
addParagraph('Contains real PSCMR College students with registration numbers, names, branches, and sections:');
addCodeBlock(
`const SEED_STUDENTS = [
  {
    registerNo: "24KT1A4715",
    rollNo: "24KT1A4715",
    studentName: "G. Monish",
    department: "CSE",
    year: "3rd Year",
    section: "A",
    email: "g.monish@pscmr.ac.in"
  },
  {
    registerNo: "24KT1A4751",
    rollNo: "24KT1A4751",
    studentName: "S. Yathendranadh",
    department: "CSE",
    year: "3rd Year",
    section: "A",
    email: "s.yathendranadh@pscmr.ac.in"
  },
  {
    registerNo: "24KT1A4722",
    rollNo: "24KT1A4722",
    studentName: "K. Bhavana",
    department: "ECE",
    year: "3rd Year",
    section: "B",
    email: "k.bhavana@pscmr.ac.in"
  }
];`,
'js/data.js — Seed Students Array'
);

addSubSectionH3('3.2 LocalStorage Read/Write Engine');
addParagraph('Ensures that when you add a new student or enter exam marks, the changes persist even when you refresh or close the browser:');
addCodeBlock(
`const DataStore = {
  // Get all students (fallback to seed data if empty)
  getStudents() {
    const data = localStorage.getItem("pscmr_students");
    if (!data) {
      localStorage.setItem("pscmr_students", JSON.stringify(SEED_STUDENTS));
      return SEED_STUDENTS;
    }
    return JSON.parse(data);
  },

  // Save new student to LocalStorage
  saveStudent(studentObj) {
    const students = this.getStudents();
    students.push(studentObj);
    localStorage.setItem("pscmr_students", JSON.stringify(students));
  },

  // Filter students by department (for strict isolation)
  getStudentsByDept(deptName) {
    return this.getStudents().filter(s => s.department === deptName);
  }
};`,
'js/data.js — LocalStorage CRUD Controller'
);

// ==========================================
// 5. CODE WALKTHROUGH: JS/APP.JS
// ==========================================
doc.addPage();
drawHeader('Section 4 — Application Controller & Session Guard (js/app.js)');
addTitleH1('4. APPLICATION CONTROLLER & SESSION: JS/APP.JS');

addParagraph('"js/app.js" governs page initialization, user session checking, logout handling, and custom alert toast notifications.');

addSubSectionH3('4.1 Session & Role Verification');
addParagraph('When any page loads, "app.js" checks who is logged in to grant or restrict access:');
addCodeBlock(
`function getCurrentUser() {
  return {
    username: localStorage.getItem("loggedInUser") || "Guest",
    role: localStorage.getItem("userRole") || "Student",
    facultyId: localStorage.getItem("facultyId") || null,
    department: localStorage.getItem("userDept") || "CSE"
  };
}

function logout() {
  localStorage.removeItem("loggedInUser");
  localStorage.removeItem("userRole");
  localStorage.removeItem("userDept");
  window.location.href = "login.html";
}`,
'js/app.js — Session Helpers'
);

addSubSectionH3('4.2 Toast Notification System');
addParagraph('Instead of using ugly browser alert() popups, "app.js" injects styled Bootstrap toasts into the DOM for positive user feedback:');
addCodeBlock(
`function showToast(message, type = 'info', duration = 3500) {
  let container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.className = 'custom-toast toast-' + type;
  toast.innerHTML = '<span>' + message + '</span>';
  container.appendChild(toast);
  setTimeout(() => toast.remove(), duration);
}`,
'js/app.js — Toast Utility'
);

// ==========================================
// 6. CODE WALKTHROUGH: CORE HTML PAGES
// ==========================================
doc.addPage();
drawHeader('Section 5 — User Interface Breakdown: Core HTML Pages');
addTitleH1('5. USER INTERFACE BREAKDOWN: CORE HTML PAGES');

addSubSectionH3('5.1 login.html (Unified Authentication Portal)');
addBullet('Form Structure: Contains a single clean card with email and password inputs.', 'UI Design:');
addBullet('Auto-Routing Logic: Checks the submitted email. If email includes "admin" -> redirects to admin-dashboard.html. If email includes "faculty" -> redirects to teacher-dashboard.html. If student roll number -> redirects to student-dashboard.html.', 'Role Routing:');
addBullet('Quick-Fill Buttons: 1-click test buttons to test Admin, Faculty, or Student logins without typing.', 'Demo Convenience:');

addSubSectionH3('5.2 admin-dashboard.html (Department Isolation & Oversight)');
addBullet('Top KPI Cards: Enrolled Students, Total Faculty, Active Courses, Pass Percentage.', 'Dashboard KPIs:');
addBullet('Department Hub Buttons: Buttons for CSE, IT, ECE, ME, AI&DS. When Admin clicks "CSE", a JavaScript filter activates that hides all other branches and shows ONLY CSE students and CSE faculty.', 'Department Filter:');
addBullet('Faculty Directory Table: Lists professors with designation badges and qualifications.', 'Faculty Directory:');

addSubSectionH3('5.3 marks-entry.html (Interactive Evaluation Form)');
addBullet('Student Selector: Dropdown populated dynamically from DataStore.getStudents().', 'Dynamic Select:');
addBullet('Live Score Calculation: Entering Unit-1, Unit-2, Unit-3 marks automatically triggers "oninput" events calling PSCMR_Calculator.calcMid1UnitTotal().', 'Realtime Math:');
addBullet('Instant Grade Preview: Displays whether the student has passed or failed before clicking Save.', 'Feedback:');

addSubSectionH3('5.4 student-dashboard.html & academic-records.html');
addBullet('Displays student transcript table with subject codes (e.g. CS501), internal marks (/30), semester marks (/70), total (/100), and final letter grade.', 'Transcript View:');
addBullet('Features the "Career Recommendations" button that analyzes student performance.', 'Career Trigger:');

// ==========================================
// 7. CAREER RECOMMENDATION ENGINE
// ==========================================
doc.addPage();
drawHeader('Section 6 — Marks-Based Career Recommendation Engine');
addTitleH1('6. MARKS-BASED CAREER RECOMMENDATION ENGINE');

addParagraph('The system bridges academic grades with industry employment by calculating which jobs a student qualifies for based on their department, overall percentage, and subject mastery.');

addTable(
  ['Department', 'Career Paths', 'Academic Cutoff', 'CTC Package', 'Top Recruiters'],
  [
    ['CSE', 'Full-Stack SDE, Cloud Architect, AI Developer', '70% - 75%', '₹6.5 - 28.0 LPA', 'Google, Microsoft, Amazon, TCS Digital'],
    ['IT', 'Software Engineer, DevOps Engineer, Cybersecurity', '68% - 72%', '₹6.0 - 22.0 LPA', 'Cisco, Cognizant, Wipro, Capgemini'],
    ['ECE', 'Embedded Systems Engg, VLSI Design, IoT Engineer', '65% - 70%', '₹5.5 - 18.0 LPA', 'Qualcomm, Intel, Texas Instruments, Bosch'],
    ['ME', 'CAD/CAM Engineer, Robotics, Automation Engg', '60% - 68%', '₹4.8 - 14.0 LPA', 'Tata Motors, L&T, Mahindra, Ashok Leyland'],
    ['AI & DS', 'Machine Learning Engineer, Data Scientist, BI Analyst', '72% - 78%', '₹7.5 - 30.0 LPA', 'NVIDIA, IBM Research, Adobe, Mu Sigma']
  ],
  [65, 145, 60, 95, 130]
);

addSectionH2('6.1 How the Match Score is Calculated');
addParagraph('The JavaScript matching function uses the student\'s cumulative score and subject scores:');
addCodeBlock(
`function getJobMatchScore(studentAvg, cutoff, dsaScore) {
  let score = 70.0;
  // Percentage bonus or penalty
  if (studentAvg >= cutoff) {
    score += (studentAvg - cutoff) * 1.2;
  } else {
    score -= (cutoff - studentAvg) * 1.8;
  }
  // Technical mastery bonus
  if (dsaScore >= 80) score += 8.0;
  return Math.min(98, Math.max(45, Math.round(score)));
}`,
'Career Matching Formula in JavaScript'
);

// ==========================================
// 8. HOW TO RUN & DEMONSTRATE
// ==========================================
doc.addPage();
drawHeader('Section 7 — How to Run & Demonstrate to Madam');
addTitleH1('7. HOW TO RUN & DEMONSTRATE TO MADAM');

addParagraph('Here is how to run and demonstrate the project with maximum confidence:');

addSubSectionH3('Step 1: Launch the Application');
addParagraph('Navigate to the project folder "PSCMR_Smart_Assessment_Beginner" on your Desktop and double-click "open_project.bat" (or right-click "index.html" and choose Open with Google Chrome).');

addSubSectionH3('Step 2: Demonstration Workflow for Madam');
addBullet('Show the single login form. Explain: "Madam, there is only one portal. The system automatically detects whether we are an Admin or Faculty based on our email."', '1. Single Login:');
addBullet('Click "Instant Admin" (or enter admin@pscmr.ac.in). Point out the Deep Indigo theme and the Department Hub.', '2. Admin Portal:');
addBullet('Click on the "CSE" department card. Show that the student table immediately filters to show ONLY CSE students (G. Monish, S. Yathendranadh) and ONLY CSE faculty.', '3. Dept Isolation:');
addBullet('Log out and click "Instant Faculty". Point out the Emerald Green theme and the direct "Marks Entry" workspace.', '4. Faculty Portal:');
addBullet('Show the Mid-1, Mid-2 live scaling and the JNTUK 80:20 weighted rule.', '5. Marks & 80:20 Rule:');
addBullet('Open a student\'s transcript and click "Job Recommendations". Show the predicted jobs, match %, and CTC packages.', '6. Career Engine:');

addCalloutBox('Release APK for Mobile', 'You also have the compiled Android mobile app ready on your Desktop: C:\\Users\\IND\\Desktop\\PSCMR_Smart_Student_Assessment.apk (57.8 MB). You can show both the Web version and Mobile version!', true);

// Finalize Document & Add Page Numbers
const range = doc.bufferedPageRange();
for (let i = 0; i < range.count; i++) {
  doc.switchToPage(i);
  if (i > 0) {
    doc.fillColor(TEXT_MUTED).fontSize(8).font('Helvetica').text(
      'PSCMR Smart Assessment Beginner Code Guide — Page ' + (i + 1) + ' of ' + range.count,
      50,
      doc.page.height - 35,
      { align: 'center' }
    );
  }
}

doc.end();

writeStream.on('finish', () => {
  console.log('Beginner Code Guide PDF generation complete! Saved to: ' + OUTPUT_PATH);
});
