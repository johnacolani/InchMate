// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:inch_mate/features/calculator/domain/usecases/calculator_use_case.dart';
import 'package:inch_mate/features/calculator/domain/usecases/format_fraction_use_case.dart';
import 'package:inch_mate/features/calculator/domain/usecases/parse_fraction_use_case.dart';


void main() {
  final calculate = CalculatorUseCase();
  final format = FormatFractionUseCase();

  test('Adding 3/8 + 1/8', () {
    final result = calculate.execute(Fraction(3, 8), Fraction(1, 8), "+");
    expect(format.execute(result), equals("1/2"));
  });
  test('Format negative fraction', () {
    final useCase = FormatFractionUseCase();
    expect(useCase.execute(Fraction(-5, 2)), equals('-2 1/2'));
  });

  // test('Convert negative inches', () {
  //   final useCase = ConvertUnitsUseCase();
  //   expect(useCase.execute(Fraction(-15, 2), false), equals('-7 1/2 in')); // Changed expected value
  // });

  test('Format negative fraction', () {
    final useCase = FormatFractionUseCase();
    expect(useCase.execute(Fraction(-3, 2)), equals('-1 1/2'));
    expect(useCase.execute(Fraction(3, 2)), equals('1 1/2'));
    expect(useCase.execute(Fraction(-5)), equals('-5'));
  });
  test('Parse negative mixed number', () {
    final useCase = ParseFractionUseCase();
    expect(useCase.execute('-2 3/4'), equals(Fraction(-11, 4)));
  });
}