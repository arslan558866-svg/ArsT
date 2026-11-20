import SwiftUI
import LocalAuthentication

struct AppLockView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @State private var unlocked = false
    @State private var message = "Подтвердите вход с помощью Face ID"

    var body: some View {
        Group {
            if unlocked {
                content()
            } else {
                VStack(spacing: 18) {
                    Image(systemName: "faceid").font(.system(size: 58)).foregroundStyle(Color.gold)
                    Text("Мой фитнес PRO").font(.largeTitle.bold())
                    Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Разблокировать") { authenticate() }
                        .buttonStyle(.borderedProminent).tint(Color.navy)
                }
                .padding(30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.cream.ignoresSafeArea())
                .onAppear(perform: authenticate)
            }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            message = "Биометрия недоступна. Используйте код-пароль устройства."
            // Device-owner authentication falls back to passcode where available.
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Защитить личный тренировочный дневник") { success, _ in
            DispatchQueue.main.async { unlocked = success }
        }
    }
}

extension Color {
    static let navy = Color(red: 20/255, green: 36/255, blue: 58/255)
    static let gold = Color(red: 184/255, green: 154/255, blue: 98/255)
    static let cream = Color(red: 245/255, green: 242/255, blue: 234/255)
}
