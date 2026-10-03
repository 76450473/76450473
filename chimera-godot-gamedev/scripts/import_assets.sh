#!/usr/bin/env bash
# Import the user's art pack(s) into a Chimera Epoch project, end to end:
#   pack (zip / folder / loose images) -> art_inbox/ -> processed into art/ -> registered
#   -> coverage audit (docs/ART_TODO.md) -> full godot_check -> screenshots (gallery + main).
#   bash import_assets.sh <project_dir> [pack.zip|folder ...]
# With no pack arguments it auto-detects inside <project_dir> (top level only):
#   *.zip files (skill zips are skipped), folders whose name contains art/asset/美术/资产/素材
#   and hold images, and loose images. Processed packs move to art_inbox/_packs/ so a later
#   run never imports them twice. Images left in art_inbox/ afterwards had unknown names:
#   look at them, rename to the right asset id, and run this script again.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${1:-.}"; shift || true
GODOT="$(bash "$HERE/find_godot.sh")" || exit 1
cd "$PROJ" || exit 1
[ -f project.godot ] || { echo "no project.godot in $PROJ"; exit 1; }
ROOT="$(pwd)"
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }
is_img() { case "$(printf '%s' "$1" | tr 'A-Z' 'a-z')" in *.png|*.jpg|*.jpeg|*.webp) return 0 ;; esac; return 1; }

packs=()
if [ $# -gt 0 ]; then
  for p in "$@"; do
    if [ -e "$p" ]; then packs+=("$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"); else echo "not found: $p"; fi
  done
else
  while IFS= read -r -d '' z; do
    case "$(basename "$z")" in chimera-godot-gamedev*) continue ;; esac
    packs+=("$z")
  done < <(find "$ROOT" -maxdepth 1 -type f \( -iname '*.zip' \) -print0 2>/dev/null)
  while IFS= read -r -d '' d; do
    case "$(basename "$d")" in art|art_inbox|.godot|chimera-godot-gamedev) continue ;; esac
    if find "$d" -maxdepth 4 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | grep -q .; then
      packs+=("$d")
    fi
  done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d \( -iname '*art*' -o -iname '*asset*' -o -name '*美术*' -o -name '*资产*' -o -name '*素材*' \) -print0 2>/dev/null)
fi

echo "== register project classes"
"$GODOT" --headless --path . --import >/dev/null 2>&1
mkdir -p art_inbox

if [ ${#packs[@]} -gt 0 ]; then
  echo "== unpack ${#packs[@]} pack(s)"
  args=()
  for p in "${packs[@]}"; do echo "  $p"; args+=("$(winpath "$p")"); done
  "$GODOT" --headless --path . --script res://tools/unpack_assets.gd -- "${args[@]}" 2>&1 | grep -vE "^Godot Engine|^$"
fi
loose=0
while IFS= read -r -d '' f; do
  if is_img "$f"; then mv "$f" art_inbox/ && loose=$((loose + 1)); fi
done < <(find "$ROOT" -maxdepth 1 -type f -print0 2>/dev/null)
[ $loose -gt 0 ] && echo "== moved $loose loose image(s) into art_inbox/"

pending=$(find art_inbox -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | wc -l | tr -d ' ')
if [ "$pending" = "0" ]; then
  echo "== no images to import (art_inbox/ is empty)"
else
  echo "== process $pending image(s)"
  "$GODOT" --headless --path . --script res://tools/import_art.gd 2>&1 | grep -vE "^Godot Engine|^$|^next:"
  echo "== register new textures"
  "$GODOT" --headless --path . --import >/dev/null 2>&1
fi

for p in "${packs[@]+"${packs[@]}"}"; do
  case "$p" in "$ROOT"/*) mkdir -p art_inbox/_packs && mv "$p" art_inbox/_packs/ ;; esac
done

echo "== art coverage"
"$GODOT" --headless --path . --script res://tools/art_audit.gd 2>&1 | grep -vE "^Godot Engine|^$"
left=$(find art_inbox -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | wc -l | tr -d ' ')
[ "$left" != "0" ] && echo "!! $left image(s) still in art_inbox/ (unknown names): view them, rename to an asset id, rerun this script"

status=0
bash "$HERE/godot_check.sh" . --shot screenshots/art_gallery.png --scene res://scenes/art_gallery.tscn || status=$?
echo "== screenshot main scene"
bash "$HERE/screenshot.sh" . res://scenes/main.tscn screenshots/main.png
echo "next: Read screenshots/art_gallery.png and screenshots/main.png, then follow references/art-pipeline.md §4-§7"
exit $status
