from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import SearchResultModel, TrackModel, ArtistModel, AlbumModel

router = APIRouter(prefix="/api/search", tags=["search"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("", response_model=SearchResultModel)
async def search(q: str, token: str = Depends(get_token)):
    if not q.strip():
        return SearchResultModel()
    client = await get_client(token)
    result = await client.search(q, nocorrect=False)

    tracks: list[TrackModel] = []
    if result.tracks:
        for t in (result.tracks.results or [])[:20]:
            tracks.append(TrackModel(
                id=t.id,
                title=t.title or "",
                artists=[a.name for a in (t.artists or [])],
                album=t.albums[0].title if t.albums else None,
                duration_ms=t.duration_ms or 0,
                cover_url=_cover(t.cover_uri),
            ))

    artists: list[ArtistModel] = []
    if result.artists:
        for a in (result.artists.results or [])[:10]:
            cover = None
            if a.cover:
                cover = _cover(a.cover.uri)
            artists.append(ArtistModel(
                id=a.id,
                name=a.name or "",
                cover_url=cover,
                genres=a.genres or [],
            ))

    albums: list[AlbumModel] = []
    if result.albums:
        for al in (result.albums.results or [])[:10]:
            artist_names = [a.name for a in (al.artists or [])]
            albums.append(AlbumModel(
                id=al.id,
                title=al.title or "",
                artists=artist_names,
                year=al.year,
                cover_url=_cover(al.cover_uri),
                track_count=al.track_count or 0,
            ))

    return SearchResultModel(tracks=tracks, artists=artists, albums=albums)
