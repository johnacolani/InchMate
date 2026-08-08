import Foundation
import Combine

/// Calculator state for the watch app. Builds an expression of number/operator
/// tokens and evaluates with operator precedence (mirrors CalculatorBloc, minus
/// parentheses/percent which don't fit the watch UI).
final class WatchCalculator: ObservableObject {
    @Published var expression: String = ""
    @Published var display: String = "0"
    @Published var linear: String = ""

    private var tokens: [String] = []   // committed numbers + operators
    private var current: String = ""    // number currently being typed
    private var justEvaluated = false

    private let operators: Set<String> = ["+", "-", "×", "÷"]

    // MARK: - Input

    func inputDigit(_ d: String) {
        if justEvaluated { reset() }
        current += d
        display = current
        rebuildExpression()
    }

    func inputFraction(_ f: String) {
        if justEvaluated { reset() }
        if current.isEmpty {
            current = f
        } else if current.contains(" ") {
            // Already "whole frac" — replace the fraction part.
            let parts = current.split(separator: " ")
            current = "\(parts[0]) \(f)"
        } else if current.contains("/") {
            // Bare fraction — replace it.
            current = f
        } else {
            // Whole number — attach as a mixed number.
            current = "\(current) \(f)"
        }
        display = current
        rebuildExpression()
    }

    func inputOperator(_ op: String) {
        justEvaluated = false
        if !current.isEmpty {
            tokens.append(current)
            current = ""
        }
        guard !tokens.isEmpty else { return } // can't start with an operator

        if let last = tokens.last, operators.contains(last) {
            tokens[tokens.count - 1] = op // replace a trailing operator
        } else {
            tokens.append(op)
        }
        display = op
        rebuildExpression()
    }

    func equals() {
        if !current.isEmpty {
            tokens.append(current)
            current = ""
        }
        guard !tokens.isEmpty else { return }
        guard let result = evaluate(tokens) else {
            display = "Error"
            return
        }
        let formatted = FractionFormatter.format(result)
        expression = tokens.joined(separator: " ") + " = " + formatted
        display = formatted
        linear = FractionFormatter.linearFeet(result)
        // Continue calculating from the result.
        tokens = [formatted]
        justEvaluated = true
    }

    func clear() { reset() }

    func backspace() {
        if justEvaluated { reset(); return }
        if !current.isEmpty {
            current.removeLast()
        } else if !tokens.isEmpty {
            tokens.removeLast()
        }
        display = current.isEmpty ? "0" : current
        rebuildExpression()
    }

    // MARK: - Internals

    private func reset() {
        tokens = []
        current = ""
        justEvaluated = false
        expression = ""
        display = "0"
        linear = ""
    }

    private func rebuildExpression() {
        var parts = tokens
        if !current.isEmpty { parts.append(current) }
        expression = parts.joined(separator: " ")
    }

    private func precedence(_ op: String) -> Int {
        (op == "×" || op == "÷") ? 2 : 1
    }

    private func apply(_ values: inout [WatchFraction], _ op: String) -> Bool {
        guard values.count >= 2 else { return false }
        let b = values.removeLast()
        let a = values.removeLast()
        switch op {
        case "+": values.append(a + b)
        case "-": values.append(a - b)
        case "×": values.append(a * b)
        case "÷":
            if b.numerator == 0 { return false } // divide by zero
            values.append(a / b)
        default: return false
        }
        return true
    }

    private func evaluate(_ tokens: [String]) -> WatchFraction? {
        var values: [WatchFraction] = []
        var ops: [String] = []

        for t in tokens {
            if operators.contains(t) {
                while let last = ops.last, precedence(last) >= precedence(t) {
                    if !apply(&values, ops.removeLast()) { return nil }
                }
                ops.append(t)
            } else {
                guard let f = FractionParser.parse(t) else { return nil }
                values.append(f)
            }
        }
        while !ops.isEmpty {
            if !apply(&values, ops.removeLast()) { return nil }
        }
        return values.count == 1 ? values.first : nil
    }
}
