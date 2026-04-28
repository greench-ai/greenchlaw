# GreenchClaw 🌿⚡
> *Your cannabis industry AI agent framework.*

A freedom-first AI agent framework built for the cannabis industry — combining NexusClaw architecture with cannabis domain expertise. Self-hostable, no lock-in, built for SativaBox.lu and the broader cannabis ecosystem.

---

## 🌿 What is GreenchClaw?

GreenchClaw is a specialized version of NexusClaw tailored for cannabis businesses:
- **Cannabis expert AI** — strain knowledge, grow guides, product expertise
- **E-commerce intelligence** — inventory, suppliers, compliance, Luxembourg regulations
- **Customer service** — chatbot for SativaBox, strain recommendations, dosage guidance
- **Internal operations** — order processing, supplier management, compliance automation

## ⚡ One-Line Install

```bash
curl -sL https://github.com/greench-ai/greenchlaw/raw/main/install.sh | bash
```

## 🌱 Built on NexusClaw

GreenchClaw is powered by the NexusClaw framework — same architecture, cannabis-tuned.

| Feature | NexusClaw | GreenchClaw |
|---------|-----------|-------------|
| Base framework | ✅ | ✅ |
| Soul | Assistant | Cannabis Expert |
| Knowledge base | General | Cannabis strains, grow guides, products |
| Skills | General | Cannabis-specific |
| UI | OpenRoom | OpenRoom + green theme |

## 🔧 Architecture

```
greenchlaw/
├── apps/
│   ├── api/          # FastAPI REST + WebSocket
│   ├── web/          # Green-themed OpenRoom UI
│   └── channels/      # Telegram + Discord (customer service)
├── src/
│   ├── providers/    # Multi-provider LLM
│   ├── memory/        # Vector + session memory
│   ├── soul/         # Cannabis expert soul
│   ├── evoclaw/      # Self-evolution
│   ├── skills/       # Cannabis-specific skills
│   └── cannabis/      # GreenchClaw-specific modules
├── skills/
│   ├── strain-guide/     # Strain database queries
│   ├── grow-advice/     # Growing tips
│   ├── product-match/    # Customer recommendations
│   ├── compliance-lux/   # Luxembourg cannabis regulations
│   └── supplier-tracker/ # Supplier inventory
├── knowledge/
│   ├── strains/          # Strain database
│   ├── grow-guides/      # Cultivation guides
│   ├── products/         # Product catalog
│   └── regulations/       # Luxembourg EU cannabis law
└── docs/
```

## 🌿 Cannabis Soul

GreenchClaw has a cannabis-expert soul trained on:
- 500+ cannabis strains (THC/CBD profiles, effects, genetics)
- Indoor/outdoor growing techniques
- Luxembourg and EU cannabis regulations
- Hemp vs cannabis product law
- Customer service for dispensaries and e-commerce

## 🛠️ Skills

| Skill | Description |
|-------|-------------|
| `strain-guide` | Query strain database, recommend based on customer needs |
| `grow-advice` | Growing tips, harvest timing, nutrient schedules |
| `product-match` | Match customer symptoms/preferences to products |
| `compliance-lux` | Check Luxembourg cannabis product compliance |
| `supplier-tracker` | Monitor supplier inventory, reorder alerts |
| `sativabox-chat` | Customer service chatbot for sativabox.lu |

## 🚀 Quick Start

```bash
# Install
curl -sL https://github.com/greench-ai/greenchlaw/raw/main/install.sh | bash

# Configure
python src/onboard/setup.py

# Start
python apps/api/main.py      # API on port 8081
python apps/web/server.py     # Web UI on port 19790
```

## 📦 Powered By

- **NexusClaw framework** — greench-ai/nexusclaw
- **OpenRouter** — Multi-model LLM access
- **Qdrant** — Vector knowledge base
- **EvoClaw** — Self-evolution

---

**GreenchClaw** — *Built for the cannabis industry. By Greench.*
**SativaBox.lu** — *Luxembourg's cannabis e-commerce.*
