import SwiftUI

struct SearchScreen: View {
    @StateObject private var vm = SearchViewModel()
    @ObservedObject private var player = PlayerService.shared
    @State private var selectedAlbum: MonoAlbum?
    @State private var selectedArtist: MonoArtist?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.monoBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Glass search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.5))
                        TextField("Поиск треков, артистов, альбомов...", text: $vm.query)
                            .foregroundStyle(.white)
                            .tint(Color.monoAccent)
                        if !vm.query.isEmpty {
                            Button { vm.query = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                    .padding(14)
                    .background(GlassBackground(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    if vm.isSearching {
                        Spacer()
                        GlassLoadingView()
                        Spacer()
                    } else if vm.query.isEmpty {
                        emptyState
                    } else {
                        resultsView
                    }
                }
            }
            .navigationDestination(item: $selectedAlbum) { AlbumDetailScreen(albumId: $0.id) }
            .navigationDestination(item: $selectedArtist) { ArtistDetailScreen(artistId: $0.id) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "waveform.and.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(Color.monoAccent.opacity(0.5))
            Text("Найди своё")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            Text("Треки, артисты, альбомы, плейлисты")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.4))
            Spacer()
        }
    }

    private var resultsView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Tracks
                if !vm.result.tracks.isEmpty {
                    resultSection("Треки") {
                        ForEach(vm.result.tracks) { track in
                            TrackRow(track: track) {
                                player.play(track: track, queue: vm.result.tracks)
                            }
                        }
                    }
                }

                // Artists
                if !vm.result.artists.isEmpty {
                    resultSection("Артисты") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(vm.result.artists) { artist in
                                    ArtistChip(artist: artist) {
                                        selectedArtist = artist
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }

                // Albums
                if !vm.result.albums.isEmpty {
                    resultSection("Альбомы") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(vm.result.albums) { album in
                                    AlbumCard(album: album) { selectedAlbum = album }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }

                if vm.result.tracks.isEmpty && vm.result.artists.isEmpty && vm.result.albums.isEmpty {
                    Text("Ничего не найдено")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 140)
        }
    }

    @ViewBuilder
    private func resultSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            content()
        }
    }
}

struct ArtistChip: View {
    let artist: MonoArtist
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                RemoteImage(url: artist.coverURL, cornerRadius: 40)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                Text(artist.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
            .glass(cornerRadius: 16, padding: 10)
        }
        .buttonStyle(.plain)
    }
}
