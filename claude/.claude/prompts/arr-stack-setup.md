# Arr Stack Setup for gaen-nas

Set up the anime *arr stack on gaen-nas (UGREEN DXP6800 Pro) via SSH.

## What to do

SSH into `gaen-nas` as user `methylene` and create the full scaffolding for the anime media stack. You do NOT need sudo. You do NOT need to run docker-compose — just create the files and directories.

### 1. Create directories

```bash
ssh methylene@gaen-nas 'mkdir -p /volume1/docker/arr-stack/{jellyfin,sonarr,radarr,prowlarr,qbittorrent,bazarr,jellyseerr}'
ssh methylene@gaen-nas 'mkdir -p /volume4/videos/{downloads/complete,anime-shows,anime-movies}'
```

### 2. Write docker-compose.yml to `/volume1/docker/arr-stack/docker-compose.yml`

```yaml
services:
  # ── VPN ────────────────────────────────────────────────────
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER}
      - VPN_TYPE=${VPN_TYPE}
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES}
    ports:
      - 8080:8080

  # ── Downloads ──────────────────────────────────────────────
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    network_mode: service:gluetun
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - /volume1/docker/arr-stack/qbittorrent:/config
      - /volume4/videos/downloads:/downloads

  # ── Indexers ───────────────────────────────────────────────
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    ports:
      - 9696:9696
    volumes:
      - /volume1/docker/arr-stack/prowlarr:/config

  # ── Anime Shows ────────────────────────────────────────────
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    ports:
      - 8989:8989
    volumes:
      - /volume1/docker/arr-stack/sonarr:/config
      - /volume4/videos:/data

  # ── Anime Movies ───────────────────────────────────────────
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    ports:
      - 7878:7878
    volumes:
      - /volume1/docker/arr-stack/radarr:/config
      - /volume4/videos:/data

  # ── Subtitles ──────────────────────────────────────────────
  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    ports:
      - 6767:6767
    volumes:
      - /volume1/docker/arr-stack/bazarr:/config
      - /volume4/videos:/data

  # ── Requests ───────────────────────────────────────────────
  jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    restart: unless-stopped
    environment:
      - TZ=${TZ}
    ports:
      - 5055:5055
    volumes:
      - /volume1/docker/arr-stack/jellyseerr:/app/config

  # ── Streaming ──────────────────────────────────────────────
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    ports:
      - 8096:8096
    volumes:
      - /volume1/docker/arr-stack/jellyfin:/config
      - /volume4/videos/anime-shows:/media/anime-shows
      - /volume4/videos/anime-movies:/media/anime-movies
    devices:
      - /dev/dri:/dev/dri
```

### 3. Write .env to `/volume1/docker/arr-stack/.env`

```env
PUID=1000
PGID=1000
TZ=Asia/Tokyo

# Mullvad VPN (update WIREGUARD_PRIVATE_KEY after signing up)
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=CHANGE_ME
SERVER_COUNTRIES=Japan
```

### 4. Verify

List the created files and directories to confirm everything is in place.

## Path mapping reference

Sonarr, Radarr, qBittorrent, and Bazarr all mount `/volume4/videos` as `/data` so hardlinks work:

| Container path | Host path | Used by |
|---|---|---|
| `/data/downloads/complete` | `/volume4/videos/downloads/complete` | qBittorrent saves here |
| `/data/anime-shows` | `/volume4/videos/anime-shows` | Sonarr root folder |
| `/data/anime-movies` | `/volume4/videos/anime-movies` | Radarr root folder |

## Important

- Use `ssh methylene@gaen-nas` for all commands
- Do NOT run `docker compose up` — just create the scaffolding
- Do NOT use sudo
- Write files using `ssh methylene@gaen-nas "cat > /path/to/file << 'EOF' ... EOF"`
