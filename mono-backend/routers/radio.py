from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import TrackModel

router = APIRouter(prefix="/api/radio", tags=["radio"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("/{station_id}/tracks")
async def get_radio_tracks(station_id: str, token: str = Depends(get_token)):
    """station_id format: 'artist:12345' or 'user:onyourwave'"""
    client = await get_client(token)
    try:
        parts = station_id.split(":")
        if len(parts) != 2:
            raise HTTPException(400, "station_id must be 'type:id'")
        station_type, station_value = parts
        tracks_result = await client.rotor_station_tracks(
            f"{station_type}:{station_value}",
            queue=None,
        )
        tracks = []
        for seq in (tracks_result.sequence or [])[:20]:
            t = seq.track
            tracks.append(TrackModel(
                id=t.id,
                title=t.title or "",
                artists=[a.name for a in (t.artists or [])],
                album=t.albums[0].title if t.albums else None,
                duration_ms=t.duration_ms or 0,
                cover_url=_cover(t.cover_uri),
            ))
        return {"tracks": tracks}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(502, str(e))
