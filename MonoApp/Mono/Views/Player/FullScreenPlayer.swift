import SwiftUI

struct FullScreenPlayer: View {
    @ObservedObject private var player = PlayerService.shared
    @Binding var isPresented: Bool
    @State private var sliderValue: Float = 0
    @State private var isSliding = false

    var body: some View {
        ZStack {
            // Blurred cover background
            if let url = player.currentTrack?.coverURL {
                RemoteImage(url: url, cornerRadius: 0)
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 50)
                    .scaleEffect(1.2)
                    .opacity(0.4)
            }

            // Dark overlay
            Color.monoBackground.opacity(0.65).ignoresSafeArea()

            // Purple glow
            Circle()
                .fill(Color.monoAccent.opacity(0.2))
                .blur(radius: 80)
                .frame(width: 400)

            VStack(spacing: 0) {
                // Drag handle + close
                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 4)
                    Spacer()
                }
                .padding(.top, 16)
                .overlay(alignment: .trailing) {
                    GlassButton(icon: "chevron.down", size: 36) {
                        isPresented = false
                    }
                    .padding(.trailing, 20)
                }

                Spacer()

                // Cover
                RemoteImage(url: player.currentTrack?.coverURL, cornerRadius: 24)
                    .frame(width: 280, height: 280)
                    .shadow(color: Color.monoAccent.opacity(0.3), radius: 40, y: 20)
                    .scaleEffect(player.isPlaying ? 1.0 : 0.9)
                    .animation(.spring(response: 0.4), value: player.isPlaying)

                Spacer()

                VStack(spacing: 24) {
                    // Track info + like
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(player.currentTrack?.title ?? "")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(player.currentTrack?.artistsString ?? "")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                        Spacer()

                        Button {
                            Task { await player.toggleLike() }
                        } label: {
                            Image(systemName: player.currentTrack?.isLiked == true ? "heart.fill" : "heart")
                                .font(.system(size: 24))
                                .foregroundStyle(player.currentTrack?.isLiked == true ? Color.monoAccent : .white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 32)

                    // Slider
                    VStack(spacing: 6) {
                        GlassSlider(
                            value: Binding(
                                get: { isSliding ? sliderValue : player.progress },
                                set: { sliderValue = $0 }
                            ),
                            onEditingChanged: { editing in
                                isSliding = editing
                                if !editing { player.seek(to: sliderValue) }
                            }
                        )
                        .frame(height: 28)
                        .padding(.horizontal, 32)

                        HStack {
                            Text(player.currentTimeStr)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.45))
                            Spacer()
                            Text(player.durationStr)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                        .padding(.horizontal, 34)
                    }

                    // Controls
                    HStack(spacing: 0) {
                        // Shuffle
                        GlassButton(icon: "shuffle", size: 44) {
                            player.isShuffled.toggle()
                        }
                        .opacity(player.isShuffled ? 1 : 0.4)

                        Spacer()

                        // Previous
                        Button { player.previous() } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        // Play/Pause (large)
                        GlassPlayButton(isPlaying: player.isPlaying, size: 72) {
                            player.playPause()
                        }
                        .overlay {
                            if player.isLoading {
                                ProgressView().tint(.white)
                            }
                        }

                        Spacer()

                        // Next
                        Button { player.next() } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        // Repeat
                        GlassButton(
                            icon: player.repeatMode == .one ? "repeat.1" : "repeat",
                            size: 44
                        ) {
                            switch player.repeatMode {
                            case .off: player.repeatMode = .all
                            case .all: player.repeatMode = .one
                            case .one: player.repeatMode = .off
                            }
                        }
                        .opacity(player.repeatMode == .off ? 0.4 : 1)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
