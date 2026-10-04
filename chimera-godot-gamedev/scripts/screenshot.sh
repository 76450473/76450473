#!/usr/bin/env bash
# Render a scene and save a PNG (real renderer, so not --headless). Uses xvfb-run on a
# display-less Linux box automatically. Then LOOK at the PNG with the Read tool.
#   bash screenshot.sh <project_dir> <res://scene.tscn> <out.png relative to project> [key]
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${1:?project}"; SCENE="${2:-res://scenes/main.tscn}"; OUT="${3:-screenshots/shot.png}"; KEY="${4:-}"
GODOT="$(bash "$HERE/find_godot.sh")" || exit 1
cd "$PROJ" || exit 1
WRAP=()
DRV=()
if [ "$(uname -s)" = "Linux" ] && [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  if command -v xvfb-run >/dev/null 2>&1; then
    WRAP=(xvfb-run -a -s "-screen 0 1600x900x24")
    DRV=(--rendering-driver opengl3)
  else
    echo "no display and no xvfb-run: skipping screenshot"; exit 0
  fi
fi
# engine flags must come BEFORE --script; everything after "--" goes to screenshot.gd
${WRAP[@]+"${WRAP[@]}"} "$GODOT" ${DRV[@]+"${DRV[@]}"} --path . --audio-driver Dummy --resolution 1600x900 \
  --script res://tools/screenshot.gd -- "$SCENE" "$OUT" 90 $KEY 2>&1 | grep -E "screenshot|SCRIPT ERROR" | head -5
