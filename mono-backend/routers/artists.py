from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import ArtistModel, TrackModel, AlbumModel

router = APIRouter(prefix="/api/artists", tags=["artists"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("/{artist_id}")
async def get_artist(artist_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        artist = await client.artists(artist_id)
        a = artist[0] if isinstance(artist, list) else artist
        cover = _cover(a.cover.uri if a.cover else None)
        return ArtistModel(
            id=a.id,
            name=a.name or "",
            cover_url=cover,
            genres=a.genres or [],
            followers=a.counts.listeners if a.counts else None,
        )
    except Exception as e:
        raise HTTPException(502, str(e))


@router.get("/{artist_id}/tracks")
async def get_artist_tracks(artist_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        result = await client.artists_tracks(artist_id)
        tracks = []
        for t in (result.tracks or [])[:50]:
            tracks.append(TrackModel(
                id=t.id,
                title=t.title or "",
                artists=[a.name for a in (t.artists or [])],
                album=t.albums[0].title if t.albums else None,
                duration_ms=t.duration_ms or 0,
                cover_url=_cover(t.cover_uri),
            ))
        return {"tracks": tracks}
    except Exception as e:
        raise HTTPException(502, str(e))


@router.get("/{artist_id}/albums")
async def get_artist_albums(artist_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        result = await client.artists_direct_albums(artist_id)
        albums = []
        for al in (result.albums or [])[:30]:
            albums.append(AlbumModel(
                id=al.id,
                title=al.title or "",
                artists=[a.name for a in (al.artists or [])],
                year=al.year,
                cover_url=_cover(al.cover_uri),
                track_count=al.track_count or 0,
            ))
        return {"albums": albums}
    except Exception as e:
        raise HTTPException(502, str(e))
