from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
import httpx

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import TrackModel, StreamUrlModel

router = APIRouter(prefix="/api/tracks", tags=["tracks"])


def _track_to_model(t) -> TrackModel:
    cover = None
    if t.cover_uri:
        cover = "https://" + t.cover_uri.replace("%%", "400x400")
    return TrackModel(
        id=t.id,
        title=t.title or "",
        artists=[a.name for a in (t.artists or [])],
        album=t.albums[0].title if t.albums else None,
        duration_ms=t.duration_ms or 0,
        cover_url=cover,
    )


@router.get("/{track_id}/stream")
async def get_stream_url(track_id: int, token: str = Depends(get_token)):
    """Returns a fresh direct MP3 URL. URLs expire in ~60s — never cache."""
    client = await get_client(token)
    tracks = await client.tracks([track_id])
    if not tracks:
        raise HTTPException(404, "Track not found")
    track = tracks[0]
    try:
        info = await track.get_download_info_async(get_direct_links=True)
    except Exception as e:
        raise HTTPException(502, f"Failed to get download info: {e}")

    if not info:
        raise HTTPException(404, "No download info available (requires Yandex Plus?)")

    # Prefer highest bitrate
    best = max(info, key=lambda x: x.bitrate_in_kbps or 0)
    if not best.direct_link:
        raise HTTPException(502, "Direct link unavailable")

    return StreamUrlModel(url=best.direct_link, track_id=track_id)


@router.get("/{track_id}")
async def get_track(track_id: int, token: str = Depends(get_token)):
    client = await get_client(token)
    tracks = await client.tracks([track_id])
    if not tracks:
        raise HTTPException(404, "Track not found")
    return _track_to_model(tracks[0])
