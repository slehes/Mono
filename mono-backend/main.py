from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import auth, search, tracks, landing, artists, albums, playlists, likes, radio

app = FastAPI(title="Mono Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(search.router)
app.include_router(tracks.router)
app.include_router(landing.router)
app.include_router(artists.router)
app.include_router(albums.router)
app.include_router(playlists.router)
app.include_router(likes.router)
app.include_router(radio.router)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "mono-backend"}
