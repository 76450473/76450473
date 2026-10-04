#!/usr/bin/env bash
# One-time (safe to re-run) setup of a Chimera Epoch workspace — one folder for everything:
#   <W>/GPTapi.txt   optional: the user's OpenAI key (Claude never opens it; it is never committed)
#   <W>/美术资产/     art workshop: 候选/ 待复审/ 已通过/ 淘汰/ 风格参考/ + 审核页面.html + 记录.json
#   <W>/游戏/         the Godot project (its own git repo), scaffolded from the verified template
# Then imports any art the user already put into the workspace (zip / image folder / loose images)
# and reports which art mode applies (GPT studio when GPTapi.txt exists, otherwise manual).
#   bash setup_workspace.sh [W]        (default: the current folder)
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
W="${1:-.}"
mkdir -p "$W" && cd "$W" || exit 1
W="$(pwd)"
echo "workspace: $W"
mkdir -p "美术资产/候选/_对比" "美术资产/待复审/试装" "美术资产/已通过" "美术资产/淘汰" "美术资产/风格参考"
[ -f "美术资产/.gdignore" ] || : > "美术资产/.gdignore"
[ -f "美术资产/使用说明.txt" ] || cp "$HERE/../assets/workspace/美术资产使用说明.txt" "美术资产/使用说明.txt"

# Claude Code must never read the key file (project-level deny rule; only created if absent).
# Rules are gitignore patterns: the character classes cover every capitalisation (GPTAPI.TXT, GptApi.txt...);
# the literal spellings stay as a fallback.
DENY_RULES='      "Read(./[Gg][Pp][Tt][Aa][Pp][Ii]*)",
      "Read(./游戏/[Gg][Pp][Tt][Aa][Pp][Ii]*)",
      "Read(./GPTapi*)",
      "Read(./gptapi*)",
      "Read(./Gptapi*)",
      "Read(./游戏/GPTapi*)"'
if [ ! -f .claude/settings.json ]; then
  mkdir -p .claude
  printf '{\n  "permissions": {\n    "deny": [\n%s\n    ]\n  }\n}\n' "$DENY_RULES" > .claude/settings.json
  echo "key protection: .claude/settings.json denies reading GPTapi.txt (any capitalisation)"
elif ! grep -q -e '\[Gg\]\[Pp\]\[Tt\]\[Aa\]\[Pp\]\[Ii\]' .claude/settings.json; then
  if grep -qi "gptapi" .claude/settings.json; then
    echo "note: .claude/settings.json has a GPTapi rule but not for every capitalisation (left unchanged)."
  else
    echo "note: .claude/settings.json already exists without a GPTapi rule (left unchanged)."
  fi
  echo "      Add these lines to the \"deny\" list under \"permissions\" in .claude/settings.json"
  echo "      (create \"permissions\": {\"deny\": [ ... ]} if it is missing; mind the commas between entries):"
  printf '%s\n' "$DENY_RULES"
fi
for f in ./*; do  # a key file inside the game folder would be ignored by git, but say so
  case "$(basename "$f" | tr 'A-Z' 'a-z')" in gptapi*) echo "found $(basename "$f") (the key stays local: never read, printed or committed)" ;; esac
done

status=0
if [ -f "游戏/project.godot" ]; then
  echo "game project already exists: 游戏/"
elif [ -f project.godot ]; then
  echo "old single-folder layout: the game project is this folder itself"
else
  bash "$HERE/new_project.sh" "游戏" || status=$?
fi

echo
echo "== art already in the workspace"
bash "$HERE/art_studio.sh" "$W" sync || status=$?
echo
echo "== art mode"
bash "$HERE/art_studio.sh" "$W" status
if ls "$W" 2>/dev/null | grep -qi '^gptapi'; then
  echo
  echo "== key check (free)"
  bash "$HERE/art_studio.sh" "$W" ping || true
fi
exit $status
