Merge `jisho youtube sync-channels` and `jisho youtube fetch-videos` into a single `jisho youtube sync` command.

## Context

The podcast domain just unified `sync` + `sync-pocketcasts` into a single `jisho podcast sync` that runs the full pipeline (PC subscriptions → RSS feeds). YouTube should follow the same pattern.

Currently:
- `jisho youtube sync-channels` — sync subscriptions from YouTube API
- `jisho youtube fetch-videos` — fetch recent videos from channels (with subtitle detection)

These are always run together (cron runs them back-to-back). The user shouldn't need to think about them as separate steps.

## Target

`jisho youtube sync` = unified command:
1. Sync subscriptions from YouTube API (what `sync-channels` does)
2. Fetch recent videos from all channels with subtitle detection (what `fetch-videos` does)

Keep `--channel`, `--days`, `--years`, `--max-per-channel`, `--min-duration`, `--workers` flags from `fetch-videos`. Keep `--max` from `sync-channels` (rename to `--max-channels` for clarity).

Add `--skip-fetch` flag to only sync subscriptions without fetching videos (rare, but useful).

## Files to change

- `server/jisho-cli/src/cli.rs` — merge `SyncChannels` + `FetchVideos` into `Sync` variant, remove old variants
- `server/jisho-cli/src/commands/youtube.rs` — create unified `cmd_youtube_sync` that calls both steps
- `server/jisho-cli/src/main.rs` — update dispatch
- `server/jisho-cli/src/commands/cron.rs` — merge `run_youtube_sync_channels` + `run_youtube_fetch_videos` into single `run_youtube_sync` step

## Pattern to follow

Look at `server/jisho-cli/src/commands/podcast.rs` `cmd_podcast_sync()` for the reference pattern — step 1 is optional external service sync, step 2 is content refresh.

## Don't break

- The GraphQL mutations `syncYoutubeSubscriptions` and `fetchYoutubeChannelVideos` stay separate (they serve different purposes in the API)
- YouTube `auth` / `auth-status` stay unchanged
- `add` command stays unchanged (it's an E2E pipeline for a single channel)
- Cron should use the unified function
