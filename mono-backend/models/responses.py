from pydantic import BaseModel
from typing import Optional


class TrackModel(BaseModel):
    id: int
    title: str
    artists: list[str]
    album: Optional[str] = None
    duration_ms: int
    cover_url: Optional[str] = None
    liked: bool = False


class ArtistModel(BaseModel):
    id: int
    name: str
    cover_url: Optional[str] = None
    genres: list[str] = []
    followers: Optional[int] = None


class AlbumModel(BaseModel):
    id: int
    title: str
    artists: list[str]
    year: Optional[int] = None
    cover_url: Optional[str] = None
    track_count: int = 0
    tracks: list[TrackModel] = []


class PlaylistModel(BaseModel):
    kind: int
    uid: int
    title: str
    cover_url: Optional[str] = None
    track_count: int = 0
    tracks: list[TrackModel] = []


class SearchResultModel(BaseModel):
    tracks: list[TrackModel] = []
    artists: list[ArtistModel] = []
    albums: list[AlbumModel] = []
    playlists: list[PlaylistModel] = []


class StreamUrlModel(BaseModel):
    url: str
    track_id: int


class DeviceCodeModel(BaseModel):
    session_id: str
    user_code: str
    verification_url: str
    expires_in: int


class TokenModel(BaseModel):
    access_token: str
    status: str = "authorized"


class LandingModel(BaseModel):
    chart: list[TrackModel] = []
    personal_playlists: list[PlaylistModel] = []
    new_releases: list[AlbumModel] = []
    mixes: list[PlaylistModel] = []
