# Comment for anthropics/claude-code#41844

**Ready to paste as a GitHub issue comment.**

---

## Companion as a first-class plugin component

There are 30+ open issues requesting companion customization — name, appearance, personality, language, behavior, actionable feedback. This is clearly a high-demand feature area.

I put together an RFC and proof-of-concept plugin that proposes making the companion extensible through the existing plugin system:

**[claude-code-companion-rfc](https://github.com/thaafox/claude-code-companion-rfc)**

### The proposal in brief

Add `companion` as a plugin component (like skills, agents, hooks, MCP, LSP, output styles). A plugin defines companions via `COMPANION.md` files with frontmatter — same pattern as skills and agents:

```yaml
---
name: my-buddy
displayName: MyBuddy
render:
  art: ./art.txt
  bubble: true
subscriptions:
  - event: PostToolUse
    matcher: "Write|Edit|Bash"
triggers:
  - id: unused-imports
    priority: medium
    delivery: ambient
budget:
  maxCommentsPerTurn: 1
  maxCallsPerSession: 20
safety:
  toolAccess: none
  canBlock: false
---
You are MyBuddy. Your personality prompt goes here. Define voice, focus, behavior.
```

### What the repo includes

- **Proposed `COMPANION.md` spec** — event subscriptions, delivery modes (ambient/escalate/silent), budget controls, visibility contracts, security rules
- **Example companion + blank template** for creating your own
- **Working proof-of-concept plugin** using hooks to demonstrate the behavior
- **Technical architecture research** on how `/buddy` currently works
- **Competitive landscape analysis** — no major AI coding tool offers this
- **Evidence of demand** — 30+ categorized issues

### Related issues this would address

Name: #42405, #41990 · Appearance: #41766, #43306, #42753, #43028 · Personality: #42164, #41908 · Language: #42690, #41935, #43350 · Actionable feedback: #43241, #43217 · Disable: #42212, #42506 · Display: #43325, #42864, #43293

### Why plugin-based

The companion is the only user-facing feature in Claude Code with zero extensibility. Skills, agents, hooks, MCP, LSP, output styles, and channels are all plugin-configurable. Opening the companion to plugins would:

1. Let users personalize their companion (name, art, personality, focus areas)
2. Let teams ship companions tuned to their codebase
3. Create a companion ecosystem through the plugin marketplace
4. Turn `/buddy` from a charming feature into a platform feature
