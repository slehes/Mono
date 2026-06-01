import asyncio
from yandex_music import ClientAsync

# token -> ClientAsync
_clients: dict[str, ClientAsync] = {}
_lock = asyncio.Lock()


async def get_client(token: str) -> ClientAsync:
    async with _lock:
        if token not in _clients:
            client = ClientAsync(token)
            await client.init()
            _clients[token] = client
        return _clients[token]


def evict_client(token: str) -> None:
    _clients.pop(token, None)
