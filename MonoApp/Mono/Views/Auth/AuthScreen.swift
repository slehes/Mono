import SwiftUI

struct AuthScreen: View {
    @StateObject private var vm = AuthViewModel()
    @Binding var isAuthenticated: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0A0F"), Color(hex: "12101A"), Color(hex: "0A0A0F")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Purple glow
            Circle()
                .fill(Color.monoAccent.opacity(0.15))
                .blur(radius: 80)
                .frame(width: 400, height: 400)
                .offset(y: -100)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    GlassEffectView(cornerRadius: 32)
                    Image("mono_logo")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                }
                .frame(width: 120, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.monoAccent.opacity(0.4), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color.monoAccent.opacity(0.3), radius: 30)

                Spacer().frame(height: 32)

                Text("Mono")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Музыка без границ")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                Spacer()

                if vm.deviceCode == nil {
                    // Sign in button
                    Button {
                        vm.startAuth()
                    } label: {
                        ZStack {
                            Capsule()
                                .fill(Color.monoAccent)
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Войти через Яндекс")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 56)
                        .shadow(color: Color.monoAccent.opacity(0.5), radius: 16, y: 8)
                    }
                    .disabled(vm.isLoading)
                    .padding(.horizontal, 32)
                } else {
                    DeviceCodeView(code: vm.deviceCode!)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.top, 12)
                        .glass(cornerRadius: 10, padding: 8)
                        .padding(.horizontal, 32)
                }

                Spacer().frame(height: 60)
            }
            .padding(.horizontal, 24)
        }
        .onChange(of: vm.isAuthenticated) { auth in
            if auth { isAuthenticated = true }
        }
    }
}
