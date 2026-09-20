import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_assessment/core/utils/grade_calculator.dart';

void main() {
  group('GradeCalculator Tests', () {
    test('Calculates percentage correctly', () {
      final pct = GradeCalculator.calculatePercentage(85, 100);
      expect(pct, 85.0);
    });

    test('Calculates grade A+ for >= 90%', () {
      final grade = GradeCalculator.getGrade(95.0);
      expect(grade, 'A+');
    });

    test('Calculates grade F for < 40%', () {
      final grade = GradeCalculator.getGrade(35.0);
      expect(grade, 'F');
    });

    test('Pass/Fail verification', () {
      expect(GradeCalculator.getResult(55.0), 'Pass');
      expect(GradeCalculator.getResult(30.0), 'Fail');
    });
  });
}
