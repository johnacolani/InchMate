import SwiftUI
#if canImport(WatchKit)
import WatchKit
#endif

private enum Palette {
    static let background = Color(red: 0.098, green: 0.094, blue: 0.094)
    static let panel = Color.white.opacity(0.08)
    static let number = Color(white: 0.20)
    static let op = Color(red: 1.0, green: 0.62, blue: 0.04)   // #FF9F0A
    static let danger = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
    static let fraction = Color(red: 0.42, green: 0.30, blue: 0.55)
    static let accent = Color(red: 0.78, green: 0.68, blue: 0.84) // #C7ADD5
}

struct ContentView: View {
    @StateObject private var calc = WatchCalculator()

    // 4-column keypad; scrolls vertically (Digital Crown works too).
    private let rows: [[String]] = [
        ["C", "⌫", "÷", "×"],
        ["7", "8", "9", "-"],
        ["4", "5", "6", "+"],
        ["1", "2", "3", "="],
        ["0", "1/2", "1/4", "1/8"],
        ["1/16", "3/16", "5/16", "7/16"],
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                display
                ForEach(rows.indices, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(rows[r], id: \.self) { label in
                            CalcButton(label: label) { handle(label) }
                        }
                    }
                }
            }
            .padding(4)
        }
        .background(Palette.background.ignoresSafeArea())
    }

    private var display: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(calc.expression.isEmpty ? " " : calc.expression)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(calc.display)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
            if !calc.linear.isEmpty {
                Text(calc.linear)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Palette.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(6)
        .background(Palette.panel)
        .cornerRadius(8)
    }

    private func handle(_ label: String) {
        #if canImport(WatchKit)
        WKInterfaceDevice.current().play(.click) // subtle tap feedback
        #endif
        switch label {
        case "C": calc.clear()
        case "⌫": calc.backspace()
        case "=": calc.equals()
        case "+", "-", "×", "÷": calc.inputOperator(label)
        default:
            if label.contains("/") { calc.inputFraction(label) }
            else { calc.inputDigit(label) }
        }
    }
}

struct CalcButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: label.contains("/") ? 13 : 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.plain)
        .background(color)
        .cornerRadius(8)
    }

    private var color: Color {
        if label == "C" || label == "⌫" { return Palette.danger }
        if ["+", "-", "×", "÷", "="].contains(label) { return Palette.op }
        if label.contains("/") { return Palette.fraction }
        return Palette.number
    }
}

#Preview {
    ContentView()
}
