#!/usr/bin/env bash
# Import the user's art pack(s) into a Chimera Epoch project, end to end:
#   pack (zip / folder / loose images) -> art_inbox/ -> processed into art/ -> registered
#   -> coverage audit (docs/ART_TODO.md) -> full godot_check -> screenshots of the 3 art QA
#   pages + the main scene.
#   bash import_assets.sh <project_dir> [pack.zip|folder ...]
# Pack paths may be absolute or relative to the folder you run this from.
# With no pack arguments it auto-detects inside <project_dir> (top level only):
#   *.zip files (skill zips are skipped), folders whose name contains art/asset/美术/资产/素材
#   and hold images, and loose images. Processed packs move to art_inbox/_packs/ so a later
#   run never imports them twice.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALLER="$(pwd)"
PROJ="${1:-.}"; shift || true
GODOT="$(bash "$HERE/find_godot.sh")" || exit 1
packs=()
for p in "$@"; do  # resolve relative to the caller, BEFORE changing directory
  case "$p" in /*|[A-Za-z]:*) abs="$p" ;; *) abs="$CALLER/$p" ;; esac
  if [ -e "$abs" ]; then packs+=("$(cd "$(dirname "$abs")" && pwd)/$(basename "$abs")")
  else echo "ERROR: pack not found: $p"; exit 1; fi
done
cd "$PROJ" || exit 1
[ -f project.godot ] || { echo "no project.godot in $PROJ"; exit 1; }
ROOT="$(pwd)"
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }
is_img() { case "$(printf '%s' "$1" | tr 'A-Z' 'a-z')" in *.png|*.jpg|*.jpeg|*.webp|*.jfif|*.avif|*.heic|*.heif|*.gif|*.bmp|*.tif|*.tiff) return 0 ;; esac; return 1; }
# Godot prints one "Unicode parsing error" (+ an "at:" line) per bad byte of a GBK zip entry
# name, many times per entry. Collapse that noise into a single count.
quiet() {
  awk '/Unicode parsing error/ {n++; skip=1; next}
       skip && /^[[:space:]]+at: / {skip=0; next}
       /^Godot Engine/ || /^[[:space:]]*$/ {skip=0; next}
       {skip=0; print}
       END {if (n) printf "  (suppressed %d non-UTF-8 filename warnings)\n", n}'
}

bash "$HERE/prepare_root.sh" .
if [ ${#packs[@]} -eq 0 ]; then
  while IFS= read -r -d '' z; do
    case "$(basename "$z")" in chimera-godot-gamedev*) continue ;; esac
    packs+=("$z")
  done < <(find "$ROOT" -maxdepth 1 -type f -iname '*.zip' -print0 2>/dev/null)
  while IFS= read -r -d '' d; do
    case "$(basename "$d")" in art|art_inbox|.godot|chimera-godot-gamedev*) continue ;; esac
    [ -f "$d/.gdignore" ] && continue
    if find "$d" -maxdepth 4 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.jfif' \) 2>/dev/null | grep -q .; then
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
  unpack_out="$("$GODOT" --headless --path . --script res://tools/unpack_assets.gd -- "${args[@]}" 2>&1 | quiet)"
  printf '%s\n' "$unpack_out"
fi
loose=0
while IFS= read -r -d '' f; do
  if is_img "$f"; then mv "$f" art_inbox/ && loose=$((loose + 1)); fi
done < <(find "$ROOT" -maxdepth 1 -type f -print0 2>/dev/null)
[ $loose -gt 0 ] && echo "== moved $loose loose image(s) into art_inbox/"

summary=""
pending=0
while IFS= read -r -d '' f; do is_img "$f" && pending=$((pending + 1)); done < <(find art_inbox -maxdepth 1 -type f -print0)
if [ "$pending" = "0" ]; then
  echo "== no new images in art_inbox/"
else
  echo "== process $pending image(s)"
  out="$("$GODOT" --headless --path . --script res://tools/import_art.gd 2>&1 | quiet)"
  printf '%s\n' "$out" | grep -v '^next:'
  summary="$(printf '%s\n' "$out" | grep '^summary:' | tail -1)"
  echo "== register new textures"
  "$GODOT" --headless --path . --import >/dev/null 2>&1
fi

for p in ${packs[@]+"${packs[@]}"}; do
  case "$p" in
    "$ROOT"/*)
      mkdir -p art_inbox/_packs
      dest="art_inbox/_packs/$(basename "$p")"
      if [ -e "$dest" ]; then
        n=2; while [ -e "art_inbox/_packs/${n}_$(basename "$p")" ]; do n=$((n + 1)); done
        dest="art_inbox/_packs/${n}_$(basename "$p")"
      fi
      mv "$p" "$dest" ;;
  esac
done

echo "== art coverage"
"$GODOT" --headless --path . --script res://tools/art_audit.gd 2>&1 | quiet
unknown=$(printf '%s' "$summary" | sed -n 's/.*unknown=\([0-9]*\).*/\1/p')
failed=$(printf '%s' "$summary" | sed -n 's/.*failed=\([0-9]*\).*/\1/p')
[ "${unknown:-0}" != "0" ] && echo "!! $unknown image(s) have unknown names (lines starting with '?'): Read each, rename to an asset id inside art_inbox/, then rerun WITHOUT pack arguments: bash \"$HERE/import_assets.sh\" \"$ROOT\""
[ "${failed:-0}" != "0" ] && echo "!! $failed image(s) could not be used (lines starting with 'x': unreadable or unsupported format such as avif/heic): ask the user to re-export them as PNG"
printf '%s\n' "${unpack_out:-}" | grep -q "credits.txt 不是 UTF-8" && echo "!! credits.txt was not UTF-8: tell the user to re-save it as UTF-8 (these images are credited as '工具待补')"
printf '%s\n' "${unpack_out:-}" | grep -q "跳过不支持的图片格式" && echo "!! some files in the pack were skipped (unsupported format, see '! 跳过' lines): ask the user for PNG versions"

status=0
bash "$HERE/godot_check.sh" . --shot screenshots/art_gallery.png --scene res://scenes/art_gallery.tscn || status=$?
echo "== screenshots"
bash "$HERE/screenshot.sh" . res://scenes/art_parts.tscn screenshots/art_parts.png
bash "$HERE/screenshot.sh" . res://scenes/art_images.tscn screenshots/art_images.png
bash "$HERE/screenshot.sh" . res://scenes/main.tscn screenshots/main.png
echo "next: Read screenshots/art_gallery.png, art_parts.png, art_images.png and main.png, then follow references/art-pipeline.md §4-§7"
exit $status
