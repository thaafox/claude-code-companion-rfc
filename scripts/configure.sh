#!/usr/bin/env bash
# Companion: Quick configuration script
# Usage: ./configure.sh [name] [voice] [focus]
# Example: ./configure.sh "MyCompanion" "direct, concise" "code-quality,testing"

set -euo pipefail

COMPANION_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/buddy-companion}"
mkdir -p "$COMPANION_DIR"

NAME="${1:-Companion}"
VOICE="${2:-direct, no fluff, tactical}"
FOCUS="${3:-code-quality,security,efficiency}"

# Convert comma-separated focus to JSON array
FOCUS_JSON=$(echo "$FOCUS" | python3 -c "
import sys
items = sys.stdin.read().strip().split(',')
import json
print(json.dumps([i.strip() for i in items]))
")

cat > "$COMPANION_DIR/config.json" << EOF
{
  "name": "$NAME",
  "voice": "$VOICE",
  "focus": $FOCUS_JSON,
  "catchphrase": "",
  "configured_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Companion configured:"
echo "  Name:  $NAME"
echo "  Voice: $VOICE"
echo "  Focus: $FOCUS"
echo ""
echo "Config saved to: $COMPANION_DIR/config.json"
