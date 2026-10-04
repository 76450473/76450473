#!/usr/bin/env bash
# Make a game folder safe before Godot/git touch it. Users often drop everything into one
# folder: the art pack, the TXT guides, the skill zip, even the UNZIPPED skill folder.
#  - any top-level folder holding SKILL.md or a nested project.godot, and the unzipped
#    给Claude/给Codex/给GPT bundle folders and the chimera_art Codex art folder, get a .gdignore (Godot
#    skips it, so its template copy cannot clash with the project's class_names) and is added
#    to .gitignore (never committed).
#   bash prepare_root.sh <project_dir>
set -u
cd "${1:-.}" || exit 1
touch .gitignore
while IFS= read -r -d '' d; do
  name="$(basename "$d")"
  case "$name" in .*|art|art_inbox|data|docs|scenes|screenshots|src|tests|tools) continue ;; esac
  lower="$(printf '%s' "$name" | tr 'A-Z' 'a-z')"
  case "$lower" in 给claude*|给gpt*|给codex*|chimera_art*|chimera-art*) bundle=1 ;; *) bundle=0 ;; esac
  if [ $bundle = 1 ] || [ -f "$d/SKILL.md" ] || [ -f "$d/project.godot" ] || find "$d" -maxdepth 2 -name SKILL.md 2>/dev/null | grep -q .; then
    [ -f "$d/.gdignore" ] || touch "$d/.gdignore"
    grep -qxF "/$name/" .gitignore || printf '/%s/\n' "$name" >> .gitignore
    echo "prepare: '$name' is not part of the game (skill/project/bundle folder) -> ignored by Godot and git"
  fi
done < <(find . -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
exit 0
