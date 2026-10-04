#!/usr/bin/env bash
# Prints the path of a Godot 4.x executable (prefers the *console* build on Windows,
# because the GUI .exe does not write to the terminal). Exit 1 if none found.
# Usage: GODOT=$(bash scripts/find_godot.sh) && "$GODOT" --version
set -u

check() {  # $1 = candidate path/command
  local c="$1"
  [ -z "$c" ] && return 1
  case "$c" in  # Windows-style path from GODOT_PATH (C:\Godot\...) -> /c/Godot/... in Git Bash
    [A-Za-z]:\\*|[A-Za-z]:/*|*\\*) command -v cygpath >/dev/null 2>&1 && c="$(cygpath -u "$c")" ;;
  esac
  if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then
    local v
    v=$("$c" --version 2>/dev/null | head -1)
    case "$v" in
      4.*) case "$v" in 4.[0-6].*) echo "warning: Godot $v found; this project targets 4.7.x" >&2 ;; esac
           echo "$c"; exit 0 ;;
    esac
  fi
  return 1
}

check "${GODOT_PATH:-}"
check "${GODOT:-}"
for name in godot4 godot Godot godot.exe godot4.exe; do check "$name"; done

dirs=(
  "/Applications" "$HOME/Applications"
  "/Applications/Godot.app/Contents/MacOS" "$HOME/Applications/Godot.app/Contents/MacOS"
  "$HOME/.local/bin" "/usr/local/bin" "/opt/godot" "$HOME/godot" "$HOME/Godot"
  "$HOME/Downloads" "$HOME/Desktop" "$HOME/Documents"
  "${LOCALAPPDATA:-/nonexistent}/Programs/Godot" "${LOCALAPPDATA:-/nonexistent}/Godot"
  "/c/Program Files/Godot" "/c/Godot" "/c/Tools/Godot" "/d/Godot" "$HOME/scoop/apps/godot/current"
  "/c/Program Files (x86)/Steam/steamapps/common/Godot Engine"
)
for d in "${dirs[@]}"; do
  [ -d "$d" ] || continue
  # 1) Windows console builds first
  while IFS= read -r f; do check "$f"; done < <(
    find "$d" -maxdepth 4 -iname 'Godot*_console.exe' -type f 2>/dev/null | LC_ALL=C sort -r)
  # 2) any other Godot 4 binary (newest-looking name first)
  while IFS= read -r f; do check "$f"; done < <(
    find "$d" -maxdepth 4 \( -iname 'Godot_v4*' -o -iname 'godot*.exe' -o -name 'Godot' -o -name 'godot' -o -name 'godot4' \) \
      -type f 2>/dev/null | LC_ALL=C sort -r)
done
echo "Godot 4 not found. Install 4.7.x from https://godotengine.org/download and set GODOT_PATH." >&2
exit 1
