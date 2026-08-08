import Foundation

/// Exact rational number (mirrors the Dart `fraction` package usage) so the
/// watch calculator never accumulates floating-point error on 1/16-style math.
struct WatchFraction: Equatable {
    let numerator: Int
    let denominator: Int

    init(_ numerator: Int, _ denominator: Int = 1) {
        precondition(denominator != 0, "denominator cannot be zero")
        // Keep the sign on the numerator so formatting is predictable.
        let sign = denominator < 0 ? -1 : 1
        self.numerator = numerator * sign
        self.denominator = denominator * sign
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = abs(a), b = abs(b)
        while b != 0 { (a, b) = (b, a % b) }
        return a == 0 ? 1 : a
    }

    func reduced() -> WatchFraction {
        let g = WatchFraction.gcd(numerator, denominator)
        return WatchFraction(numerator / g, denominator / g)
    }

    var doubleValue: Double { Double(numerator) / Double(denominator) }

    static func + (l: WatchFraction, r: WatchFraction) -> WatchFraction {
        WatchFraction(l.numerator * r.denominator + r.numerator * l.denominator,
                      l.denominator * r.denominator).reduced()
    }
    static func - (l: WatchFraction, r: WatchFraction) -> WatchFraction {
        WatchFraction(l.numerator * r.denominator - r.numerator * l.denominator,
                      l.denominator * r.denominator).reduced()
    }
    static func * (l: WatchFraction, r: WatchFraction) -> WatchFraction {
        WatchFraction(l.numerator * r.numerator, l.denominator * r.denominator).reduced()
    }
    static func / (l: WatchFraction, r: WatchFraction) -> WatchFraction {
        WatchFraction(l.numerator * r.denominator, l.denominator * r.numerator).reduced()
    }
}

/// Parses "5", "1/2", "27 1/2", "-3 1/4" — the same value forms the phone app
/// produces and accepts.
enum FractionParser {
    static func parse(_ input: String) -> WatchFraction? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }

        let negative = trimmed.hasPrefix("-")
        let body = negative ? String(trimmed.dropFirst()) : trimmed

        let value: WatchFraction?
        if body.contains(" ") {
            let parts = body.split(separator: " ")
            guard parts.count == 2, let whole = Int(parts[0]),
                  let frac = parseSimple(String(parts[1])) else { return nil }
            value = WatchFraction(whole) + frac
        } else {
            value = parseSimple(body)
        }

        guard let v = value else { return nil }
        return negative ? v * WatchFraction(-1) : v
    }

    private static func parseSimple(_ s: String) -> WatchFraction? {
        if s.contains("/") {
            let parts = s.split(separator: "/")
            guard parts.count == 2, let n = Int(parts[0]), let d = Int(parts[1]),
                  d != 0 else { return nil }
            return WatchFraction(n, d)
        }
        guard let n = Int(s) else { return nil }
        return WatchFraction(n)
    }
}

/// Formats a fraction as a mixed number, and converts inches to linear feet —
/// mirroring FormatFractionUseCase / ConvertUnitsUseCase on the phone.
enum FractionFormatter {
    static func format(_ f: WatchFraction) -> String {
        let r = f.reduced()
        let negative = r.numerator < 0
        let absNum = abs(r.numerator)
        let den = r.denominator
        let whole = absNum / den
        let rem = absNum % den
        let sign = negative ? "-" : ""

        if rem == 0 { return "\(sign)\(whole)" }
        if whole == 0 { return "\(sign)\(rem)/\(den)" }
        return "\(sign)\(whole) \(rem)/\(den)"
    }

    /// Inches -> feet + remaining inches, e.g. 27 1/2  ->  2' 3 1/2"
    static func linearFeet(_ f: WatchFraction) -> String {
        let negative = f.numerator < 0
        let sign = negative ? "-" : ""
        let absF = negative ? f * WatchFraction(-1) : f

        // Exact integer division (absF is non-negative) = floor.
        let wholeFeet = absF.numerator / (absF.denominator * 12)
        let remainder = absF - WatchFraction(wholeFeet * 12)
        return "\(sign)\(wholeFeet)' \(format(remainder))\""
    }
}
