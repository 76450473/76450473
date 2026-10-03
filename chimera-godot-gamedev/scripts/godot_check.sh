#!/usr/bin/env bash
# One-shot verification gate for a Chimera Epoch project. Run after EVERY change.
#   bash godot_check.sh <project_dir> [--shot screenshots/name.png] [--key R] [--balance]
# Steps: import -> parse-check all scripts -> unit tests -> headless smoke run of the main
# scene (fails on any SCRIPT ERROR / ERROR line) -> optional balance report -> optional screenshot.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${1:-.}"; shift || true
SHOT=""; KEY=""; BALANCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --shot) SHOT="$2"; shift 2 ;;
    --key) KEY="$2"; shift 2 ;;
    --balance) BALANCE=1; shift ;;
    *) echo "unknown arg $1"; exit 2 ;;
  esac
done
GODOT="$(bash "$HERE/find_godot.sh")" || exit 1
cd "$PROJ" || exit 1
[ -f project.godot ] || { echo "no project.godot in $PROJ"; exit 1; }
LOG="$(mktemp 2>/dev/null || echo ./.godot_check.log)"
fail=0
step() { echo; echo "== $1"; }

step "import ($("$GODOT" --version | head -1))"
"$GODOT" --headless --path . --import >"$LOG" 2>&1
grep -E "SCRIPT ERROR|Parse Error" "$LOG" | head -20

step "parse-check all scripts"
"$GODOT" --headless --path . --script res://tools/check_scripts.gd >"$LOG" 2>&1 || fail=1
grep -E "BROKEN|Parse Error|Compile Error|checked" -A1 "$LOG" | grep -v '^--' | head -40

step "unit tests"
"$GODOT" --headless --path . --script res://tests/run_tests.gd >"$LOG" 2>&1 || fail=1
grep -E "^FAIL" "$LOG" | head -40
tail -1 "$LOG"

step "smoke run main scene (120 frames, headless)"
"$GODOT" --headless --path . --quit-after 120 >"$LOG" 2>&1
if grep -qE "SCRIPT ERROR|^ERROR" "$LOG"; then
  fail=1; grep -E "SCRIPT ERROR|^ERROR" -A2 "$LOG" | head -30
else echo "clean"; fi

if [ "$BALANCE" = 1 ]; then
  step "balance (n=400, tiers 1-3)"
  for t in 1 2 3; do
    "$GODOT" --headless --path . --script res://tools/balance_sim.gd -- n=400 seed=1 tier=$t 2>&1 | grep -E "^player|CHECK" | head -6
  done
fi

if [ -n "$SHOT" ]; then
  step "screenshot -> $SHOT"
  CMD=("$GODOT" --path . --audio-driver Dummy --resolution 1600x900 --script res://tools/screenshot.gd -- res://scenes/main.tscn "$SHOT" 90 $KEY)
  if [ "$(uname -s)" = "Linux" ] && [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    if command -v xvfb-run >/dev/null; then
      xvfb-run -a -s "-screen 0 1600x900x24" "${CMD[@]}" --rendering-driver opengl3 2>&1 | grep -E "screenshot|SCRIPT ERROR" | head -5
    else echo "no display and no xvfb-run: skipping screenshot"; fi
  else
    "${CMD[@]}" 2>&1 | grep -E "screenshot|SCRIPT ERROR" | head -5
  fi
fi

echo
[ $fail = 0 ] && echo "ALL CHECKS PASSED" || echo "CHECKS FAILED"
rm -f "$LOG"
exit $fail
