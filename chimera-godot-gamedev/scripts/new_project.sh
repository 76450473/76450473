#!/usr/bin/env bash
# Scaffold a new Chimera Epoch project from the skill's verified template.
#   bash new_project.sh <target_dir>
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
bash "$HERE/godot_check.sh" . || status=$?
if [ ! -d .git ]; then
  git init -q && git add -A
  git -c user.name="${GIT_AUTHOR_NAME:-chimera}" -c user.email="${GIT_AUTHOR_EMAIL:-chimera@localhost}" \
    commit -qm "chore: scaffold Chimera Epoch from skill template (M0)" && echo "git: initial commit created"
fi
exit $status
