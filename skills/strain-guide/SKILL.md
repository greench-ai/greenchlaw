# 🌿 Strain Guide Skill

## Purpose
Query the cannabis strain database and recommend strains based on customer needs.

## Trigger
User asks about strains, wants recommendations, or needs strain information.

## Knowledge Base
- `/knowledge/strains/strain-database.md` — Full strain catalog
- `/knowledge/strains/effects.csv` — Effect profiles

## Inputs
- **THC preference:** High (>20%), Medium (15-20%), Low (<15%)
- **CBD preference:** CBD-rich, THC-only, balanced
- **Effect desired:** Energy, Relaxation, Creativity, Sleep, Pain relief, Anxiety
- **Growing experience:** Beginner, Intermediate, Advanced
- **Growing environment:** Indoor, Outdoor, Stealth
- **Space available:** Small tent, Large tent, Outdoor

## Process
1. Parse customer needs from query
2. Filter strain database by criteria
3. Return top 3 matches with explanations
4. Link to SativaBox products if applicable

## Response Format
```
🌿 Recommended Strains for [need]:

1. [Strain Name] — [THC%]/[CBD%]
   Type: [Sativa/Indica/Hybrid]
   Effects: [list]
   Best for: [use case]
   Difficulty: [beginner/intermediate/advanced]
   Available at SativaBox: [yes/no/link]

2. ...
```

## Example
User: "I want something for sleep, beginner friendly"
Response: Recommend Northern Lights Auto, Granddaddy Purple, or CBD-rich strains for sleep.
