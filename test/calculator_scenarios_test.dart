// Comprehensive scenario tests covering every way a user can interact with the
// InchMate calculator: whole-number math, fraction math, mixed-number
// measurements, order of operations, parentheses, percent, negate, editing
// (backspace/clear), linear-foot / square-foot conversion, and error/stability
// edge cases.
//
// The bloc tests drive the SAME events the on-screen buttons dispatch (see
// calculator_button.dart), so a passing test means the real button flow works.

import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:inch_mate/features/calculator/domain/usecases/calculator_use_case.dart';
import 'package:inch_mate/features/calculator/domain/usecases/convert_units_use_case.dart';
import 'package:inch_mate/features/calculator/domain/usecases/format_fraction_use_case.dart';
import 'package:inch_mate/features/calculator/domain/usecases/parse_fraction_use_case.dart';
import 'package:inch_mate/features/calculator/presentation/blocs/calculator_bloc.dart';
import 'package:inch_mate/features/calculator/presentation/blocs/calculator_event.dart';

CalculatorBloc _newBloc() => CalculatorBloc(
      calculate: CalculatorUseCase(),
      convertUnits: ConvertUnitsUseCase(),
      formatFraction: FormatFractionUseCase(),
      parseFraction: ParseFractionUseCase(),
    );

/// Presses a single calculator button by its label, dispatching exactly the
/// event that CalculatorButton._handlePress would.
void _press(CalculatorBloc bloc, String label) {
  if (label == 'C') {
    bloc.add(ClearEvent());
  } else if (label == '±') {
    bloc.add(NegateEvent());
  } else if (label == '%') {
    bloc.add(PercentEvent());
  } else if (['÷', '×', '-', '+'].contains(label)) {
    bloc.add(OperatorEvent(label));
  } else if (label == '⌫') {
    bloc.add(BackspaceEvent());
  } else if (label == '=') {
    bloc.add(EqualsEvent());
  } else if (label == '(') {
    bloc.add(ParenthesisEvent(true));
  } else if (label == ')') {
    bloc.add(ParenthesisEvent(false));
  } else if (label.contains('/')) {
    bloc.add(FractionEvent('"$label"'));
  } else {
    bloc.add(DigitEvent(label));
  }
}

/// Presses a sequence of buttons and waits for the bloc to process them.
Future<void> _type(CalculatorBloc bloc, List<String> labels) async {
  for (final l in labels) {
    _press(bloc, l);
  }
  await pumpEventQueue();
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  group('Whole-number arithmetic', () {
    test('7 + 8 = 15', () async {
      final bloc = _newBloc();
      await _type(bloc, ['7', '+', '8', '=']);
      expect(bloc.state.displayText, '15');
    });

    test('9 - 4 = 5', () async {
      final bloc = _newBloc();
      await _type(bloc, ['9', '-', '4', '=']);
      expect(bloc.state.displayText, '5');
    });

    test('6 × 5 = 30', () async {
      final bloc = _newBloc();
      await _type(bloc, ['6', '×', '5', '=']);
      expect(bloc.state.displayText, '30');
    });

    test('100 ÷ 4 = 25', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '0', '0', '÷', '4', '=']);
      expect(bloc.state.displayText, '25');
    });

    test('multi-digit 12 + 34 = 46', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '2', '+', '3', '4', '=']);
      expect(bloc.state.displayText, '46');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Fraction arithmetic (core purpose)', () {
    test('1/2 + 1/2 = 1', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1/2', '+', '1/2', '=']);
      expect(bloc.state.displayText, '1');
    });

    test('3/8 + 1/8 = 1/2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['3/8', '+', '1/8', '=']);
      expect(bloc.state.displayText, '1/2');
    });

    test('3/4 - 1/4 = 1/2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['3/4', '-', '1/4', '=']);
      expect(bloc.state.displayText, '1/2');
    });

    test('1/2 × 1/2 = 1/4', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1/2', '×', '1/2', '=']);
      expect(bloc.state.displayText, '1/4');
    });

    test('1/2 ÷ 1/4 = 2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1/2', '÷', '1/4', '=']);
      expect(bloc.state.displayText, '2');
    });

    test('1/16 + 1/16 = 1/8 (reduces)', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1/16', '+', '1/16', '=']);
      expect(bloc.state.displayText, '1/8');
    });

    test('improper result 3/4 + 3/4 = 1 1/2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['3/4', '+', '3/4', '=']);
      expect(bloc.state.displayText, '1 1/2');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Mixed-number measurements (whole + fraction)', () {
    test('type 2 then 1/2 builds "2 1/2"', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '1/2']);
      expect(bloc.state.displayText, '2 1/2');
    });

    test('2 1/2 + 1 1/2 = 4', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '1/2', '+', '1', '1/2', '=']);
      expect(bloc.state.displayText, '4');
    });

    test('5 3/4 + 2 1/4 = 8', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '3/4', '+', '2', '1/4', '=']);
      expect(bloc.state.displayText, '8');
    });

    test('1 1/2 × 2 = 3', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '1/2', '×', '2', '=']);
      expect(bloc.state.displayText, '3');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Order of operations & chaining', () {
    test('2 + 3 × 4 = 14 (× before +)', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '+', '3', '×', '4', '=']);
      expect(bloc.state.displayText, '14');
    });

    test('10 - 2 - 3 = 5 (left associative)', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '0', '-', '2', '-', '3', '=']);
      expect(bloc.state.displayText, '5');
    });

    test('continue after equals: 2 + 2 = 4 then + 1 = 5', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '+', '2', '=']);
      expect(bloc.state.displayText, '4');
      await _type(bloc, ['+', '1', '=']);
      expect(bloc.state.displayText, '5');
    });

    test('new digit after equals starts fresh', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '+', '2', '=']);
      await _type(bloc, ['7', '=']);
      expect(bloc.state.displayText, '7');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Parentheses', () {
    test('( 2 + 3 ) × 4 = 20', () async {
      final bloc = _newBloc();
      await _type(bloc, ['(', '2', '+', '3', ')', '×', '4', '=']);
      expect(bloc.state.displayText, '20');
    });

    test('( 1/2 + 1/2 ) × 4 = 4', () async {
      final bloc = _newBloc();
      await _type(bloc, ['(', '1/2', '+', '1/2', ')', '×', '4', '=']);
      expect(bloc.state.displayText, '4');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Percent', () {
    test('50 % = 1/2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '0', '%']);
      expect(bloc.state.displayText, '1/2');
    });

    test('200 % = 2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '0', '0', '%']);
      expect(bloc.state.displayText, '2');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Negate (±)', () {
    test('5 then ± = -5', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '±']);
      expect(bloc.state.displayText, '-5');
    });

    test('± twice returns to 5', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '±', '±']);
      expect(bloc.state.displayText, '5');
    });

    test('negative in a sum: 5 + 3 then ± on 3 → 2', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '+', '3', '±', '=']);
      expect(bloc.state.displayText, '2');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Editing: backspace & clear', () {
    test('backspace removes last digit: 123 → 12', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '2', '3', '⌫']);
      expect(bloc.state.displayText, '12');
    });

    test('backspace after equals clears to 0', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '+', '2', '=']);
      await _type(bloc, ['⌫']);
      expect(bloc.state.displayText, '0');
    });

    test('clear resets everything', () async {
      final bloc = _newBloc();
      await _type(bloc, ['9', '+', '9', '=']);
      await _type(bloc, ['C']);
      expect(bloc.state.displayText, '0');
      expect(bloc.state.expression, '');
      expect(bloc.state.linearResult, '');
      expect(bloc.state.squareResult, '');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Feet/inch & square-foot conversion (the key feature)', () {
    test('12 in → 1 ft linear result', () async {
      final bloc = _newBloc();
      await _type(bloc, ['1', '2', '=']);
      expect(bloc.state.linearResult, contains('1 ft'));
      expect(bloc.state.squareResult, contains('sq ft'));
    });

    test('24 in → 2 ft linear result', () async {
      final bloc = _newBloc();
      await _type(bloc, ['2', '4', '=']);
      expect(bloc.state.linearResult, contains('2 ft'));
    });

    test('conversion use case: 18 in linear', () {
      final result = ConvertUnitsUseCase().execute(Fraction(18), false);
      expect(result, contains('1 ft'));
    });

    test('conversion use case: 288 sq in = 2.000 sq ft', () {
      final result = ConvertUnitsUseCase().execute(Fraction(288), true);
      expect(result, '2.000 sq ft');
    });

    test('conversion use case: 72 sq in = 0.500 sq ft', () {
      final result = ConvertUnitsUseCase().execute(Fraction(72), true);
      expect(result, '0.500 sq ft');
    });

    test('negative value converts with single sign', () {
      final result = ConvertUnitsUseCase().execute(Fraction(-288), true);
      expect(result, startsWith('-'));
      expect(result, contains('sq ft'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Error handling & stability (no crashes)', () {
    test('divide by zero shows Error, not a crash', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '÷', '0', '=']);
      expect(bloc.state.displayText, 'Error');
    });

    test('unbalanced parenthesis shows Error', () async {
      final bloc = _newBloc();
      await _type(bloc, ['(', '2', '+', '3', '=']);
      expect(bloc.state.displayText, 'Error');
    });

    test('equals on empty input does nothing', () async {
      final bloc = _newBloc();
      await _type(bloc, ['=']);
      expect(bloc.state.displayText, '0');
    });

    test('leading operator is ignored', () async {
      final bloc = _newBloc();
      await _type(bloc, ['+']);
      expect(bloc.state.displayText, '0');
    });

    test('double operator is replaced, then evaluates: 5 + × 2 = 10', () async {
      final bloc = _newBloc();
      await _type(bloc, ['5', '+', '×', '2', '=']);
      expect(bloc.state.displayText, '10');
    });

    test('backspace on empty stays at 0', () async {
      final bloc = _newBloc();
      await _type(bloc, ['⌫']);
      expect(bloc.state.displayText, '0');
    });

    test('percent with nothing entered does not crash', () async {
      final bloc = _newBloc();
      await _type(bloc, ['%']);
      expect(bloc.state.displayText, '0');
    });

    test('negate with nothing entered does not crash', () async {
      final bloc = _newBloc();
      await _type(bloc, ['±']);
      expect(bloc.state.displayText, '0');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('Pure use-case sanity checks', () {
    test('calculator reduces results', () {
      final r = CalculatorUseCase().execute(Fraction(1, 16), Fraction(1, 16), '+');
      expect(FormatFractionUseCase().execute(r), '1/8');
    });

    test('parse mixed number', () {
      expect(ParseFractionUseCase().execute('2 3/4'), Fraction(11, 4));
    });

    test('parse negative mixed number', () {
      expect(ParseFractionUseCase().execute('-2 3/4'), Fraction(-11, 4));
    });

    test('format whole number drops fraction', () {
      expect(FormatFractionUseCase().execute(Fraction(8, 2)), '4');
    });
  });
}
