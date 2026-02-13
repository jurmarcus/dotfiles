---
description: "Sync Japanese vocab from Anki and display acquisition stats"
---

# Sync Japanese Vocabulary

Sync the user's Japanese vocabulary from Anki and display a formatted overview of vocab and grammar acquisition stats.

## Step 1: Sync and fetch stats

Read these 3 MCP resources in parallel:

1. `jisho://user/morph/sync` from `jisho-acquisition` — triggers the Anki sync
2. `jisho://user/vocab/stats` from `jisho-acquisition` — vocab tier breakdown
3. `jisho://user/grammar/stats` from `jisho-acquisition` — grammar tier breakdown (includes learning list)

## Step 2: Display formatted output

Parse the stats from each resource and display using Unicode box-drawing tables in this EXACT format:

```
Vocabulary — <total> words (<acquired_pct>% acquired)
┌─────────────┬────────────┬───────┬─────┬───────────────┐
│    Tier     │  Interval  │ Count │  %  │    Visual     │
├─────────────┼────────────┼───────┼─────┼───────────────┤
│ 🌱 New      │ < 7 days   │ <n>   │ <p>%│ <bar>         │
├─────────────┼────────────┼───────┼─────┼───────────────┤
│ 🌿 Young    │ 7-20 days  │ <n>   │ <p>%│ <bar>         │
├─────────────┼────────────┼───────┼─────┼───────────────┤
│ 🌳 Mature   │ 21-83 days │ <n>   │ <p>%│ <bar>         │
├─────────────┼────────────┼───────┼─────┼───────────────┤
│ 💎 Mastered │ 84+ days   │ <n>   │ <p>%│ <bar>         │
└─────────────┴────────────┴───────┴─────┴───────────────┘

- **Acquired (i)**: <mature+mastered> words (mature + mastered) — used freely in sentences
- **In progress (+1)**: <new+young> words (new + young)

---
Grammar — <total> patterns (<acquired_pct>% acquired)
┌─────────────┬────────────┬───────┬─────┬─────────────┐
│    Tier     │  Interval  │ Count │  %  │   Visual    │
├─────────────┼────────────┼───────┼─────┼─────────────┤
│ 🌱 New      │ < 7 days   │ <n>   │ <p>%│ <bar>       │
├─────────────┼────────────┼───────┼─────┼─────────────┤
│ 🌿 Young    │ 7-20 days  │ <n>   │ <p>%│ <bar>       │
├─────────────┼────────────┼───────┼─────┼─────────────┤
│ 🌳 Mature   │ 21-83 days │ <n>   │ <p>%│ <bar>       │
├─────────────┼────────────┼───────┼─────┼─────────────┤
│ 💎 Mastered │ 84+ days   │ <n>   │ <p>%│ <bar>       │
└─────────────┴────────────┴───────┴─────┴─────────────┘

- **Acquired**: <mature+mastered> patterns (mature + mastered)
- **In progress**: <new+young> patterns (new + young)

Recently learning grammar: <comma-separated list of learning grammar pattern names, max ~15>
```

### Table formatting rules

- Use Unicode box-drawing characters: `┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼ ─ │`
- Each row is separated by a horizontal rule using `├─┼─┤`
- Column widths must be consistent within each table
- Right-align Count and % columns
- Numbers use commas for thousands (e.g., 1,335)

### Visual bar column rules

The Visual column uses `█` (full block) characters as a bar chart proportional to the percentage:
- Scale: 1 block per ~3%, so 40% = ~13 blocks, 13% = ~4 blocks
- Bars should be visually proportional to each other
- Both vocab AND grammar tables get the Visual column

### Insight

After the tables, include a brief insight:

```
---
★ Insight ─────────────────────────────────────
<2-3 sentences analyzing the balance between vocab/grammar acquisition rates,
tier distribution health, and any notable observations about the pipeline>
─────────────────────────────────────────────────
```

## Important

- Do NOT include the full list of acquired/learning grammar — just the summary tables and the recently learning list
- Do NOT include proper noun stats
- Do NOT provide lengthy feedback — keep it to the concise table format with a brief insight
- Do NOT use markdown tables (`| col |`) — use Unicode box-drawing tables only
