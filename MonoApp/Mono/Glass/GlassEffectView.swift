import SwiftUI
import UIKit
import LiquidGlassKit

// MARK: - UIViewRepresentable wrapper for LiquidGlassEffectView

struct GlassEffectView: UIViewRepresentable {
    var style: LiquidGlassEffect.Style = .regular
    var cornerRadius: CGFloat = 16
    var tintColor: UIColor? = UIColor(red: 0.48, green: 0.41, blue: 0.93, alpha: 0.15)

    func makeUIView(context: Context) -> UIView {
        let effect = LiquidGlassEffect(style: style, isNative: true)
        effect.tintColor = tintColor
        let view = VisualEffectView(effect: effect)
        view.layer.cornerRadius = cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
    }
}

// MARK: - GlassCard: glass background + border + clip

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    GlassEffectView(cornerRadius: cornerRadius)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
