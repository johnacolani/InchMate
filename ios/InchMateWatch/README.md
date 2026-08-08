# InchMate Apple Watch app

A **standalone** watchOS calculator (SwiftUI). It does not depend on the phone
app and reimplements the fraction math in Swift, because Flutter/Dart cannot run
on watchOS.

Files (add all to the watch target):
- `InchMateWatchApp.swift` — `@main` entry point
- `ContentView.swift` — SwiftUI keypad + display
- `WatchCalculator.swift` — calculator state / expression evaluation
- `WatchFraction.swift` — exact fraction math, parsing, formatting, ft/in conversion

## One-time Xcode setup

Flutter cannot create the watch target — do this once in Xcode:

1. Open the iOS project in Xcode:
   `open ios/Runner.xcworkspace`
2. **File → New → Target… → watchOS → App**. Set:
   - Product Name: **InchMateWatch**
   - Interface: **SwiftUI**, Language: **Swift**
   - Leave "Include Notification Scene" etc. **unchecked**
   - When asked, **Embed in Companion Application: Runner** (this adds the
     "Embed Watch Content" build phase so the watch app ships inside the iOS app).
3. Xcode generates a target folder with its own `App`/`ContentView`. **Delete
   those generated Swift files** (Move to Trash), then **drag the four files in
   this folder** into the new target's group, and in the dialog check
   **Target Membership → InchMateWatch** (only the watch target).
4. Select the watch target → **General**:
   - Bundle Identifier will be `com.johncolani.inchmate.watchkitapp` (auto).
   - Minimum Deployments: **watchOS 10.0** (or 9.0 if you need older watches).
5. Select the **InchMateWatch** scheme + a paired watch simulator and **Run** to
   test. To ship: build the normal iOS IPA — the watch app is embedded
   automatically. (`flutter build ipa` invokes the Runner scheme, which now
   embeds the watch content.)

## Notes / limits (v1)

- No parentheses or % (they don't fit the watch keypad); +, −, ×, ÷ with correct
  precedence, plus common fractions and a linear-feet readout.
- Keypad scrolls; the Digital Crown scrolls it too.
- Fully standalone — no WatchConnectivity. If you later want to push results to
  the phone, that's a separate feature.
