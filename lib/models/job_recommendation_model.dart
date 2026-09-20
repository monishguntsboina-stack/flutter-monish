class JobRecommendationModel {
  final String id;
  final String title;
  final String category; // e.g. Software, Cloud/DevOps, Data/AI, Core Electronics, Mechanical Design
  final String department;
  final double matchPercentage;
  final String eligibilityStatus; // High Match, Eligible, Upskilling Recommended
  final String salaryRange;
  final double minimumPercentageRequired;
  final List<String> requiredSkills;
  final List<String> topHiringCompanies;
  final String careerOutlook;
  final String preparationAdvice;

  const JobRecommendationModel({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.matchPercentage,
    required this.eligibilityStatus,
    required this.salaryRange,
    required this.minimumPercentageRequired,
    required this.requiredSkills,
    required this.topHiringCompanies,
    required this.careerOutlook,
    required this.preparationAdvice,
  });
}
