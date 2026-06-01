from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import PlaylistModel, TrackModel

router = APIRouter(prefix="/api/playlists", tags=["playlists"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


def _pl_cover(pl) -> str | None:
    try:
        if pl.cover and pl.cover.uri:
            return _cover(pl.cover.uri)
        if pl.cover and pl.cover.items_uri:
            return _cover(pl.cover.items_uri[0])
    except Exception:
        pass
    return None


@router.get("/{uid}/{kind}", response_model=PlaylistModel)
async def get_playlist(uid: int, kind: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        pl = await client.users_playlists(kind, user_id=uid)
        tracks = []
        for pt in (pl.tracks or [])[:200]:
            t = pt.track if hasattr(pt, "track") and pt.track else None
            if not t:
                continue
            tracks.append(TrackModel(
                id=t.id,
                title=t.title or "",
                artists=[a.name for a in (t.artists or [])],
                album=t.albums[0].title if t.albums else None,
                duration_ms=t.duration_ms or 0,
                cover_url=_cover(t.cover_uri),
            ))
        return PlaylistModel(
            kind=pl.kind,
            uid=pl.uid,
            title=pl.title or "",
            cover_url=_pl_cover(pl),
            track_count=pl.track_count or len(tracks),
            tracks=tracks,
        )
    except Exception as e:
        raise HTTPException(502, str(e))
