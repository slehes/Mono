import SwiftUI

struct PlaylistDetailScreen: View {
    let playlist: MonoPlaylist
    @StateObject private var vm = DetailViewModel()
    @ObservedObject private var player = PlayerService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.monoBackground.ignoresSafeArea()

            if vm.isLoading {
                GlassLoadingView()
            } else if let pl = vm.playlist {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 14) {
                            RemoteImage(url: pl.coverURL, cornerRadius: 20)
                                .frame(width: 200, height: 200)
                                .shadow(color: Color.monoAccent.opacity(0.2), radius: 30)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)

                            Text(pl.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.white)

                            Text("\(pl.trackCount) треков")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.45))

                            HStack(spacing: 14) {
                                Button {
                                    if let first = pl.tracks.first {
                                        player.play(track: first, queue: pl.tracks)
                                    }
                                } label: {
                                    Label("Слушать", systemImage: "play.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Capsule().fill(Color.monoAccent))
                                }
                                .buttonStyle(.plain)

                                GlassButton(icon: "shuffle", size: 44) {
                                    let shuffled = pl.tracks.shuffled()
                                    if let first = shuffled.first {
                                        player.play(track: first, queue: shuffled)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                        // Tracks
                        LazyVStack(spacing: 8) {
                            ForEach(pl.tracks) { track in
                                TrackRow(track: track) {
                                    player.play(track: track, queue: pl.tracks)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 140)
                    }
                }
            }

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
        .task { await vm.loadPlaylist(uid: playlist.uid, kind: playlist.kind) }
    }
}

extension MonoPlaylist: Hashable {
    public static func == (lhs: MonoPlaylist, rhs: MonoPlaylist) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
