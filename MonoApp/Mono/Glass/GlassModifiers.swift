import SwiftUI

// MARK: - .glass() modifier

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    GlassEffectView(cornerRadius: cornerRadius)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func glass(cornerRadius: CGFloat = 16, padding: CGFloat = 12) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - GlassBackground standalone

struct GlassBackground: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            GlassEffectView(cornerRadius: cornerRadius)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Loading glass overlay

struct GlassLoadingView: View {
    var body: some View {
        ZStack {
            GlassEffectView(cornerRadius: 20)
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
        }
        .frame(width: 72, height: 72)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
