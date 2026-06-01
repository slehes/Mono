from fastapi import APIRouter, Depends, HTTPException, Body

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import TrackModel

router = APIRouter(prefix="/api/likes", tags=["likes"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("/tracks")
async def get_liked_tracks(token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        liked = await client.users_likes_tracks()
        tracks = []
        for lt in (liked.tracks or [])[:200]:
            t = lt.track if hasattr(lt, "track") and lt.track else None
            if not t:
                continue
            tracks.append(TrackModel(
                id=t.id,
                title=t.title or "",
                artists=[a.name for a in (t.artists or [])],
                album=t.albums[0].title if t.albums else None,
                duration_ms=t.duration_ms or 0,
                cover_url=_cover(t.cover_uri),
                liked=True,
            ))
        return {"tracks": tracks}
    except Exception as e:
        raise HTTPException(502, str(e))


@router.post("/tracks/{track_id}")
async def like_track(track_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        await client.users_likes_tracks_add([track_id])
        return {"status": "liked"}
    except Exception as e:
        raise HTTPException(502, str(e))


@router.delete("/tracks/{track_id}")
async def unlike_track(track_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        await client.users_likes_tracks_remove([track_id])
        return {"status": "unliked"}
    except Exception as e:
        raise HTTPException(502, str(e))


@router.get("/playlists")
async def get_liked_playlists(token: str = Depends(get_token)):
    client = await get_client(token)
    try:
        playlists = await client.users_playlists_list()
        result = []
        for pl in (playlists or []):
            cover = None
            try:
                if pl.cover and pl.cover.uri:
                    cover = _cover(pl.cover.uri)
            except Exception:
                pass
            result.append({
                "kind": pl.kind,
                "uid": pl.uid,
                "title": pl.title or "",
                "cover_url": cover,
                "track_count": pl.track_count or 0,
            })
        return {"playlists": result}
    except Exception as e:
        raise HTTPException(502, str(e))
