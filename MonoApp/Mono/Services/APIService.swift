import Foundation

// MARK: - API Service

actor APIService {
    static let shared = APIService()
    private let base = "http://localhost:8000"
    private let session = URLSession.shared

    private var token: String? { Keychain.accessToken }

    private func request(_ path: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        guard let url = URL(string: base + path) else {
            throw MonoError.invalidURL
        }
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.httpBody = body
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw MonoError.api(msg)
        }
        return data
    }

    // MARK: Auth

    func startDeviceAuth() async throws -> APIDeviceCode {
        let data = try await request("/api/auth/device-code", method: "POST")
        return try JSONDecoder().decode(APIDeviceCode.self, from: data)
    }

    func pollToken(sessionId: String) async throws -> APIPollResult {
        let data = try await request("/api/auth/poll-token?session_id=\(sessionId)", method: "POST")
        return try JSONDecoder().decode(APIPollResult.self, from: data)
    }

    // MARK: Stream — NEVER cache, call fresh every time

    func getStreamURL(trackId: Int) async throws -> String {
        let data = try await request("/api/tracks/\(trackId)/stream")
        let result = try JSONDecoder().decode(APIStreamUrl.self, from: data)
        return result.url
    }

    // MARK: Landing

    func getLanding() async throws -> MonoLanding {
        let data = try await request("/api/landing")
        let api = try JSONDecoder().decode(APILanding.self, from: data)
        return MonoLanding(
            chart: api.chart?.map { $0.toDomain() } ?? [],
            personalPlaylists: api.personal_playlists?.map { $0.toDomain() } ?? [],
            newReleases: api.new_releases?.map { $0.toDomain() } ?? [],
            mixes: api.mixes?.map { $0.toDomain() } ?? []
        )
    }

    // MARK: Search

    func search(_ query: String) async throws -> MonoSearchResult {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let data = try await request("/api/search?q=\(q)")
        let api = try JSONDecoder().decode(APISearchResult.self, from: data)
        return MonoSearchResult(
            tracks: api.tracks?.map { $0.toDomain() } ?? [],
            artists: api.artists?.map { $0.toDomain() } ?? [],
            albums: api.albums?.map { $0.toDomain() } ?? []
        )
    }

    // MARK: Artist

    func getArtist(_ id: Int) async throws -> MonoArtist {
        let data = try await request("/api/artists/\(id)")
        return try JSONDecoder().decode(APIArtist.self, from: data).toDomain()
    }

    func getArtistTracks(_ id: Int) async throws -> [MonoTrack] {
        let data = try await request("/api/artists/\(id)/tracks")
        return try JSONDecoder().decode(APITracksWrapper.self, from: data).tracks.map { $0.toDomain() }
    }

    func getArtistAlbums(_ id: Int) async throws -> [MonoAlbum] {
        let data = try await request("/api/artists/\(id)/albums")
        return try JSONDecoder().decode(APIAlbumsWrapper.self, from: data).albums.map { $0.toDomain() }
    }

    // MARK: Album

    func getAlbum(_ id: Int) async throws -> MonoAlbum {
        let data = try await request("/api/albums/\(id)")
        return try JSONDecoder().decode(APIAlbum.self, from: data).toDomain()
    }

    // MARK: Playlist

    func getPlaylist(uid: Int, kind: Int) async throws -> MonoPlaylist {
        let data = try await request("/api/playlists/\(uid)/\(kind)")
        return try JSONDecoder().decode(APIPlaylist.self, from: data).toDomain()
    }

    // MARK: Likes

    func getLikedTracks() async throws -> [MonoTrack] {
        let data = try await request("/api/likes/tracks")
        return try JSONDecoder().decode(APITracksWrapper.self, from: data).tracks.map { $0.toDomain() }
    }

    func likeTrack(_ id: Int) async throws {
        _ = try await request("/api/likes/tracks/\(id)", method: "POST")
    }

    func unlikeTrack(_ id: Int) async throws {
        _ = try await request("/api/likes/tracks/\(id)", method: "DELETE")
    }

    func getLikedPlaylists() async throws -> [MonoPlaylist] {
        let data = try await request("/api/likes/playlists")
        return try JSONDecoder().decode(APIPlaylistsWrapper.self, from: data).playlists.map { $0.toDomain() }
    }

    // MARK: Radio

    func getRadioTracks(stationId: String) async throws -> [MonoTrack] {
        let data = try await request("/api/radio/\(stationId)/tracks")
        return try JSONDecoder().decode(APITracksWrapper.self, from: data).tracks.map { $0.toDomain() }
    }
}

enum MonoError: LocalizedError {
    case invalidURL
    case api(String)
    case noStream

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .api(let msg): return "API error: \(msg)"
        case .noStream: return "Stream URL unavailable"
        }
    }
}
