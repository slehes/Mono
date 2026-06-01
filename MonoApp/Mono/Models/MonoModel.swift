import Foundation

// MARK: - Core domain models

struct MonoTrack: Identifiable, Hashable {
    let id: Int
    let title: String
    let artists: [String]
    let album: String?
    let durationMs: Int
    let coverURL: String?
    var isLiked: Bool = false

    var artistsString: String { artists.joined(separator: ", ") }
    var durationFormatted: String {
        let sec = durationMs / 1000
        return String(format: "%d:%02d", sec / 60, sec % 60)
    }
}

struct MonoArtist: Identifiable, Hashable {
    let id: Int
    let name: String
    let coverURL: String?
    let genres: [String]
    let followers: Int?
}

struct MonoAlbum: Identifiable, Hashable {
    let id: Int
    let title: String
    let artists: [String]
    let year: Int?
    let coverURL: String?
    let trackCount: Int
    var tracks: [MonoTrack] = []

    var artistsString: String { artists.joined(separator: ", ") }
}

struct MonoPlaylist: Identifiable, Hashable {
    let id: String         // "\(uid)_\(kind)"
    let kind: Int
    let uid: Int
    let title: String
    let coverURL: String?
    let trackCount: Int
    var tracks: [MonoTrack] = []
}

struct MonoSearchResult {
    var tracks: [MonoTrack] = []
    var artists: [MonoArtist] = []
    var albums: [MonoAlbum] = []
    var playlists: [MonoPlaylist] = []
}

struct MonoLanding {
    var chart: [MonoTrack] = []
    var personalPlaylists: [MonoPlaylist] = []
    var newReleases: [MonoAlbum] = []
    var mixes: [MonoPlaylist] = []
}
