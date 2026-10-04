#!/usr/bin/env bash
# Scaffold a new Chimera Epoch project from the skill's verified template, import any art
# pack the user placed in the target folder, run all checks, take the QA screenshots and
# make the first commit.
#   bash new_project.sh <target_dir>        (use "." to build inside the current folder)
# Refuses to overwrite a directory that already contains project.godot.
set -eu
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$HERE/../assets/template"
TARGET="${1:?usage: new_project.sh <target_dir>}"
if [ -f "$TARGET/project.godot" ]; then
  echo "refusing: $TARGET already has project.godot (continue that project instead)"; exit 1
fi
mkdir -p "$TARGET"
cp -R "$TEMPLATE/." "$TARGET/"
cd "$TARGET"
echo "scaffolded into $(pwd)"
bash "$HERE/prepare_root.sh" .
status=0
has_art=0
for f in ./*; do
  [ -e "$f" ] || continue
  [ -d "$f" ] && [ -f "$f/.gdignore" ] && continue
  case "$(printf '%s' "$(basename "$f")" | tr 'A-Z' 'a-z')" in
    chimera-godot-gamedev*) ;;
    *.zip|*.png|*.jpg|*.jpeg|*.webp|*.jfif|*.avif|*.heic|*.heif|*.gif|*.bmp|*.tif|*.tiff|*.psd) has_art=1 ;;
    art_inbox) ;;
    *art*|*asset*|*image*|*img*|*pic*|*美术*|*资产*|*素材*|*图片*|*图像*) [ -d "$f" ] && has_art=1 ;;
  esac
done
if [ $has_art = 1 ]; then
  echo "art pack detected -> importing"
  bash "$HERE/import_assets.sh" . || status=$?
else
  echo "no art pack found (placeholder art will be used)"
  bash "$HERE/godot_check.sh" . --shot screenshots/art_gallery.png --scene res://scenes/art_gallery.tscn || status=$?
  bash "$HERE/screenshot.sh" . res://scenes/art_parts.tscn screenshots/art_parts.png
  bash "$HERE/screenshot.sh" . res://scenes/art_images.tscn screenshots/art_images.png
  bash "$HERE/screenshot.sh" . res://scenes/art_enemies.tscn screenshots/art_enemies.png
  bash "$HERE/screenshot.sh" . res://scenes/main.tscn screenshots/main.png
  echo "next: Read screenshots/art_gallery.png, art_parts.png, art_images.png, art_enemies.png and main.png"
fi
if [ ! -d .git ]; then
  git init -q
  # repo-local identity only if the user has none, so later commits never fail on a fresh machine
  if ! git config user.name >/dev/null 2>&1 || ! git config user.email >/dev/null 2>&1; then
    git config user.name >/dev/null 2>&1 || git config user.name "${GIT_AUTHOR_NAME:-Chimera Dev}"
    git config user.email >/dev/null 2>&1 || git config user.email "${GIT_AUTHOR_EMAIL:-chimera@localhost}"
    echo "git: no identity configured -> using repo-local '$(git config user.name) <$(git config user.email)>'; the user can run git config user.name/user.email in this folder to change it"
  fi
  git add -A
  git commit -qm "chore: scaffold Chimera Epoch from skill template (M0)" && echo "git: initial commit created"
fi
exit $status
