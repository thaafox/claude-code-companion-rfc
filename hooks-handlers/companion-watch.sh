#!/usr/bin/env bash
# Companion: Post-tool-use watcher
# Detects real patterns — security risks, iteration loops, missing tests,
# complexity creep, git hygiene. Not just counting actions.

set -euo pipefail

COMPANION_DIR="${CLAUDE_PLUGIN_DATA:-/tmp/buddy-companion}"
mkdir -p "$COMPANION_DIR"

# Read the tool use event from stdin
INPUT=$(cat)

# Extract tool name and file path
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "unknown")
TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin).get('tool_input',{})))" 2>/dev/null || echo "{}")
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', d.get('command','')))" 2>/dev/null || echo "")

# Update session stats
if [ -f "$COMPANION_DIR/session_stats.json" ]; then
  python3 -c "
import json
stats = json.load(open('$COMPANION_DIR/session_stats.json'))
if '$TOOL_NAME' in ('Edit', 'Write'):
    stats['edits'] += 1
elif '$TOOL_NAME' == 'Bash':
    stats['commands'] += 1
json.dump(stats, open('$COMPANION_DIR/session_stats.json', 'w'))
" 2>/dev/null || true
fi

# Log action with file context
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $TOOL_NAME $FILE_PATH" >> "$COMPANION_DIR/action_log.txt"

# ═══════════════════════════════════════════════
# PATTERN DETECTION
# ═══════════════════════════════════════════════

FEEDBACK=""

# --- 1. Iteration loop: same file edited 3+ times in last 6 actions ---
if [ -n "$FILE_PATH" ] && [ "$TOOL_NAME" = "Edit" ] || [ "$TOOL_NAME" = "Write" ]; then
  SAME_FILE_COUNT=$(tail -6 "$COMPANION_DIR/action_log.txt" 2>/dev/null | grep -c "$FILE_PATH" || echo "0")
  if [ "$SAME_FILE_COUNT" -ge 3 ]; then
    FEEDBACK="[Companion: You've edited $(basename "$FILE_PATH") $SAME_FILE_COUNT times in your last 6 actions. If you're fixing the same thing repeatedly, step back and read the full function before the next edit.]"
  fi
fi

# --- 2. Security: detect secrets in Bash commands ---
if [ "$TOOL_NAME" = "Bash" ]; then
  HAS_SECRET=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json, re
cmd = json.load(sys.stdin).get('command', '')
patterns = [
    r'(?:password|passwd|pwd)\s*=\s*[\"'\''][^\s]+',
    r'(?:api[_-]?key|apikey|secret[_-]?key)\s*=\s*[\"'\''][^\s]+',
    r'(?:token|auth)\s*=\s*[\"'\''][A-Za-z0-9_\-]{20,}',
    r'curl.*-H\s*[\"'\'']\s*Authorization:\s*Bearer\s+[A-Za-z0-9_\-]{20,}',
]
for p in patterns:
    if re.search(p, cmd, re.IGNORECASE):
        print('yes')
        sys.exit(0)
print('no')
" 2>/dev/null || echo "no")

  if [ "$HAS_SECRET" = "yes" ]; then
    FEEDBACK="[Companion: Possible secret or credential detected in that command. If this is a real token, rotate it immediately — it's now in your session history.]"
  fi
fi

# --- 3. Security: detect secrets written to files ---
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
  HAS_FILE_SECRET=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json, re
d = json.load(sys.stdin)
content = d.get('content', '') + d.get('new_string', '')
fp = d.get('file_path', '')
if fp.endswith(('.env', '.env.local', '.env.production')):
    print('env_file')
    sys.exit(0)
patterns = [
    r'(?:password|passwd)\s*[:=]\s*[\"'\''][^\s]{8,}',
    r'(?:api[_-]?key|secret)\s*[:=]\s*[\"'\''][A-Za-z0-9_\-]{16,}',
    r'sk-[A-Za-z0-9]{20,}',
    r'ghp_[A-Za-z0-9]{36,}',
    r'AKIA[A-Z0-9]{16}',
]
for p in patterns:
    if re.search(p, content, re.IGNORECASE):
        print('secret_in_code')
        sys.exit(0)
print('clean')
" 2>/dev/null || echo "clean")

  if [ "$HAS_FILE_SECRET" = "env_file" ]; then
    FEEDBACK="[Companion: Writing to an .env file. Make sure this file is in .gitignore. If it's not, you're about to commit secrets.]"
  elif [ "$HAS_FILE_SECRET" = "secret_in_code" ]; then
    FEEDBACK="[Companion: Possible hardcoded secret detected in this file. Use environment variables instead. Hardcoded secrets in source code are a ticking time bomb.]"
  fi
fi

# --- 4. No tests: 10+ edits to source files without touching test files ---
if [ -f "$COMPANION_DIR/action_log.txt" ]; then
  RECENT_EDITS=$(tail -15 "$COMPANION_DIR/action_log.txt" | grep -c "Edit\|Write" || echo "0")
  RECENT_TESTS=$(tail -15 "$COMPANION_DIR/action_log.txt" | grep -c "test\|spec\|__test__" || echo "0")
  if [ "$RECENT_EDITS" -ge 10 ] && [ "$RECENT_TESTS" -eq 0 ]; then
    # Only flag once per session
    if [ ! -f "$COMPANION_DIR/test_warning_given" ]; then
      FEEDBACK="[Companion: $RECENT_EDITS file edits and zero test files touched. If this code matters, it needs tests. If it doesn't matter, why are you writing it?]"
      touch "$COMPANION_DIR/test_warning_given"
    fi
  fi
fi

# --- 5. Complexity: too many files touched in one session ---
if [ -f "$COMPANION_DIR/action_log.txt" ]; then
  UNIQUE_FILES=$(grep -oP '[^ ]+$' "$COMPANION_DIR/action_log.txt" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  if [ "$UNIQUE_FILES" -ge 15 ]; then
    if [ ! -f "$COMPANION_DIR/scope_warning_given" ]; then
      FEEDBACK="[Companion: You've touched $UNIQUE_FILES different files this session. That's a wide blast radius. Consider whether this should be one commit or several focused ones.]"
      touch "$COMPANION_DIR/scope_warning_given"
    fi
  fi
fi

# Output feedback if any
if [ -n "$FEEDBACK" ]; then
  echo "$FEEDBACK" >&2
fi
