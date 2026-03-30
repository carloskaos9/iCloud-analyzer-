import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var tokenInput = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E3A5F"), Color(hex: "#0F172A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 100, height: 100)
                        Image(systemName: "wifi")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 8)

                    Text("Wi-Fi Analyzer Pro")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Insira seu token de acesso para continuar")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 48)

                // Token Input Card
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Token de Acesso", systemImage: "key.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                            .textCase(.uppercase)
                            .tracking(1)

                        SecureField("Cole seu token aqui...", text: $tokenInput)
                            .focused($isFocused)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isFocused ? Color.blue : Color.white.opacity(0.15), lineWidth: 1.5)
                            )
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                    }

                    // Error message
                    if let error = auth.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red.opacity(0.8))
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Login Button
                    Button(action: {
                        isFocused = false
                        Task { await auth.validateToken(tokenInput.trimmingCharacters(in: .whitespaces)) }
                    }) {
                        HStack(spacing: 10) {
                            if auth.isValidating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                                Text("Validando...")
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Entrar")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            tokenInput.isEmpty || auth.isValidating
                            ? Color.blue.opacity(0.4)
                            : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    .disabled(tokenInput.isEmpty || auth.isValidating)
                }
                .padding(24)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Help text
                VStack(spacing: 6) {
                    Text("Não tem um token?")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                    Text("Solicite ao administrador do sistema")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.7))
                }

                Spacer()
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    LoginView().environmentObject(AuthManager.shared)
}
