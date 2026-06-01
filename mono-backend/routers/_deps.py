from fastapi import Header, HTTPException


async def get_token(authorization: str = Header(...)) -> str:
    if not authorization.startswith("Bearer "):
        raise HTTPException(401, "Missing Bearer token")
    return authorization.removeprefix("Bearer ").strip()
