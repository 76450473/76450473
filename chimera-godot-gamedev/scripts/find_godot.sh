#!/usr/bin/env bash
# Prints the path of a Godot 4.x executable (prefers the *console* build on Windows,
# because the GUI .exe does not write to the terminal). Exit 1 if none found.
# Usage: GODOT=$(bash scripts/find_godot.sh) && "$GODOT" --version
set -u

check() {  # $1 = candidate path/command
  local c="$1"
  [ -z "$c" ] && return 1
  if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then
    local v
    v=$("$c" --version 2>/dev/null | head -1)
    case "$v" in 4.*) echo "$c"; exit 0 ;; esac
  fi
  return 1
}

check "${GODOT_PATH:-}"
check "${GODOT:-}"
for name in godot4 godot Godot godot.exe godot4.exe; do check "$name"; done

dirs=(
  "/Applications/Godot.app/Contents/MacOS"
  "$HOME/Applications/Godot.app/Contents/MacOS"
  "$HOME/.local/bin" "/usr/local/bin" "/opt/godot" "$HOME/godot" "$HOME/Godot"
  "$HOME/Downloads" "$HOME/Desktop" "$HOME/Documents"
  "${LOCALAPPDATA:-/nonexistent}/Programs/Godot" "${LOCALAPPDATA:-/nonexistent}/Godot"
  "/c/Program Files/Godot" "/c/Godot" "/c/Tools/Godot" "$HOME/scoop/apps/godot/current"
  "/c/Program Files (x86)/Steam/steamapps/common/Godot Engine"
)
for d in "${dirs[@]}"; do
  [ -d "$d" ] || continue
  # console builds first (Windows), then any Godot 4 binary
  while IFS= read -r f; do check "$f"; done < <(
    { find "$d" -maxdepth 3 -iname 'Godot*_console.exe' 2>/dev/null
      find "$d" -maxdepth 3 \( -iname 'Godot_v4*' -o -iname 'godot*.exe' -o -name 'Godot' \) -type f 2>/dev/null; } | sort -r)
done
echo "Godot 4 not found. Install 4.7.x from https://godotengine.org/download and set GODOT_PATH." >&2
exit 1
