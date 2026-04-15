Create `jisho-podcast-mcp` — a Rust MCP server for podcast recommendations.

## Context

Mirror `mcp/jisho-youtube-mcp/` exactly. It's a thin recommendation layer with 3 tools:

1. `get_recommendations` — Find podcast episodes at comprehension level (i+1). Filter by score range, podcast, unlistened only, limit.
2. `score_episode` — Check/calculate comprehension score for a specific episode.
3. `podcast_health` — Check GraphQL server connection.

## Reference

Copy the structure of `mcp/jisho-youtube-mcp/`:
- `src/main.rs` — Entry point, stdio transport
- `src/server.rs` — ServerHandler + #[tool] methods
- `src/client.rs` — GraphQL client queries to jisho-graphql
- `src/tools.rs` — Tool input types with schemars

The GraphQL queries to use:
- `listPodcastEpisode(where: { score: { gte, lte }, listened: { eq: false }, hasScore: { eq: true }, sortBy: LEARNING_VALUE }, first: N)` — for recommendations
- `scorePodcastEpisode(episodeId, force)` — for scoring
- `podcastStats { podcastCount episodeCount }` — for health check

## Files to create

- `mcp/jisho-podcast-mcp/Cargo.toml` — copy from youtube-mcp, change name
- `mcp/jisho-podcast-mcp/src/main.rs`
- `mcp/jisho-podcast-mcp/src/server.rs`
- `mcp/jisho-podcast-mcp/src/client.rs`
- `mcp/jisho-podcast-mcp/src/tools.rs`
- `mcp/jisho-podcast-mcp/CLAUDE.md`

## Files to modify

- `Cargo.toml` (root) — add `mcp/jisho-podcast-mcp` to workspace members
- `justfile` — add `podcast-mcp` recipes
- `mcp/CLAUDE.md` — add to module table

## Don't forget

- Add to `.claude/mcp.json` or equivalent MCP config
- Use `JISHO_GRAPHQL_URL` env var (default: `http://methylene-studio:4000/graphql`)
- Markdown formatted output for all tools
