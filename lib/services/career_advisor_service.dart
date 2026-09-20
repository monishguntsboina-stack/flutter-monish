import '../models/job_recommendation_model.dart';
import '../models/marks_model.dart';

class CareerAdvisorService {
  static List<JobRecommendationModel> getRecommendationsForStudent({
    required String department,
    required double averagePercentage,
    List<MarksModel> studentMarks = const [],
  }) {
    final dept = department.toLowerCase();
    final List<JobRecommendationModel> jobs = [];

    // Evaluate subject-specific highlights from marks if available
    double dsaScore = 0;
    double webScore = 0;
    double dbmsScore = 0;
    double networksScore = 0;
    double osScore = 0;

    for (final mark in studentMarks) {
      final sub = mark.subjectName.toLowerCase();
      if (sub.contains('data struct') || sub.contains('algorithm')) dsaScore = mark.percentage;
      if (sub.contains('web') || sub.contains('cloud')) webScore = mark.percentage;
      if (sub.contains('database') || sub.contains('dbms')) dbmsScore = mark.percentage;
      if (sub.contains('network')) networksScore = mark.percentage;
      if (sub.contains('operating') || sub.contains('os')) osScore = mark.percentage;
    }

    if (dept.contains('computer') || dept.contains('information') || dept.contains('cse') || dept.contains('it')) {
      // 1. Software Development Engineer (SDE)
      final sdeScore = dsaScore > 0 ? ((averagePercentage * 0.4) + (dsaScore * 0.6)) : averagePercentage;
      jobs.add(
        JobRecommendationModel(
          id: 'job_sde',
          title: 'Software Development Engineer (SDE-1)',
          category: 'Software Engineering',
          department: 'Computer Science & Engineering',
          matchPercentage: sdeScore.clamp(35.0, 98.0),
          eligibilityStatus: sdeScore >= 80.0
              ? 'High Match (Tier-1 Product Placement)'
              : (sdeScore >= 65.0 ? 'Eligible (Core Tech Role)' : 'Upskilling Recommended'),
          salaryRange: sdeScore >= 80.0 ? '₹10 - ₹22 LPA' : '₹6 - ₹10 LPA',
          minimumPercentageRequired: 70.0,
          requiredSkills: const ['Data Structures & Algorithms', 'Java / C++', 'System Design', 'Git & CI/CD'],
          topHiringCompanies: const ['Google', 'Amazon', 'Microsoft', 'Oracle', 'Cognizant', 'Infosys'],
          careerOutlook: 'Extremely high demand across global tech product and service companies.',
          preparationAdvice: sdeScore >= 80.0
              ? 'Outstanding performance in DSA! Practice LeetCode medium/hard and conduct mock technical interviews.'
              : 'Review Tree and Graph algorithms to push your coding assessment scores above the 80% mark.',
        ),
      );

      // 2. Full Stack Web & Cloud Developer
      final webDevScore = webScore > 0 ? ((averagePercentage * 0.4) + (webScore * 0.6)) : (averagePercentage * 0.95);
      jobs.add(
        JobRecommendationModel(
          id: 'job_web',
          title: 'Full Stack Web & Cloud Engineer',
          category: 'Cloud & Web Technologies',
          department: 'Computer Science / IT',
          matchPercentage: webDevScore.clamp(35.0, 97.0),
          eligibilityStatus: webDevScore >= 75.0 ? 'High Match' : (webDevScore >= 60.0 ? 'Eligible' : 'Needs Practice'),
          salaryRange: webDevScore >= 75.0 ? '₹7 - ₹14 LPA' : '₹4.5 - ₹7 LPA',
          minimumPercentageRequired: 60.0,
          requiredSkills: const ['Flutter / React', 'Node.js / Django', 'REST APIs', 'Cloud (Firebase / AWS)', 'Docker'],
          topHiringCompanies: const ['Accenture', 'Capgemini', 'Zoho', 'Swiggy', 'Wipro', 'TCS Digital'],
          careerOutlook: 'Massive adoption as businesses migrate to modern responsive web and mobile cloud architectures.',
          preparationAdvice: 'Deploy 2 full-stack projects featuring real-time authentication and database integration to GitHub.',
        ),
      );

      // 3. Database Architect / Data Analyst
      final dataScore = dbmsScore > 0 ? ((averagePercentage * 0.4) + (dbmsScore * 0.6)) : (averagePercentage * 0.9);
      jobs.add(
        JobRecommendationModel(
          id: 'job_data',
          title: 'Data Analyst & Database Administrator',
          category: 'Data Engineering',
          department: 'Information Technology / CSE',
          matchPercentage: dataScore.clamp(30.0, 95.0),
          eligibilityStatus: dataScore >= 70.0 ? 'High Match' : 'Eligible',
          salaryRange: dataScore >= 70.0 ? '₹6 - ₹12 LPA' : '₹4 - ₹6.5 LPA',
          minimumPercentageRequired: 60.0,
          requiredSkills: const ['SQL / NoSQL Query Optimization', 'Python / Pandas', 'PowerBI / Tableau', 'Database Normalization'],
          topHiringCompanies: const ['Deloitte', 'EY', 'Fractal Analytics', 'Mu Sigma', 'HCLTech'],
          careerOutlook: 'Data-driven decision making continues to create strong corporate demand across all sectors.',
          preparationAdvice: 'Focus on advanced SQL joins, indexing, execution plans, and ETL pipeline pipelines.',
        ),
      );

      // 4. DevOps & Cloud Security Engineer
      final devopsScore = (networksScore > 0 && osScore > 0)
          ? ((networksScore + osScore) / 2)
          : (averagePercentage * 0.92);
      jobs.add(
        JobRecommendationModel(
          id: 'job_devops',
          title: 'DevOps & Cyber Systems Engineer',
          category: 'Infrastructure & Security',
          department: 'Computer Science & Engineering',
          matchPercentage: devopsScore.clamp(30.0, 94.0),
          eligibilityStatus: devopsScore >= 75.0 ? 'High Match' : 'Eligible',
          salaryRange: devopsScore >= 75.0 ? '₹8 - ₹16 LPA' : '₹5 - ₹8 LPA',
          minimumPercentageRequired: 65.0,
          requiredSkills: const ['Linux Internals', 'TCP/IP & OSI Routing', 'Docker & Kubernetes', 'CI/CD Pipelines', 'AWS / Azure'],
          topHiringCompanies: const ['Cisco', 'Palo Alto Networks', 'Red Hat', 'IBM', 'LTIMindtree'],
          careerOutlook: 'Critical infrastructure role ensuring high application reliability and zero downtime.',
          preparationAdvice: 'Hands-on practice with Linux shell scripting and network socket programming.',
        ),
      );
    } else if (dept.contains('electron') || dept.contains('ece') || dept.contains('communication')) {
      // ECE Jobs
      jobs.add(
        JobRecommendationModel(
          id: 'job_embedded',
          title: 'Embedded Systems & IoT Engineer',
          category: 'Core Hardware & Firmware',
          department: 'Electronics & Communication',
          matchPercentage: (averagePercentage * 0.96).clamp(35.0, 97.0),
          eligibilityStatus: averagePercentage >= 70.0 ? 'High Match' : 'Eligible',
          salaryRange: averagePercentage >= 75.0 ? '₹7 - ₹15 LPA' : '₹4.5 - ₹7.5 LPA',
          minimumPercentageRequired: 65.0,
          requiredSkills: const ['Embedded C / C++', 'Microcontrollers (ARM, ESP32)', 'RTOS', 'UART/SPI/I2C Protocols', 'IoT Gateways'],
          topHiringCompanies: const ['Bosch', 'Qualcomm', 'Texas Instruments', 'Schneider Electric', 'Tata Elxsi'],
          careerOutlook: 'Surging demand driven by smart mobility, electric vehicles, and industrial IoT automation.',
          preparationAdvice: 'Build microcontroller prototypes interfacing with sensors and wireless cloud connectivity.',
        ),
      );

      jobs.add(
        JobRecommendationModel(
          id: 'job_vlsi',
          title: 'VLSI Chip Design & Verification Engineer',
          category: 'Semiconductor Engineering',
          department: 'Electronics & Communication',
          matchPercentage: (averagePercentage * 0.93).clamp(30.0, 96.0),
          eligibilityStatus: averagePercentage >= 75.0 ? 'High Match' : 'Eligible with Specialized Course',
          salaryRange: averagePercentage >= 75.0 ? '₹10 - ₹20 LPA' : '₹6 - ₹9 LPA',
          minimumPercentageRequired: 70.0,
          requiredSkills: const ['Verilog / SystemVerilog', 'Digital Design', 'FPGA Prototyping', 'Static Timing Analysis (STA)', 'CMOS Logic'],
          topHiringCompanies: const ['Intel', 'AMD', 'MediaTek', 'Synopsys', 'Cadence', 'NVIDIA'],
          careerOutlook: 'High-paying core electronics career supporting national and global semiconductor expansions.',
          preparationAdvice: 'Master state machines, timing constraints, and hardware description language simulations.',
        ),
      );

      jobs.add(
        JobRecommendationModel(
          id: 'job_telecom',
          title: '5G / Wireless Network Communications Specialist',
          category: 'Telecommunications',
          department: 'Electronics & Communication',
          matchPercentage: (averagePercentage * 0.9).clamp(30.0, 93.0),
          eligibilityStatus: averagePercentage >= 65.0 ? 'Eligible' : 'Upskilling Required',
          salaryRange: '₹5 - ₹10 LPA',
          minimumPercentageRequired: 60.0,
          requiredSkills: const ['RF Systems', 'OFDM / MIMO Concepts', 'Network Protocols', 'MATLAB Simulation', 'Spectrum Analysis'],
          topHiringCompanies: const ['Ericsson', 'Nokia', 'Jio Platforms', 'Airtel Enterprise', 'Qualcomm'],
          careerOutlook: 'Rapid rollout of 5G cellular infrastructure and satellite connectivity worldwide.',
          preparationAdvice: 'Simulate modulation and wireless propagation models in MATLAB or Python.',
        ),
      );
    } else if (dept.contains('mechan') || dept.contains('me')) {
      // Mechanical Jobs
      jobs.add(
        JobRecommendationModel(
          id: 'job_cad',
          title: 'CAD / CAE Design & Modeling Engineer',
          category: 'Mechanical Design',
          department: 'Mechanical Engineering',
          matchPercentage: (averagePercentage * 0.95).clamp(35.0, 96.0),
          eligibilityStatus: averagePercentage >= 70.0 ? 'High Match' : 'Eligible',
          salaryRange: averagePercentage >= 70.0 ? '₹5.5 - ₹10 LPA' : '₹4 - ₹6 LPA',
          minimumPercentageRequired: 60.0,
          requiredSkills: const ['SolidWorks / CATIA', 'Finite Element Analysis (FEA)', 'GD&T Standards', 'Ansys Simulation', 'Additive Manufacturing'],
          topHiringCompanies: const ['Tata Motors', 'Mahindra', 'Larsen & Toubro', 'Cummins', 'Thermax', 'Hero MotoCorp'],
          careerOutlook: 'Foundational engineering career essential for automotive, aerospace, and renewable power equipment.',
          preparationAdvice: 'Earn professional CAD certifications and assemble a portfolio of 3D mechanical assemblies.',
        ),
      );

      jobs.add(
        JobRecommendationModel(
          id: 'job_robotics',
          title: 'Robotics & Industrial Automation Specialist',
          category: 'Mechatronics & Automation',
          department: 'Mechanical Engineering',
          matchPercentage: (averagePercentage * 0.92).clamp(30.0, 95.0),
          eligibilityStatus: averagePercentage >= 72.0 ? 'High Match' : 'Eligible',
          salaryRange: '₹6 - ₹12 LPA',
          minimumPercentageRequired: 65.0,
          requiredSkills: const ['PLC Programming', 'SCADA', 'Industrial Robotics', 'Pneumatics & Hydraulics', 'Kinematics'],
          topHiringCompanies: const ['ABB', 'Fanuc', 'Siemens', 'Honeywell', 'KUKA Robotics'],
          careerOutlook: 'Accelerated growth with Industry 4.0 automated manufacturing plants.',
          preparationAdvice: 'Work with programmable logic controllers and automated actuator integration projects.',
        ),
      );
    } else {
      // General Engineering / Multi-disciplinary Jobs
      jobs.add(
        JobRecommendationModel(
          id: 'job_gen_analyst',
          title: 'Associate Technical Consultant',
          category: 'Technology Consulting',
          department: department,
          matchPercentage: (averagePercentage * 0.92).clamp(40.0, 95.0),
          eligibilityStatus: averagePercentage >= 60.0 ? 'Eligible' : 'Needs Higher Percentage',
          salaryRange: '₹4.5 - ₹8 LPA',
          minimumPercentageRequired: 60.0,
          requiredSkills: const ['Analytical Problem Solving', 'Python / SQL', 'Presentation Skills', 'Agile Methodologies'],
          topHiringCompanies: const ['Deloitte', 'Accenture', 'TCS', 'Infosys', 'Capgemini'],
          careerOutlook: 'Consistent multi-disciplinary hiring for graduate campus recruits.',
          preparationAdvice: 'Practice quantitative aptitude, logical reasoning, and communication case studies.',
        ),
      );

      jobs.add(
        JobRecommendationModel(
          id: 'job_gen_qa',
          title: 'Quality Assurance & Test Automation Associate',
          category: 'Quality Assurance',
          department: department,
          matchPercentage: (averagePercentage * 0.88).clamp(35.0, 92.0),
          eligibilityStatus: averagePercentage >= 55.0 ? 'Eligible' : 'Needs Remedial Support',
          salaryRange: '₹3.6 - ₹6 LPA',
          minimumPercentageRequired: 55.0,
          requiredSkills: const ['Manual Testing', 'Selenium / Postman', 'Defect Tracking (Jira)', 'Test Case Documentation'],
          topHiringCompanies: const ['Wipro', 'Tech Mahindra', 'HCLTech', 'Cognizant'],
          careerOutlook: 'Steady entry-level pathway into the software lifecycle.',
          preparationAdvice: 'Learn API testing with Postman and basic automated testing with Selenium.',
        ),
      );
    }

    // Sort by match percentage descending
    jobs.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return jobs;
  }
}
