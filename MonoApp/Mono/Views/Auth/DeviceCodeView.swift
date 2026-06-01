import SwiftUI

struct DeviceCodeView: View {
    let code: APIDeviceCode

    var body: some View {
        VStack(spacing: 20) {
            GlassCard(cornerRadius: 20, padding: 24) {
                VStack(spacing: 16) {
                    Text("Авторизация")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    VStack(spacing: 8) {
                        Text("Перейдите по ссылке:")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))

                        Text(code.verification_url)
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.monoAccent)

                        Text("и введите код:")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    // Big code display
                    Text(code.user_code)
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                        .tracking(8)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.monoAccent.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.monoAccent.opacity(0.5), lineWidth: 1)
                                )
                        )

                    Button {
                        UIPasteboard.general.string = code.user_code
                    } label: {
                        Label("Скопировать код", systemImage: "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.monoAccent)
                    }

                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Color.monoAccent)
                            .scaleEffect(0.8)
                        Text("Ожидаю авторизации...")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
