import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var likedTracks: [MonoTrack] = []
    @Published var playlists: [MonoPlaylist] = []
    @Published var isLoading = false
    @Published var filter: LibraryFilter = .all

    enum LibraryFilter: String, CaseIterable {
        case all = "Все"
        case tracks = "Треки"
        case playlists = "Плейлисты"
    }

    func load() async {
        guard likedTracks.isEmpty && playlists.isEmpty else { return }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        async let tracks = APIService.shared.getLikedTracks()
        async let pls = APIService.shared.getLikedPlaylists()
        likedTracks = (try? await tracks) ?? []
        playlists = (try? await pls) ?? []
        isLoading = false
    }
}
