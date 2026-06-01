import SwiftUI

extension View {
    func monoBackground() -> some View {
        self.background(Color.monoBackground.ignoresSafeArea())
    }

    func hideNavBar() -> some View {
        self
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - RemoteImage

struct RemoteImage: View {
    let url: String?
    var cornerRadius: CGFloat = 8

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundStyle(.white.opacity(0.3))
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let urlStr = url, let url = URL(string: urlStr) else { return }
        if let cached = ImageCache.shared.get(urlStr) { image = cached; return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let ui = UIImage(data: data) else { return }
        ImageCache.shared.set(urlStr, image: ui)
        image = ui
    }
}

// Simple NSCache image cache
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    func get(_ key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ key: String, image: UIImage) { cache.setObject(image, forKey: key as NSString) }
}
