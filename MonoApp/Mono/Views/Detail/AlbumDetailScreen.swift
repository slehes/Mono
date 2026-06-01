import SwiftUI

struct AlbumDetailScreen: View {
    let albumId: Int
    @StateObject private var vm = DetailViewModel()
    @ObservedObject private var player = PlayerService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.monoBackground.ignoresSafeArea()

            if vm.isLoading {
                GlassLoadingView()
            } else if let album = vm.album {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Cover + gradient
                        ZStack(alignment: .bottom) {
                            RemoteImage(url: album.coverURL, cornerRadius: 0)
                                .frame(maxWidth: .infinity)
                                .frame(height: 320)

                            LinearGradient(
                                colors: [.clear, Color.monoBackground],
                                startPoint: .top, endPoint: .bottom
                            )
                            .frame(height: 200)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            // Info
                            Text(album.title)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)

                            Text(album.artistsString)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.monoAccent)

                            if let year = album.year {
                                Text("\(year) · \(album.trackCount) треков")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.45))
                            }

                            // Play button
                            HStack(spacing: 14) {
                                Button {
                                    if let first = album.tracks.first {
                                        player.play(track: first, queue: album.tracks)
                                    }
                                } label: {
                                    Label("Слушать", systemImage: "play.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 14)
                                        .background(Capsule().fill(Color.monoAccent))
                                }
                                .buttonStyle(.plain)

                                GlassButton(icon: "shuffle", size: 48) {
                                    let shuffled = album.tracks.shuffled()
                                    if let first = shuffled.first {
                                        player.play(track: first, queue: shuffled)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -40)

                        // Track list
                        LazyVStack(spacing: 8) {
                            ForEach(Array(album.tracks.enumerated()), id: \.element.id) { idx, track in
                                TrackRow(track: track, showIndex: idx + 1) {
                                    player.play(track: track, queue: album.tracks)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 140)
                    }
                }
            }

            // Back button
            VStack {
                HStack {
                    GlassButton(icon: "chevron.left", size: 40) { dismiss() }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task { await vm.loadAlbum(albumId) }
    }
}


