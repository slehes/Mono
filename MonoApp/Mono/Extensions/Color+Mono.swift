import SwiftUI

extension Color {
    static let monoBackground  = Color(hex: "0A0A0F")
    static let monoAccent      = Color(hex: "7B68EE")
    static let monoGlassTint   = Color(hex: "7B68EE").opacity(0.15)
    static let monoGlassBorder = Color.white.opacity(0.1)
    static let monoText        = Color.white
    static let monoSubtext     = Color.white.opacity(0.55)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
