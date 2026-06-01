import SwiftUI

struct TrackRow: View {
    let track: MonoTrack
    var showIndex: Int? = nil
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let idx = showIndex {
                    Text("\(idx)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 24, alignment: .center)
                } else {
                    RemoteImage(url: track.coverURL, cornerRadius: 8)
                        .frame(width: 48, height: 48)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(track.artistsString)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(track.durationFormatted)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(GlassBackground(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct TrackRowCompact: View {
    let track: MonoTrack
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                RemoteImage(url: track.coverURL, cornerRadius: 6)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(track.artistsString)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
