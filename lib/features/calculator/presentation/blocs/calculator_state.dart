/// A single completed calculation, kept for the history tape.
class CalcHistoryEntry {
  final String expression; // readable form, quotes stripped
  final String result; // primary fraction/inch result (e.g. 27 1/2")
  final String linearResult; // linear feet form (e.g. 2' 3-1/2")
  final String squareResult; // square feet form

  const CalcHistoryEntry({
    required this.expression,
    required this.result,
    required this.linearResult,
    required this.squareResult,
  });
}

class CalculatorState {
  final String displayText;
  final String expression;
  final String linearResult;
  final String squareResult;
  final List<CalcHistoryEntry> history;

  CalculatorState({
    required this.displayText,
    required this.expression,
    required this.linearResult,
    required this.squareResult,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? displayText,
    String? expression,
    String? linearResult,
    String? squareResult,
    List<CalcHistoryEntry>? history,
  }) {
    return CalculatorState(
      displayText: displayText ?? this.displayText,
      expression: expression ?? this.expression,
      linearResult: linearResult ?? this.linearResult,
      squareResult: squareResult ?? this.squareResult,
      history: history ?? this.history,
    );
  }
}
