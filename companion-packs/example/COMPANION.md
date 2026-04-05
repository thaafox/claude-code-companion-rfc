---
name: example
displayName: Example Companion
description: Minimal example showing the COMPANION.md format.

render:
  mode: ascii
  art: ./art.txt
  sidebar: right
  bubble: true

defaults:
  activityLevel: medium
  delivery: ambient

focus:
  - code-quality

subscriptions:
  - event: PostToolUse
    matcher: "Write|Edit|Bash"
  - event: Stop

triggers:
  - id: missing-tests
    priority: high
    delivery: ambient
    cooldownSec: 900

generation:
  model: fast
  maxOutputTokens: 60

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

You are an example companion. Replace this with your own personality.
Keep it short — one paragraph that defines how you speak and what you watch for.
