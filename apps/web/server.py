"""
GreenchClaw Web UI Server — port 18420
"""
import os
from pathlib import Path
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import FileResponse

ROOT = Path(__file__).resolve().parent.parent.parent
INDEX_HTML = ROOT / "apps" / "web" / "index.html"

app = FastAPI(title="GreenchClaw Web")

@app.get("/")
async def root():
    if INDEX_HTML.exists(): return FileResponse(str(INDEX_HTML))
    from fastapi.responses import HTMLResponse
    return HTMLResponse("<h1>🌿 GreenchClaw — index.html not found</h1>", status_code=404)

@app.get("/health")
async def health():
    return {"status": "ok", "service": "greenchlaw-web", "version": "1.0.0"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("GREENCLAW_WEB_PORT", "18420"))
    uvicorn.run(app, host="0.0.0.0", port=port)
