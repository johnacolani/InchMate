abstract class CalculatorEvent {}

class ClearEvent extends CalculatorEvent {}

class NegateEvent extends CalculatorEvent {}

class OperatorEvent extends CalculatorEvent {
  final String operator;
  OperatorEvent(this.operator);
}

class EqualsEvent extends CalculatorEvent {}

class DigitEvent extends CalculatorEvent {
  final String digit;
  DigitEvent(this.digit);
}

class FractionEvent extends CalculatorEvent {
  final String fraction;
  FractionEvent(this.fraction);
}

class PercentEvent extends CalculatorEvent {}

class ParenthesisEvent extends CalculatorEvent {
  final bool isOpen;
  ParenthesisEvent(this.isOpen);
}
class BackspaceEvent extends CalculatorEvent {}

/// Reuse a past result from the history tape as the current value, so the user
/// can keep calculating from it.
class ReuseHistoryEvent extends CalculatorEvent {
  final String result;
  final String linearResult;
  final String squareResult;
  ReuseHistoryEvent({
    required this.result,
    required this.linearResult,
    required this.squareResult,
  });
}

/// Clear the entire history tape.
class ClearHistoryEvent extends CalculatorEvent {}

/// Paste a copied value into the expression as an operand.
class PasteEvent extends CalculatorEvent {
  final String value;
  PasteEvent(this.value);
}