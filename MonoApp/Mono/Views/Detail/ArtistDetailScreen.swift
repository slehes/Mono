import SwiftUI

struct ArtistDetailScreen: View {
    let artistId: Int
    @StateObject private var vm = DetailViewModel()
    @ObservedObject private var player = PlayerService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAlbum: MonoAlbum?

    var body: some View {
        ZStack {
            Color.monoBackground.ignoresSafeArea()

            if vm.isLoading {
                GlassLoadingView()
            } else if let artist = vm.artist {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Hero
                        ZStack(alignment: .bottomLeading) {
                            RemoteImage(url: artist.coverURL, cornerRadius: 0)
                                .frame(maxWidth: .infinity)
                                .frame(height: 360)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, Color.monoBackground],
                                startPoint: .center, endPoint: .bottom
                            )
                            .frame(height: 250)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(artist.name)
                                    .font(.system(size: 34, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)

                                if let followers = artist.followers {
                                    Text("\(Self.format(followers)) слушателей")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }

                        // Genres
                        if !artist.genres.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(artist.genres, id: \.self) { genre in
                                        Text(genre)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(Color.monoAccent)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule().fill(Color.monoAccent.opacity(0.15))
                                            )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 20)
                        }

                        // Popular tracks
                        if !vm.artistTracks.isEmpty {
                            Text("Популярные треки")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)

                            VStack(spacing: 8) {
                                ForEach(vm.artistTracks.prefix(10)) { track in
                                    TrackRow(track: track) {
                                        player.play(track: track, queue: vm.artistTracks)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Albums
                        if !vm.artistAlbums.isEmpty {
                            Text("Альбомы")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 12)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(vm.artistAlbums) { album in
                                        AlbumCard(album: album) { selectedAlbum = album }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer().frame(height: 140)
                    }
                }
            }

            // Back button
            VStack {
                HStack {
                    GlassButton(icon: "chevron.left", size: 40) { dismiss() }
                        .padding(.leading, 16)
                        .padding(.top, 56)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedAlbum) { AlbumDetailScreen(albumId: $0.id) }
        .task { await vm.loadArtist(artistId) }
    }

    private static func format(_ n: Int) -> String {
        if n >= 1_000_000 { return "\(n / 1_000_000)M" }
        if n >= 1_000 { return "\(n / 1_000)K" }
        return "\(n)"
    }
}


