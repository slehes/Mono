from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import AlbumModel, TrackModel

router = APIRouter(prefix="/api/albums", tags=["albums"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("/{album_id}", response_model=AlbumModel)
async def get_album(album_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        album = await client.albums_with_tracks(album_id)
        tracks = []
        for vol in (album.volumes or []):
            for t in vol:
                tracks.append(TrackModel(
                    id=t.id,
                    title=t.title or "",
                    artists=[a.name for a in (t.artists or [])],
                    album=album.title,
                    duration_ms=t.duration_ms or 0,
                    cover_url=_cover(t.cover_uri or album.cover_uri),
                ))
        return AlbumModel(
            id=album.id,
            title=album.title or "",
            artists=[a.name for a in (album.artists or [])],
            year=album.year,
            cover_url=_cover(album.cover_uri),
            track_count=album.track_count or len(tracks),
            tracks=tracks,
        )
    except Exception as e:
        raise HTTPException(502, str(e))
