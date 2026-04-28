#!/usr/bin/env bash
# GreenchClaw One-Line Installer v1.0 🌿
# curl -sL https://github.com/greench-ai/greenchlaw/raw/main/install.sh | bash
set -euo pipefail

NEXUS_VERSION="${NEXUS_VERSION:-main}"
NEXUS_DIR="${NEXUS_DIR:-$HOME/greenchlaw}"
NEXUS_CONFIG_DIR="${NEXUS_CONFIG_DIR:-$HOME/.greenchlaw}"

# Colors — green theme
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; GREEN_LIGHT='\033[92m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
step()  { echo -e "${CYAN}[STEP]${NC}  $*"; }

banner() {
  echo ""
  echo -e "${GREEN_LIGHT}   🌿  ▄▀█ █▄ █ ▀▄▀ █▀█ █▀█ ▄▀█ ${NC}"
  echo -e "${GREEN_LIGHT}  ⚡   █▀█ █▀█ █ ██ █▄█ █▄█ █▀█ ${NC}"
  echo ""
  echo -e "  ${GREEN}GreenchClaw v1.0 — Cannabis AI Agent Framework${NC}"
  echo -e "  ${GREEN}Built for SativaBox.lu & the cannabis industry${NC}"
  echo ""
}

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then echo "macos"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then echo "windows"
  elif grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then echo "wsl"
  elif [[ -f /etc/os-release ]]; then
    ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    case "$ID" in debian|ubuntu|kali) echo "debian" ;; fedora|rhel|centos) echo "rhel" ;; arch) echo "arch" ;; alpine) echo "alpine" ;; *) echo "linux" ;; esac
  else echo "linux"; fi
}

need_cmd() {
  if ! command -v "$1" &>/dev/null; then warn "Missing: $1"; return 1; fi; return 0
}

clone_or_update() {
  if [[ -d "$NEXUS_DIR/.git" ]]; then
    info "Updating GreenchClaw in $NEXUS_DIR"
    cd "$NEXUS_DIR" && git pull origin main 2>/dev/null && ok "Updated" || warn "Update failed"
  else
    step "Cloning GreenchClaw..."
    mkdir -p "$(dirname "$NEXUS_DIR")"
    git clone https://github.com/greench-ai/greenchlaw.git "$NEXUS_DIR" 2>/dev/null || {
      warn "Git clone failed — creating directory"
      mkdir -p "$NEXUS_DIR"
    }
    cd "$NEXUS_DIR"
  fi
}

install_python() {
  if need_cmd python3; then echo "python3"
  elif need_cmd python; then echo "python"
  else
    step "Python not found — please install Python 3.10+"
    exit 1
  fi
}

install_pip_packages() {
  local python=$1
  step "Installing Python packages..."
  local break_flag=""
  $python -m pip --help 2>/dev/null | grep -q "break-system-packages" && break_flag="--break-system-packages"
  $python -m pip install $break_flag --upgrade pip 2>/dev/null | tail -1
  $python -m pip install $break_flag -r "$NEXUS_DIR/requirements.txt" 2>&1 | tail -3
  ok "Python packages installed"
}

create_config() {
  mkdir -p "$NEXUS_CONFIG_DIR"
  if [[ ! -f "$NEXUS_CONFIG_DIR/config.json" ]]; then
    cat > "$NEXUS_CONFIG_DIR/config.json" <<'EOF'
{
  "version": "1.0.0",
  "name": "GreenchClaw",
  "business": "SativaBox.lu",
  "api": { "host": "0.0.0.0", "port": 8081 },
  "web": { "host": "0.0.0.0", "port": 19790 },
  "providers": {
    "openrouter": { "api_key": "" },
    "openai": { "api_key": "" },
    "anthropic": { "api_key": "" },
    "ollama": { "url": "http://localhost:11434" }
  },
  "memory": {
    "vector_db": "qdrant",
    "qdrant_url": "http://localhost:6333",
    "embedding_model": "nomic-embed-text"
  },
  "cannabis": {
    "shop_url": "https://sativabox.lu",
    "compliance_region": "luxembourg",
    "strain_db": "$NEXUS_DIR/knowledge/strains/",
    "grow_guides": "$NEXUS_DIR/knowledge/grow-guides/"
  },
  "evoclaw": { "enabled": true, "heartbeat_interval": 300 },
  "soul": { "template": "cannabis_expert" }
}
EOF
    ok "Config created at $NEXUS_CONFIG_DIR/config.json"
  fi
}

start_qdrant() {
  if curl -s http://localhost:6333/readyz &>/dev/null; then
    ok "Qdrant already running"
    return 0
  fi
  step "Starting Qdrant..."
  if command -v docker &>/dev/null; then
    docker run -d --name greenclaw-qdrant \
      -p 6333:6333 -p 6334:6334 \
      -v "$NEXUS_CONFIG_DIR/qdrant:/qdrant/storage" \
      qdrant/qdrant:latest 2>/dev/null && ok "Qdrant started" || warn "Qdrant start failed"
  else
    warn "Docker not available"
  fi
}

start_greenclaw() {
  local python=$1
  mkdir -p "$NEXUS_CONFIG_DIR/logs"
  cd "$NEXUS_DIR"
  nohup $python apps/api/main.py > "$NEXUS_CONFIG_DIR/logs/api.log" 2>&1 &
  sleep 3
  if curl -s http://localhost:8081/health &>/dev/null 2>&1; then
    ok "API started on port 8081"
  else
    err "API failed — see $NEXUS_CONFIG_DIR/logs/api.log"
  fi
  nohup $python apps/web/server.py > "$NEXUS_CONFIG_DIR/logs/web.log" 2>&1 &
  sleep 3
  if curl -s http://localhost:19790/health &>/dev/null 2>&1; then
    ok "Web UI started on port 19790"
  else
    warn "Web UI failed — see $NEXUS_CONFIG_DIR/logs/web.log"
  fi
}

print_summary() {
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo -e "  ${GREEN}✅ GreenchClaw installed!${NC}"
  echo ""
  echo -e "  🌿 Web UI:    ${GREEN}http://localhost:19790${NC}"
  echo -e "  🔗 API:       ${GREEN}http://localhost:8081${NC}"
  echo -e "  🌱 Shop:     ${GREEN}https://sativabox.lu${NC}"
  echo ""
  echo -e "  📁 Install:   $NEXUS_DIR"
  echo -e "  ⚙️  Config:   $NEXUS_CONFIG_DIR/config.json"
  echo ""
  echo -e "  ${YELLOW}Next steps:${NC}"
  echo -e "  $ python $NEXUS_DIR/src/onboard/setup.py   # Configure"
  echo -e "  $ python $NEXUS_DIR/apps/api/main.py         # Start API"
  echo -e "  $ python $NEXUS_DIR/apps/web/server.py      # Start Web UI"
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
}

main() {
  banner
  local os; os=$(detect_os)
  info "Detected OS: $os"
  clone_or_update
  local python; python=$(install_python)
  install_pip_packages "$python"
  create_config
  start_qdrant
  print_summary
}

main "$@"
