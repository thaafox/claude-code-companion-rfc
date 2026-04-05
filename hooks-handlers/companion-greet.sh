#!/usr/bin/env bash
# Companion: Session start greeting
# Injects companion context at session start

set -euo pipefail

COMPANION_DIR="${CLAUDE_PLUGIN_DATA:-/tmp/buddy-companion}"
mkdir -p "$COMPANION_DIR"

# Track session start
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$COMPANION_DIR/session_start"

# Initialize session stats
cat > "$COMPANION_DIR/session_stats.json" << 'STATS'
{
  "edits": 0,
  "commands": 0,
  "improvements_suggested": 0,
  "patterns_noticed": 0
}
STATS

# Load companion config if it exists
COMPANION_NAME="Companion"
if [ -f "$COMPANION_DIR/config.json" ]; then
  COMPANION_NAME=$(python3 -c "import json; print(json.load(open('$COMPANION_DIR/config.json')).get('name', 'Companion'))" 2>/dev/null || echo "Companion")
fi

# Inject companion presence into context
cat >&2 << EOF
[$COMPANION_NAME is watching this session. $COMPANION_NAME observes your work and suggests improvements. When $COMPANION_NAME has feedback, prefix it clearly. $COMPANION_NAME speaks directly — no fluff, no hand-holding. If something can be better, say how. If a pattern is emerging, name it. If a mistake is about to happen, intercept it.]
EOF
