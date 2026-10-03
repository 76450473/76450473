#!/usr/bin/env bash
# Scaffold a new Chimera Epoch project from the skill's verified template, import any art
# pack the user placed in the target folder, run all checks, and make the first commit.
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
status=0
has_art=0
for f in ./*; do
  case "$(printf '%s' "$f" | tr 'A-Z' 'a-z')" in
    *chimera-godot-gamedev*) ;;
    *.zip|*.png|*.jpg|*.jpeg|*.webp) has_art=1 ;;
    *art*|*asset*|*美术*|*资产*|*素材*) [ -d "$f" ] && [ "$(basename "$f")" != art_inbox ] && has_art=1 ;;
  esac
done
if [ $has_art = 1 ]; then
  echo "art pack detected -> importing"
  bash "$HERE/import_assets.sh" . || status=$?
else
  bash "$HERE/godot_check.sh" . || status=$?
fi
if [ ! -d .git ]; then
  git init -q && git add -A
  git -c user.name="${GIT_AUTHOR_NAME:-chimera}" -c user.email="${GIT_AUTHOR_EMAIL:-chimera@localhost}" \
    commit -qm "chore: scaffold Chimera Epoch from skill template (M0)" && echo "git: initial commit created"
fi
exit $status
