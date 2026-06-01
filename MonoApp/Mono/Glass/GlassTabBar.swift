import SwiftUI

struct GlassTabBar: View {
    @Binding var selection: Int
    let items: [(icon: String, label: String)]

    var body: some View {
        ZStack {
            GlassEffectView(cornerRadius: 28)
                .frame(height: 64)

            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    GlassTabItem(
                        icon: items[idx].icon,
                        label: items[idx].label,
                        isSelected: selection == idx
                    ) {
                        selection = idx
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 64)
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
    }
}

private struct GlassTabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .symbolVariant(isSelected ? .fill : .none)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.monoAccent : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.monoAccent.opacity(0.18))
                }
            }
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
