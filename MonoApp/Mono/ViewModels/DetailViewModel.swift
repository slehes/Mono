import SwiftUI

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var album: MonoAlbum?
    @Published var artist: MonoArtist?
    @Published var artistTracks: [MonoTrack] = []
    @Published var artistAlbums: [MonoAlbum] = []
    @Published var playlist: MonoPlaylist?
    @Published var isLoading = false
    @Published var error: String?

    func loadAlbum(_ id: Int) async {
        isLoading = true
        do { album = try await APIService.shared.getAlbum(id) }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }

    func loadArtist(_ id: Int) async {
        isLoading = true
        async let a = APIService.shared.getArtist(id)
        async let tracks = APIService.shared.getArtistTracks(id)
        async let albums = APIService.shared.getArtistAlbums(id)
        artist = try? await a
        artistTracks = (try? await tracks) ?? []
        artistAlbums = (try? await albums) ?? []
        isLoading = false
    }

    func loadPlaylist(uid: Int, kind: Int) async {
        isLoading = true
        do { playlist = try await APIService.shared.getPlaylist(uid: uid, kind: kind) }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }
}
