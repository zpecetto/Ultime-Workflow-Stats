#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly YTDLP="${YTDLP:-/usr/local/bin/yt-dlp}"
readonly OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/Musique}"
readonly COOKIE_FILE="${COOKIE_FILE:-$SCRIPT_DIR/youtube-cookies.txt}"
readonly VIDEO_ID="${1:-}"

if [[ ! "$VIDEO_ID" =~ ^[A-Za-z0-9_-]{11}$ ]]; then
  echo "Invalid YouTube video ID: $VIDEO_ID" >&2
  exit 2
fi

if [[ ! -x "$YTDLP" ]]; then
  echo "yt-dlp is not executable: $YTDLP" >&2
  exit 3
fi

if ! command -v deno >/dev/null 2>&1; then
  echo "Deno is required by yt-dlp." >&2
  exit 4
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to convert audio to MP3." >&2
  exit 5
fi

mkdir -p "$OUTPUT_DIR"
COOKIE_ARGS=()
if [[ -s "$COOKIE_FILE" ]]; then
  COOKIE_ARGS=(--cookies "$COOKIE_FILE")
else
  echo "Warning: YouTube cookies not found; age-restricted videos may fail." >&2
fi

exec "$YTDLP" \
  --no-playlist \
  --no-simulate \
  --js-runtimes "deno:$(command -v deno)" \
  --remote-components ejs:github \
  "${COOKIE_ARGS[@]}" \
  --format "bestaudio/best" \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
  --print 'after_move:N8N_FILE:%(filepath)j' \
  -- \
  "https://www.youtube.com/watch?v=$VIDEO_ID"
