# InchMate Apple Watch app — implementation explained

A walkthrough of how the standalone watchOS calculator is built, written for a
junior developer. Pair this with the setup steps in [README.md](README.md).

---

## 1. The big constraint: Flutter can't run on watchOS

Our main app is Flutter (Dart). **watchOS is not a Flutter platform**, so none of
our Dart code (`CalculatorBloc`, the fraction use-cases) can run on the watch. An
Apple Watch app *must* be native **SwiftUI + Swift**. That's why we wrote a small,
self-contained watch app and **re-implemented** the calculator logic in Swift.

It's a sibling app, not a port. It shares no runtime code with the Flutter app —
only the *design* and the *math rules*.

## 2. The four files and what each does

Everything lives in `ios/InchMateWatch/`:

| File | Role | Analogy in the Flutter app |
|---|---|---|
| `WatchFraction.swift` | Math: exact fractions, parsing, formatting, ft/in conversion | `fraction` package + parse/format/convert use-cases |
| `WatchCalculator.swift` | State + expression evaluation | `CalculatorBloc` |
| `ContentView.swift` | UI (keypad + display) | `FractionCalculatorScreen` + `CalculatorButton` |
| `InchMateWatchApp.swift` | App entry point (`@main`) | `main.dart` / `runApp` |

Same **separation of concerns** as the phone app: **math → state → UI**.

## 3. Why a custom `WatchFraction` instead of `Double`

Measurements are fractions (1/16, 3/8, …). With `Double`, rounding errors creep
in (`0.1 + 0.2 != 0.3`). So `WatchFraction` stores a **numerator and denominator
as integers** and does exact arithmetic, reducing with GCD:

```swift
static func + (l: WatchFraction, r: WatchFraction) -> WatchFraction {
    WatchFraction(l.numerator * r.denominator + r.numerator * l.denominator,
                  l.denominator * r.denominator).reduced()
}
```

That's why `1/16 + 1/16` gives exactly `1/8`, never `0.125`.

Supporting helpers:
- `FractionParser.parse` reads `"5"`, `"1/2"`, `"27 1/2"`, `"-3 1/4"` — the same
  value forms the phone app produces.
- `FractionFormatter.format` prints a mixed number (`16 1/2`).
- `FractionFormatter.linearFeet` converts inches to `feet' inches"` (e.g.
  `16 1/2"` → `1' 4 1/2"`).

## 4. State management: `ObservableObject` (SwiftUI's version of BLoC)

`WatchCalculator` is an `ObservableObject`. Properties marked `@Published`
automatically notify the UI when they change:

```swift
@Published var display: String = "0"   // like a BLoC state field
```

The view holds it with `@StateObject`:

```swift
@StateObject private var calc = WatchCalculator()
```

When `calc.display` changes, SwiftUI **rebuilds** the view — exactly like
`BlocBuilder` rebuilding when a new state is emitted. No manual refresh.

| SwiftUI | Flutter / BLoC equivalent |
|---|---|
| `ObservableObject` + `@Published` | `Bloc` + state fields |
| `@StateObject` | `BlocProvider` (owns the instance) |
| view rebuild on change | `BlocBuilder` |

## 5. How a tap flows through the system

Pressing `×`:

1. **UI** (`ContentView.handle`) plays a haptic and calls `calc.inputOperator("×")`.
2. **State** (`WatchCalculator`) commits the current number to a token list,
   records the operator, and updates `@Published var display`.
3. SwiftUI sees the change and **re-renders**.

One-way data flow: **UI → method → state → UI rebuild** — the same shape as the
phone app's event → bloc → state → builder.

## 6. Evaluating the expression (the interesting algorithm)

On `=`, we evaluate a token list like `["2","+","3","×","4"]` with correct
precedence using the **two-stack (shunting-yard) method** — the same approach as
the Dart `_evaluateExpression`:

```swift
// one stack of values, one of operators
while let last = ops.last, precedence(last) >= precedence(t) {
    apply(&values, ops.removeLast())   // do higher/equal precedence first
}
ops.append(t)
```

`× ÷` have precedence 2, `+ −` have precedence 1, so `2 + 3 × 4 = 14`.

## 7. The UI: a declarative SwiftUI grid

`ContentView` describes the keypad as **data** (a 2D array of labels) and renders
it with nested stacks:

```swift
ForEach(rows.indices, id: \.self) { r in
    HStack {
        ForEach(rows[r], id: \.self) { label in
            CalcButton(label: label) { handle(label) }
        }
    }
}
```

`CalcButton` picks its colour by role (orange operator, red clear, purple
fraction) — the same colour language as the phone app. SwiftUI is
**declarative**: describe *what* the screen looks like for the current state, and
the framework works out *how* to update it.

## 8. Testing the engine without a watch

Because the math/state live in files that only import `Foundation`/`Combine`,
we can compile and run them on plain macOS — no watch needed:

```bash
swiftc -o enginetest \
  ios/InchMateWatch/WatchFraction.swift \
  ios/InchMateWatch/WatchCalculator.swift \
  main.swift        # a small file that drives the calculator and prints results
./enginetest
```

Verified cases (all pass):

```
1/2 + 1/4      => 3/4
6 × 2 3/4      => 16 1/2      (linear: 1' 4 1/2")
2 + 3 × 4      => 14          (precedence)
1/16 + 1/16    => 1/8
```

This is the payoff of keeping the math independent of the UI — it's unit-testable
in isolation.

## 9. How we ran it on the simulator (for verification)

The normal way is to add a **watchOS App target** in Xcode and hit Run. To verify
without that manual step we:

1. **Compiled** the four Swift files against the watch-simulator SDK (`swiftc`).
2. Built a **universal binary** with `lipo` (arm64 + x86_64) so it runs on both
   Apple-Silicon and Intel Mac simulators.
3. Packaged an `.app` with an `Info.plist` whose `WKApplication` / `WKWatchOnly`
   keys tell watchOS "this is a standalone watch app."
4. `xcrun simctl install` + `launch` onto the booted watch simulator.

For real development/shipping you don't do this by hand — Xcode's watch target
handles arch, Info.plist, and embedding into the iOS app automatically. See
[README.md](README.md).

## Key takeaways

- **SwiftUI concepts map onto Flutter ones** (`@Published`↔state,
  `@StateObject`↔provider, rebuild-on-change↔`BlocBuilder`).
- **Model → State → View** separation keeps the math testable on its own.
- **Exact integer fractions** avoid floating-point drift — essential for a
  measurement tool.
