---
name: your-companion-name
displayName: Your Companion Name
description: One line — what does your companion do?

render:
  mode: ascii
  art: ./art.txt
  sidebar: right
  bubble: true

defaults:
  activityLevel: medium    # low | medium | high
  delivery: ambient        # ambient | escalate | silent

focus:
  - your-focus-area        # what should it watch for?

subscriptions:
  - event: PostToolUse
    matcher: "Write|Edit|Bash"
  - event: Stop

triggers:
  - id: your-trigger-id
    priority: medium       # critical | high | medium | low
    delivery: ambient      # ambient | escalate | silent
    cooldownSec: 300

generation:
  model: fast
  maxOutputTokens: 80

budget:
  maxCommentsPerTurn: 1
  maxCallsPerSession: 20
  maxUsdPerSession: 0.25

visibility:
  sees: [tool_name, tool_status, changed_files, diff_summary, hook_signals]
  denies: [raw_secrets, oauth_tokens, full_conversation]

safety:
  toolAccess: none
  canBlock: false
  canEscalateToContext: true
---

Write your companion's personality here.
How does it speak? What does it care about? When should it stay quiet?
