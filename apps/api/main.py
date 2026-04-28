"""
GreenchClaw API Server v1.0
FastAPI — REST + WebSocket, JWT auth, chat, cannabis knowledge, skills.
Port: 8081 (different from NexusClaw's 8080)
"""
from __future__ import annotations
import os, sys, json, uuid, asyncio, logging
from pathlib import Path
from datetime import datetime
from typing import Optional
from concurrent.futures import ThreadPoolExecutor

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import jwt, bcrypt

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT))

logging.basicConfig(level=logging.INFO, format="[%(asctime)s] %(message)s")
log = logging.getLogger("greenchlaw.api")

app = FastAPI(title="GreenchClaw API", version="1.0.0", description="Cannabis industry AI agent")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

CONFIG_PATH = Path(os.environ.get("GREENCLAW_CONFIG", str(Path.home() / ".greenchlaw" / "config.json")))
users_db, sessions_db, connections = {}, {}, {}
_executor = ThreadPoolExecutor(max_workers=4)

def load_config():
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text())
    return {"api": {"port": 8081, "secret": "greenchlaw-dev"}, "providers": {}}

# ─── Auth ────────────────────────────────────────────────────────────────────
def _secret(): return load_config()["api"].get("secret", "greenchlaw-dev")
def create_token(uid: str) -> str:
    return jwt.encode({"sub": uid, "exp": datetime.utcnow().timestamp() + 86400}, _secret(), algorithm="HS256")
def verify_token(t: str) -> Optional[str]:
    try: return jwt.decode(t, _secret(), algorithms=["HS256"]).get("sub")
    except: return None

# ─── Pydantic Models ───────────────────────────────────────────────────────────
class ChatReq(BaseModel):
    message: str
    provider: str = "openrouter"
    model: str = "qwen/qwen3.5-plus"
    session_id: Optional[str] = None
    use_rag: bool = True
    stream: bool = False

# ─── Health ───────────────────────────────────────────────────────────────────
@app.get("/health")
async def health():
    return {"status": "ok", "service": "greenchlaw", "version": "1.0.0", "shop": "sativabox.lu"}

# ─── Auth Routes ───────────────────────────────────────────────────────────────
@app.post("/auth/register")
async def register(email: str, password: str, display_name: str = "Cannabis Expert"):
    if email in users_db: raise HTTPException(400, "Email taken")
    uid = str(uuid.uuid4())
    users_db[uid] = {"id": uid, "email": email, "name": display_name, "password": bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()}
    return {"token": create_token(uid), "user": {"id": uid, "email": email, "name": display_name}}

# ─── Chat ─────────────────────────────────────────────────────────────────────
@app.post("/chat")
async def chat(body: ChatReq):
    cfg = load_config()
    streamer = PROVIDER_STREAMERS.get(body.provider)
    if not streamer: raise HTTPException(400, f"Unknown provider: {body.provider}")

    api_key = cfg.get("providers", {}).get(body.provider, {}).get("api_key", "")
    soul = _load_soul()
    messages = [{"role": "system", "content": soul}, *[m for m in _get_messages(body.session_id)], {"role": "user", "content": body.message}]

    if body.use_rag:
        context = await _rag_query(body.message)
        if context:
            messages[0]["content"] = soul + f"\n\n[Context]\n{context}"

    full = ""
    async for token in streamer(messages, body.model, api_key, cfg):
        full += token

    _save_message(body.session_id, "user", body.message)
    _save_message(body.session_id, "assistant", full)
    return {"response": full, "session_id": body.session_id or "new"}

def _load_soul() -> str:
    soul_path = ROOT / "src" / "soul" / "cannabis_expert.md"
    if soul_path.exists():
        return soul_path.read_text()
    return "You are GreenchClaw, a cannabis industry AI assistant for SativaBox.lu."

def _get_messages(sid: Optional[str]) -> list:
    return sessions_db.get(sid or "", {}).get("messages", [])

def _save_message(sid: Optional[str], role: str, content: str):
    if not sid: sid = str(uuid.uuid4())
    if sid not in sessions_db: sessions_db[sid] = {"id": sid, "messages": [], "title": content[:40]}
    sessions_db[sid]["messages"].append({"role": role, "content": content, "ts": datetime.utcnow().isoformat()})

async def _rag_query(query: str) -> str:
    try:
        from src.memory.vector_store import VectorStore
        cfg = load_config()
        store = VectorStore(cfg.get("memory", {}).get("qdrant_url", "http://localhost:6333"))
        results = await asyncio.get_event_loop().run_in_executor(_executor, lambda: store.search(query, top_k=5, workspace="greenchlaw"))
        return "\n".join([f"[{r['score']:.2f}] {r['text'][:200]}" for r in results]) if results else ""
    except: return ""

# ─── Provider streamers ────────────────────────────────────────────────────────
async def _stream_openrouter(messages, model, api_key, cfg):
    try:
        from openai import AsyncOpenAI
        client = AsyncOpenAI(base_url="https://openrouter.ai/api/v1", api_key=api_key or os.environ.get("OPENROUTER_API_KEY",""))
        stream = await client.chat.completions.create(model=model or "qwen/qwen3.5-plus", messages=messages, stream=True, temperature=0.7)
        async for chunk in stream:
            if chunk.choices and (d := chunk.choices[0].delta.content): yield d
    except Exception as e: yield f"[Error: {e}]"

PROVIDER_STREAMERS = {"openrouter": _stream_openrouter}

# ─── WebSocket ────────────────────────────────────────────────────────────────
@app.websocket("/ws/{session_id}")
async def ws_chat(ws: WebSocket, session_id: str):
    await ws.accept()
    try:
        while True:
            data = await ws.receive_text()
            req = json.loads(data)
            # Broadcast to others in session
            for c in connections.get(session_id, []):
                if c != ws:
                    await c.send_json({"type": "message", "data": req})
    except WebSocketDisconnect: pass

if __name__ == "__main__":
    import uvicorn
    port = load_config().get("api", {}).get("port", 8081)
    uvicorn.run(app, host="0.0.0.0", port=port, log_level="info")
