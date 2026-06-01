import asyncio
import uuid

from fastapi import APIRouter, HTTPException
from yandex_music import ClientAsync

router = APIRouter(prefix="/api/auth", tags=["auth"])

# session_id -> {"code_info": dict | None, "token": str | None, "event": asyncio.Event}
_sessions: dict[str, dict] = {}


@router.post("/device-code")
async def start_device_auth():
    """Step 1: Start Yandex Device Flow. Returns user_code + verification_url."""
    session_id = str(uuid.uuid4())
    code_ready = asyncio.Event()
    _sessions[session_id] = {"code_info": None, "token": None, "event": code_ready}

    async def _on_code(code):
        _sessions[session_id]["code_info"] = {
            "session_id": session_id,
            "user_code": code.user_code,
            "verification_url": code.verification_url,
            "expires_in": code.expires_in,
        }
        code_ready.set()

    async def _auth_task():
        try:
            client = ClientAsync()
            token_data = await client.device_auth(on_code=_on_code)
            _sessions[session_id]["token"] = token_data.access_token
        except Exception as exc:
            _sessions[session_id]["error"] = str(exc)

    asyncio.create_task(_auth_task())

    try:
        await asyncio.wait_for(code_ready.wait(), timeout=15)
    except asyncio.TimeoutError:
        raise HTTPException(504, "Timeout waiting for Yandex device code")

    return _sessions[session_id]["code_info"]


@router.post("/poll-token")
async def poll_token(session_id: str):
    """Step 2: Poll until user authorizes on Yandex. Returns access_token when ready."""
    session = _sessions.get(session_id)
    if not session:
        raise HTTPException(404, "Session not found")
    if session.get("error"):
        raise HTTPException(400, session["error"])
    if session["token"]:
        token = session.pop("token")
        _sessions.pop(session_id, None)
        return {"status": "authorized", "access_token": token}
    return {"status": "pending"}
