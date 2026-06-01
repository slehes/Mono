from fastapi import APIRouter, Depends, HTTPException

from services.yandex_client import get_client
from routers._deps import get_token
from models.responses import LandingModel, TrackModel, AlbumModel, PlaylistModel

router = APIRouter(prefix="/api/landing", tags=["landing"])


def _cover(uri: str | None, size: str = "400x400") -> str | None:
    if not uri:
        return None
    return "https://" + uri.replace("%%", size)


@router.get("", response_model=LandingModel)
async def get_landing(token: str = Depends(get_token)):
    client = await get_client(token)

    chart_tracks: list[TrackModel] = []
    new_releases: list[AlbumModel] = []
    personal_playlists: list[PlaylistModel] = []
    mixes: list[PlaylistModel] = []

    try:
        landing = await client.landing(["chart", "new-releases", "personal-playlists", "play-contexts"])

        for block in (landing.blocks or []):
            if block.type == "chart":
                for entity in (block.entities or [])[:20]:
                    t = entity.data.track if hasattr(entity.data, "track") else entity.data
                    chart_tracks.append(TrackModel(
                        id=t.id,
                        title=t.title or "",
                        artists=[a.name for a in (t.artists or [])],
                        album=t.albums[0].title if t.albums else None,
                        duration_ms=t.duration_ms or 0,
                        cover_url=_cover(t.cover_uri),
                    ))

            elif block.type == "new-releases":
                for entity in (block.entities or [])[:15]:
                    al = entity.data
                    new_releases.append(AlbumModel(
                        id=al.id,
                        title=al.title or "",
                        artists=[a.name for a in (al.artists or [])],
                        year=al.year,
                        cover_url=_cover(al.cover_uri),
                        track_count=al.track_count or 0,
                    ))

            elif block.type == "personal-playlists":
                for entity in (block.entities or [])[:10]:
                    pl = entity.data
                    personal_playlists.append(PlaylistModel(
                        kind=pl.kind,
                        uid=pl.uid,
                        title=pl.title or "",
                        cover_url=_cover(getattr(pl, "cover", None) and pl.cover.uri if hasattr(pl, "cover") and pl.cover else None),
                        track_count=pl.track_count or 0,
                    ))

            elif block.type == "play-contexts":
                for entity in (block.entities or [])[:10]:
                    pl = entity.data
                    if hasattr(pl, "kind"):
                        mixes.append(PlaylistModel(
                            kind=pl.kind,
                            uid=getattr(pl, "uid", 0),
                            title=pl.title or "",
                            cover_url=_cover(getattr(pl.cover, "uri", None) if hasattr(pl, "cover") and pl.cover else None),
                            track_count=pl.track_count or 0,
                        ))
    except Exception as e:
        raise HTTPException(502, f"Landing error: {e}")

    return LandingModel(
        chart=chart_tracks,
        personal_playlists=personal_playlists,
        new_releases=new_releases,
        mixes=mixes,
    )
