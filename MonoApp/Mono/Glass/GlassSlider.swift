import SwiftUI
import UIKit

// UIViewRepresentable for LiquidGlassSlider
struct GlassSlider: UIViewRepresentable {
    @Binding var value: Float
    var range: ClosedRange<Float> = 0...1
    var accentColor: UIColor = UIColor(red: 0.48, green: 0.41, blue: 0.93, alpha: 1)
    var onEditingChanged: (Bool) -> Void = { _ in }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> LiquidGlassSlider {
        let slider = LiquidGlassSlider()
        slider.minimumValue = range.lowerBound
        slider.maximumValue = range.upperBound
        slider.value = value
        slider.minimumTrackTintColor = accentColor
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.2)
        slider.tintColor = accentColor
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.touchBegan), for: .touchDown)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.touchEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return slider
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard !context.coordinator.isDragging else { return }
        (uiView as? AnySlider)?.setValue(value, animated: true)
    }

    class Coordinator: NSObject {
        var parent: GlassSlider
        var isDragging = false

        init(_ parent: GlassSlider) { self.parent = parent }

        @objc func valueChanged(_ sender: AnyObject) {
            if let s = sender as? AnySlider { parent.value = s.value }
        }
        @objc func touchBegan() {
            isDragging = true
            parent.onEditingChanged(true)
        }
        @objc func touchEnded() {
            isDragging = false
            parent.onEditingChanged(false)
        }
    }
}
