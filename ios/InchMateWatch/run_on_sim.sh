#!/usr/bin/env bash
# Build the standalone InchMate watch app and run it on a watchOS simulator.
# Usage:  bash ios/InchMateWatch/run_on_sim.sh
#
# This exists because the watchOS target isn't in the Xcode project yet. Once you
# add a real Watch App target in Xcode, you'll just press Run instead.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC_DIR="$ROOT/ios/InchMateWatch"
OUT="$ROOT/build/watch_run"
BUNDLE_ID="com.johncolani.inchmatewatch"
APP="$OUT/InchMateWatch.app"

mkdir -p "$OUT"

# 1. Pick a watch simulator (prefer one already booted) and boot it.
WATCH=$(xcrun simctl list devices available | awk '/Apple Watch/{print; }' | grep -oE '[0-9A-Fa-f-]{36}' | head -1)
if [ -z "${WATCH:-}" ]; then echo "No watchOS simulator found. Install one in Xcode > Settings > Components."; exit 1; fi
echo "▸ Using watch simulator: $WATCH"
xcrun simctl boot "$WATCH" 2>/dev/null || true
open -a Simulator

# 2. Compile a universal (arm64 + x86_64) simulator binary.
SDK=$(xcrun --sdk watchsimulator --show-sdk-path)
SRCS=("$SRC_DIR/WatchFraction.swift" "$SRC_DIR/WatchCalculator.swift" "$SRC_DIR/ContentView.swift" "$SRC_DIR/SplashView.swift" "$SRC_DIR/InchMateWatchApp.swift")
echo "▸ Compiling…"
xcrun -sdk watchsimulator swiftc -target arm64-apple-watchos11.0-simulator  -sdk "$SDK" -parse-as-library -o "$OUT/wa_arm" "${SRCS[@]}"
xcrun -sdk watchsimulator swiftc -target x86_64-apple-watchos11.0-simulator -sdk "$SDK" -parse-as-library -o "$OUT/wa_x86" "${SRCS[@]}"
mkdir -p "$APP"
lipo -create "$OUT/wa_arm" "$OUT/wa_x86" -output "$APP/InchMateWatch"

# 3. Write the Info.plist (WKApplication + WKWatchOnly = standalone watch app).
cat > "$APP/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDisplayName</key><string>InchMate</string>
  <key>CFBundleExecutable</key><string>InchMateWatch</string>
  <key>CFBundleIdentifier</key><string>com.johncolani.inchmatewatch</string>
  <key>CFBundleName</key><string>InchMateWatch</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleSupportedPlatforms</key><array><string>WatchSimulator</string></array>
  <key>MinimumOSVersion</key><string>11.0</string>
  <key>UIDeviceFamily</key><array><integer>4</integer></array>
  <key>WKApplication</key><true/>
  <key>WKWatchOnly</key><true/>
</dict></plist>
PLIST

# 3b. Compile the app-icon asset catalog into the bundle (if present).
if [ -d "$SRC_DIR/Assets.xcassets" ]; then
  echo "▸ Compiling app icon…"
  xcrun actool "$SRC_DIR/Assets.xcassets" \
    --compile "$APP" \
    --platform watchsimulator \
    --minimum-deployment-target 11.0 \
    --app-icon AppIcon \
    --output-partial-info-plist "$OUT/icon-partial.plist" >/dev/null 2>&1 || true
  # Merge the icon keys actool produced into the app Info.plist.
  if [ -f "$OUT/icon-partial.plist" ]; then
    /usr/libexec/PlistBuddy -c "Merge $OUT/icon-partial.plist" "$APP/Info.plist" >/dev/null 2>&1 || true
  fi
fi

# 4. Install and launch.
echo "▸ Installing & launching…"
xcrun simctl install "$WATCH" "$APP"
xcrun simctl launch "$WATCH" "$BUNDLE_ID"
echo "✓ InchMate is running on the watch simulator."
