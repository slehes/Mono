import SwiftUI

struct MiniPlayer: View {
    @ObservedObject private var player = PlayerService.shared
    @Binding var showFullPlayer: Bool

    var body: some View {
        Button { showFullPlayer = true } label: {
            HStack(spacing: 14) {
                // Cover
                RemoteImage(url: player.currentTrack?.coverURL, cornerRadius: 8)
                    .frame(width: 44, height: 44)

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentTrack?.title ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(player.currentTrack?.artistsString ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Controls
                HStack(spacing: 16) {
                    if player.isLoading {
                        ProgressView().tint(.white).scaleEffect(0.7)
                    } else {
                        Button {
                            player.playPause()
                        } label: {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }

                    Button { player.next() } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(GlassBackground(cornerRadius: 20))
        .overlay(alignment: .bottom) {
            // Progress line
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.monoAccent)
                    .frame(width: geo.size.width * CGFloat(player.progress), height: 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 2)
            .clipShape(Capsule())
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
    }
}
