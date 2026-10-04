#!/usr/bin/env bash
# Art studio front end: GPT image generation -> Claude's first pass -> the user's review page -> game.
#   bash art_studio.sh <workspace> <command> [args]
# Commands (full procedure: references/art-studio.md):
#   status                      what waits where, money spent, the next step
#   ping                        free key/connection check (generates nothing)
#   plan <sel>                  list + cost estimate (sends nothing)    <sel>: anchor|p1|p2|p3|all|redo|ids
#   gen <sel> [--max-usd X] [--n N] [--quality low|medium|high] [--again] [--no-ref]
#   apply                       apply Claude's verdicts in 美术资产/初审.json
#   trial                       import the picks into a throwaway copy of the game, take the QA
#                               screenshots, copy processed previews, build 美术资产/审核页面.html
#   page                        rebuild 审核页面.html only
#   serve [--no-open] [--port P] [--minutes M]   local review server; opens the user's browser;
#                               exits by itself when the user submits (run it in the BACKGROUND)
#   user-apply [--file F]       apply the user's 复审结果.json (approved originals -> 已通过/)
#   sync                        import 已通过/ + manual art packs found in the workspace into the game
# Workspace: <W>/GPTapi.txt (optional) · <W>/美术资产/ · <W>/游戏/ (or an old single-folder project).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALLER="$(pwd)"
W_ARG="${1:?usage: art_studio.sh <workspace> <command> [args]}"; shift
CMD="${1:?usage: art_studio.sh <workspace> <command> [args]}"; shift
case "$W_ARG" in /*|[A-Za-z]:*) W="$W_ARG" ;; *) W="$CALLER/$W_ARG" ;; esac
W="$(cd "$W" 2>/dev/null && pwd)" || { echo "workspace not found: $W_ARG"; exit 1; }
if [ -f "$W/游戏/project.godot" ]; then G="$W/游戏"
elif [ -f "$W/project.godot" ]; then G="$W"
else echo "no game project in $W (run: bash \"$HERE/setup_workspace.sh\" \"$W\")"; exit 1; fi
ART="$W/美术资产"
GODOT="$(bash "$HERE/find_godot.sh")" || exit 1
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }
is_img() { case "$(printf '%s' "$1" | tr 'A-Z' 'a-z')" in *.png|*.jpg|*.jpeg|*.webp|*.jfif|*.avif|*.heic|*.heif|*.gif|*.bmp|*.tif|*.tiff|*.psd) return 0 ;; esac; return 1; }

# class_name StudioCore must be registered (a project scaffolded before the studio existed, or a fresh clone)
grep -qs "StudioCore" "$G/.godot/global_script_class_cache.cfg" || "$GODOT" --headless --path "$(winpath "$G")" --import >/dev/null 2>&1

studio() {  # run tools/art_studio.gd; drop the engine banner
  "$GODOT" --headless --path "$(winpath "$G")" --script res://tools/art_studio.gd -- "$@" --ws "$(winpath "$W")" 2>&1 \
    | grep --line-buffered -v -e '^Godot Engine v' -e '^$'
  return "${PIPESTATUS[0]}"
}

case "$CMD" in
  status|ping|plan|gen|apply|page|user-apply)
    # --file <path>: relative to the folder the user ran this from (Godot runs elsewhere), Windows-style for Godot
    args=()
    while [ $# -gt 0 ]; do
      if [ "$1" = "--file" ] && [ $# -ge 2 ]; then
        case "$2" in /*|[A-Za-z]:*) f="$2" ;; *) f="$CALLER/$2" ;; esac
        args+=("--file" "$(winpath "$f")"); shift 2
      else
        args+=("$1"); shift
      fi
    done
    studio "$CMD" ${args[@]+"${args[@]}"}; exit $? ;;

  trial)
    list="$(studio trial-list | tr -d '\r')"   # Windows consoles may end lines with CRLF
    if printf '%s\n' "$list" | grep -q '^TRIAL_NONE'; then
      echo "nothing is waiting for the user's review"; studio page; exit $?
    fi
    T="$ART/.trial_project"
    [ -n "$ART" ] && [ -d "$T" ] && rm -rf -- "$T"
    mkdir -p "$T" "$ART/待复审/试装"
    # entry by entry: an old single-folder project holds 美术资产/ itself (and .trial_project inside it),
    # and the key file / .env must never land in the throwaway copy
    for e in "$G"/* "$G"/.[!.]* "$G"/..?*; do
      [ -e "$e" ] || [ -L "$e" ] || continue
      case "$(basename "$e")" in 美术资产|.git|[Gg][Pp][Tt][Aa][Pp][Ii]*|.env|.env.*|chimera-godot-gamedev*) continue ;; esac
      cp -R "$e" "$T/"
    done
    find "$T/art_inbox" -mindepth 1 -maxdepth 1 ! -name README.txt ! -name .gdignore -exec rm -rf {} + 2>/dev/null
    n=0
    while IFS=$'\t' read -r tag id path; do
      [ "$tag" = "TRIAL" ] || continue
      cp "$path" "$T/art_inbox/$id.${path##*.}" && n=$((n + 1))
    done <<< "$list"
    echo "== trial import of $n pick(s) (a throwaway copy of the game; the real game is untouched)"
    "$GODOT" --headless --path "$(winpath "$T")" --script res://tools/import_art.gd 2>&1 | grep -E '^(ok|  x|  \?|    !)'
    "$GODOT" --headless --path "$(winpath "$T")" --import >/dev/null 2>&1
    echo "== trial screenshots"
    for s in art_gallery art_parts art_images art_enemies main; do  # = SCREENS in tools/art_studio.gd
      rm -f "$T/screenshots/$s.png"
      [ -f "$T/scenes/$s.tscn" ] && bash "$HERE/screenshot.sh" "$T" "res://scenes/$s.tscn" "screenshots/$s.png" >/dev/null
      if [ -f "$T/screenshots/$s.png" ]; then cp "$T/screenshots/$s.png" "$ART/待复审/试装/$s.png"
      else rm -f "$ART/待复审/试装/$s.png"; fi
    done
    studio trial-done --trial "$(winpath "$T")"
    echo "next: Read 美术资产/待复审/试装/*.png yourself first (do the picks look right in the game?), then: bash \"$HERE/art_studio.sh\" \"$W\" serve   (run_in_background)"
    exit 0 ;;

  serve)
    [ -f "$ART/审核页面.html" ] || studio page
    exec "$GODOT" --headless --path "$(winpath "$G")" --script res://tools/review_server.gd -- --root "$(winpath "$ART")" "$@" ;;

  sync)
    out="$(studio sync-prepare | tr -d '\r')"; printf '%s\n' "$out" | grep -v '^SYNC '
    synced="$(printf '%s\n' "$out" | sed -n 's/^SYNC \([0-9]*\).*/\1/p')"
    # manual art the user dropped into the workspace: zips, image folders, loose images
    packs=()
    while IFS= read -r -d '' z; do
      case "$(basename "$z")" in chimera-godot-gamedev*) continue ;; esac
      packs+=("$z")
    done < <(find "$W" "$ART" -maxdepth 1 -type f -iname '*.zip' -print0 2>/dev/null)
    # In an old single-folder layout the workspace IS the game: its own folders (art/ above all) are
    # never a pack, or the import would move the game's art away. Anything Godot has touched (*.import,
    # scripts, scenes, resources) or the skill itself is never a pack either.
    proj_dirs=" art art_inbox screenshots data docs scenes src tests tools ui addons "
    [ -f "$W/project.godot" ] && w_is_game=1 || w_is_game=0
    while IFS= read -r -d '' d; do
      b="$(basename "$d")"
      case "$b" in 美术资产|游戏|.*|chimera-godot-gamedev*) continue ;; esac
      lb="$(printf '%s' "$b" | tr 'A-Z' 'a-z')"
      [ $w_is_game = 1 ] && case "$proj_dirs" in *" $lb "*) continue ;; esac
      [ -f "$d/.gdignore" ] && continue
      find "$d" -maxdepth 4 -type f \( -name '*.import' -o -name '*.gd' -o -name '*.tscn' -o -name '*.tres' -o -name '*.gdshader' -o -name 'project.godot' -o -name 'SKILL.md' \) 2>/dev/null | grep -q . && continue
      if find "$d" -maxdepth 4 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.jfif' \) 2>/dev/null | grep -q .; then
        packs+=("$d")
      fi
    done < <(find "$W" -mindepth 1 -maxdepth 1 -type d \( -iname '*art*' -o -iname '*asset*' -o -iname '*image*' -o -iname '*img*' -o -iname '*pic*' -o -name '*美术*' -o -name '*资产*' -o -name '*素材*' -o -name '*图片*' -o -name '*图像*' \) -print0 2>/dev/null)
    loose=0
    while IFS= read -r -d '' f; do
      if is_img "$f"; then mkdir -p "$ART/_散图" && mv "$f" "$ART/_散图/" && loose=$((loose + 1)); fi
    done < <(find "$W" "$ART" -maxdepth 1 -type f -print0 2>/dev/null)
    [ $loose -gt 0 ] && packs+=("$ART/_散图") && echo "== $loose loose image(s) collected into 美术资产/_散图/"
    pending=0
    while IFS= read -r -d '' f; do is_img "$f" && pending=$((pending + 1)); done < <(find "$G/art_inbox" -maxdepth 1 -type f -print0 2>/dev/null)
    if [ ${#packs[@]} -eq 0 ] && [ "$pending" = "0" ]; then
      echo "nothing to sync (已通过/ already imported, no art packs in the workspace)"; exit 0
    fi
    status=0
    bash "$HERE/import_assets.sh" "$G" ${packs[@]+"${packs[@]}"} || status=$?
    for p in ${packs[@]+"${packs[@]}"}; do  # never import the same pack twice
      [ -e "$p" ] || continue
      mkdir -p "$ART/_已导入的包"
      dest="$ART/_已导入的包/$(basename "$p")"; n=2
      while [ -e "$dest" ]; do dest="$ART/_已导入的包/${n}_$(basename "$p")"; n=$((n + 1)); done
      mv "$p" "$dest"
    done
    echo "SYNCED approved=${synced:-0} packs=${#packs[@]}"
    exit $status ;;

  *)
    echo "unknown command: $CMD (status|ping|plan|gen|apply|trial|page|serve|user-apply|sync)"; exit 2 ;;
esac
