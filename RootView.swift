import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            ContentView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView(progress: progress)
                    .transition(.opacity)
            }
        }
        .task { await startUp() } // inicia “carregamento”
    }

    // Fluxo de arranque (exemplo com 4 etapas)
    private func startUp() async {

        try? await Task.sleep(nanoseconds: 300_000_000)
        await update(0.25)

        try? await Task.sleep(nanoseconds: 300_000_000)
        await update(0.50)
    
        try? await Task.sleep(nanoseconds: 300_000_000)
        await update(0.75)

        try? await Task.sleep(nanoseconds: 300_000_000)
        await update(1.00)

        await MainActor.run {
            withAnimation(.easeOut(duration: 0.35)) { showSplash = false }
        }
    }

    // Agora é realmente assíncrona (faz hop pro MainActor)
    private func update(_ value: Double) async {
        await MainActor.run {
            withAnimation(.linear(duration: 0.2)) {
                progress = value
            }
        }
    }
}
