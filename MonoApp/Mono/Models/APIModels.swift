import Foundation

// MARK: - API response Codable types

struct APITrack: Codable {
    let id: Int
    let title: String
    let artists: [String]
    let album: String?
    let duration_ms: Int
    let cover_url: String?
    let liked: Bool?

    func toDomain() -> MonoTrack {
        MonoTrack(
            id: id, title: title, artists: artists,
            album: album, durationMs: duration_ms,
            coverURL: cover_url, isLiked: liked ?? false
        )
    }
}

struct APIArtist: Codable {
    let id: Int
    let name: String
    let cover_url: String?
    let genres: [String]
    let followers: Int?

    func toDomain() -> MonoArtist {
        MonoArtist(id: id, name: name, coverURL: cover_url, genres: genres, followers: followers)
    }
}

struct APIAlbum: Codable {
    let id: Int
    let title: String
    let artists: [String]
    let year: Int?
    let cover_url: String?
    let track_count: Int
    let tracks: [APITrack]?

    func toDomain() -> MonoAlbum {
        MonoAlbum(
            id: id, title: title, artists: artists, year: year,
            coverURL: cover_url, trackCount: track_count,
            tracks: tracks?.map { $0.toDomain() } ?? []
        )
    }
}

struct APIPlaylist: Codable {
    let kind: Int
    let uid: Int
    let title: String
    let cover_url: String?
    let track_count: Int
    let tracks: [APITrack]?

    func toDomain() -> MonoPlaylist {
        MonoPlaylist(
            id: "\(uid)_\(kind)", kind: kind, uid: uid, title: title,
            coverURL: cover_url, trackCount: track_count,
            tracks: tracks?.map { $0.toDomain() } ?? []
        )
    }
}

struct APISearchResult: Codable {
    let tracks: [APITrack]?
    let artists: [APIArtist]?
    let albums: [APIAlbum]?
    let playlists: [APIPlaylist]?
}

struct APILanding: Codable {
    let chart: [APITrack]?
    let personal_playlists: [APIPlaylist]?
    let new_releases: [APIAlbum]?
    let mixes: [APIPlaylist]?
}

struct APIStreamUrl: Codable {
    let url: String
    let track_id: Int
}

struct APIDeviceCode: Codable {
    let session_id: String
    let user_code: String
    let verification_url: String
    let expires_in: Int
}

struct APIPollResult: Codable {
    let status: String
    let access_token: String?
}

struct APITracksWrapper: Codable {
    let tracks: [APITrack]
}

struct APIAlbumsWrapper: Codable {
    let albums: [APIAlbum]
}

struct APIPlaylistsWrapper: Codable {
    let playlists: [APIPlaylist]
}
