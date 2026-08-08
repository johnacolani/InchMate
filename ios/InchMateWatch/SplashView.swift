import SwiftUI

/// Root of the watch app: shows an animated splash, then reveals the calculator.
struct RootView: View {
    @State private var showCalculator = false

    var body: some View {
        ZStack {
            if showCalculator {
                ContentView().transition(.opacity)
            } else {
                SplashView().transition(.opacity)
            }
        }
        .onAppear {
            // Let the splash animation play, then cross-fade to the calculator.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.4)) { showCalculator = true }
            }
        }
    }
}

/// Animated launch screen: the orange "1/2" mark scales/fades in over a ruler,
/// mirroring the app icon.
struct SplashView: View {
    @State private var appear = false

    private let bg = Color(red: 0.098, green: 0.094, blue: 0.094)
    private let orange = Color(red: 1.0, green: 0.624, blue: 0.039)
    private let accent = Color(red: 0.78, green: 0.68, blue: 0.84)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(spacing: 8) {
                VStack(spacing: 3) {
                    Text("1").font(.system(size: 40, weight: .bold))
                    RoundedRectangle(cornerRadius: 2).frame(width: 54, height: 5)
                    Text("2").font(.system(size: 40, weight: .bold))
                }
                .foregroundColor(orange)
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1 : 0)

                // Ruler tick strip.
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { i in
                        Rectangle()
                            .fill(accent)
                            .frame(width: 2, height: i % 2 == 0 ? 12 : 7)
                    }
                }
                .opacity(appear ? 1 : 0)

                Text("InchMate")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 6)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                appear = true
            }
        }
    }
}

#Preview {
    RootView()
}
