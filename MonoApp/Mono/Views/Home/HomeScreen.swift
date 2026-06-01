import SwiftUI

struct HomeScreen: View {
    @StateObject private var vm = HomeViewModel()
    @ObservedObject private var player = PlayerService.shared
    @State private var selectedAlbum: MonoAlbum?
    @State private var selectedPlaylist: MonoPlaylist?
    @State private var selectedArtist: MonoArtist?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.monoBackground.ignoresSafeArea()
                // Purple ambient glow
                Circle()
                    .fill(Color.monoAccent.opacity(0.08))
                    .blur(radius: 100)
                    .frame(width: 500)
                    .offset(y: -200)

                if vm.isLoading {
                    GlassLoadingView()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 32) {
                            // Header
                            headerView

                            // Chart
                            if !vm.landing.chart.isEmpty {
                                sectionTitle("Чарт дня")
                                chartSection
                            }

                            // Personal playlists
                            if !vm.landing.personalPlaylists.isEmpty {
                                sectionTitle("Для тебя")
                                playlistsSection(vm.landing.personalPlaylists)
                            }

                            // New releases
                            if !vm.landing.newReleases.isEmpty {
                                sectionTitle("Новые релизы")
                                albumsSection(vm.landing.newReleases)
                            }

                            // Mixes
                            if !vm.landing.mixes.isEmpty {
                                sectionTitle("Миксы")
                                playlistsSection(vm.landing.mixes)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 140)
                    }
                    .refreshable { await vm.refresh() }
                }
            }
            .task { await vm.load() }
            .navigationDestination(item: $selectedAlbum) { album in
                AlbumDetailScreen(albumId: album.id)
            }
            .navigationDestination(item: $selectedPlaylist) { pl in
                PlaylistDetailScreen(playlist: pl)
            }
            .navigationDestination(item: $selectedArtist) { artist in
                ArtistDetailScreen(artistId: artist.id)
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Привет!")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                Text("Что слушаем?")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            ZStack {
                GlassEffectView(cornerRadius: 20)
                Image("mono_logo")
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.top, 8)
    }

    private var chartSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(vm.landing.chart.prefix(10).enumerated()), id: \.element.id) { idx, track in
                    ChartCard(track: track, rank: idx + 1) {
                        player.play(track: track, queue: vm.landing.chart)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func playlistsSection(_ playlists: [MonoPlaylist]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(playlists) { pl in
                    PlaylistCard(playlist: pl) {
                        selectedPlaylist = pl
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func albumsSection(_ albums: [MonoAlbum]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(albums) { album in
                    AlbumCard(album: album) {
                        selectedAlbum = album
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }
}

// MARK: - Chart Card

struct ChartCard: View {
    let track: MonoTrack
    let rank: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottomLeading) {
                    RemoteImage(url: track.coverURL, cornerRadius: 14)
                        .frame(width: 150, height: 150)

                    Text("#\(rank)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .padding(10)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(track.artistsString)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
            }
            .frame(width: 150)
            .glass(cornerRadius: 18, padding: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Playlist Card

struct PlaylistCard: View {
    let playlist: MonoPlaylist
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                RemoteImage(url: playlist.coverURL, cornerRadius: 12)
                    .frame(width: 140, height: 140)

                Text(playlist.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(width: 140, alignment: .leading)

                Text("\(playlist.trackCount) треков")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .glass(cornerRadius: 16, padding: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Album Card

struct AlbumCard: View {
    let album: MonoAlbum
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                RemoteImage(url: album.coverURL, cornerRadius: 12)
                    .frame(width: 140, height: 140)

                Text(album.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(width: 140, alignment: .leading)

                Text(album.artistsString)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            }
            .glass(cornerRadius: 16, padding: 10)
        }
        .buttonStyle(.plain)
    }
}
