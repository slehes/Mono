import SwiftUI

struct GlassButton: View {
    var icon: String?
    var label: String?
    var cornerRadius: CGFloat = 50
    var size: CGFloat = 44
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                GlassEffectView(cornerRadius: cornerRadius)
                HStack(spacing: 6) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                    }
                    if let label {
                        Text(label)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, label != nil ? 16 : 0)
            }
            .frame(width: label != nil ? nil : size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// Circular play/pause variant
struct GlassPlayButton: View {
    var isPlaying: Bool
    var size: CGFloat = 56
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                GlassEffectView(cornerRadius: size / 2)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: isPlaying ? 0 : 2)
            }
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
            )
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
