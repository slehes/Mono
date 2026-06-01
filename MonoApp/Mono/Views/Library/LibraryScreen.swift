import SwiftUI

struct LibraryScreen: View {
    @StateObject private var vm = LibraryViewModel()
    @ObservedObject private var player = PlayerService.shared
    @State private var selectedPlaylist: MonoPlaylist?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.monoBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("Коллекция")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(LibraryViewModel.LibraryFilter.allCases, id: \.self) { f in
                                FilterChip(label: f.rawValue, isSelected: vm.filter == f) {
                                    vm.filter = f
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 16)

                    if vm.isLoading {
                        Spacer()
                        GlassLoadingView()
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                // Liked tracks section
                                if vm.filter != .playlists && !vm.likedTracks.isEmpty {
                                    likedTracksCard

                                    ForEach(vm.likedTracks) { track in
                                        TrackRow(track: track) {
                                            player.play(track: track, queue: vm.likedTracks)
                                        }
                                    }
                                }

                                // Playlists
                                if vm.filter != .tracks && !vm.playlists.isEmpty {
                                    ForEach(vm.playlists) { pl in
                                        PlaylistRow(playlist: pl) {
                                            selectedPlaylist = pl
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 140)
                        }
                        .refreshable { await vm.refresh() }
                    }
                }
            }
            .task { await vm.load() }
            .navigationDestination(item: $selectedPlaylist) { PlaylistDetailScreen(playlist: $0) }
        }
    }

    private var likedTracksCard: some View {
        Button {
            if !vm.likedTracks.isEmpty {
                player.play(track: vm.likedTracks[0], queue: vm.likedTracks)
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    LinearGradient(colors: [Color.monoAccent, Color.monoAccent.opacity(0.5)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Мне нравится")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(vm.likedTracks.count) треков")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()

                Image(systemName: "play.fill")
                    .foregroundStyle(Color.monoAccent)
            }
            .padding(14)
            .background(GlassBackground(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? Color.monoAccent : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct PlaylistRow: View {
    let playlist: MonoPlaylist
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                RemoteImage(url: playlist.coverURL, cornerRadius: 10)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(playlist.trackCount) треков")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
            .background(GlassBackground(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
