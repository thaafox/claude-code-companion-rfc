# Comment for anthropics/claude-code#41844

**This is a copy of the comment posted on the issue. Keep in sync.**

---

## Companion as a first-class plugin component

There are 30+ open issues requesting companion customization — name, appearance, personality, language, behavior, actionable feedback. This is clearly a high-demand feature area.

I put together a proposal and proof-of-concept plugin for making the companion extensible through the existing plugin system:

**[claude-code-companion-rfc](https://github.com/thaafox/claude-code-companion-rfc)**

### The proposal in brief

Add `companion` as a plugin component (like skills, agents, hooks, MCP, LSP, output styles). A plugin defines companions via `COMPANION.md` files with frontmatter — same pattern as skills and agents:

```yaml
---
name: my-buddy
displayName: My Buddy
render:
  art: ./art.txt
  bubble: true
subscriptions:
  - event: PostToolUse
    matcher: "Write|Edit|Bash"
triggers:
  - id: missing-tests
    priority: high
    delivery: ambient
budget:
  maxCommentsPerTurn: 1
  maxCallsPerSession: 20
safety:
  toolAccess: none
  canBlock: false
---
Your personality goes here. How does it speak?
What does it care about? When should it shut up?
```

### How it would work for users

- **Install someone else's companion:** `claude plugin install cool-companion@marketplace`
- **Build your own:** create a `COMPANION.md` with name, art, personality, triggers
- **Just change the basics:** even a simple `companion.name` and `companion.personality` in settings.json would cover most of what people are asking for

### What the repo includes

- **Proposed `COMPANION.md` spec** with event subscriptions, delivery modes (ambient/escalate/silent), budget controls, visibility contracts, security rules
- **Working proof-of-concept plugin** with hooks that detect real patterns (hardcoded secrets, iteration loops, missing tests, scope creep)
- **Technical architecture research** on how `/buddy` actually works under the hood
- **Competitive landscape** — checked 7 major AI coding tools, none offer a customizable agent-aware companion
- **Evidence of demand** — 30+ categorized issues

### Related issues this would address

Name: #42405, #41990 · Appearance: #41766, #43306, #42753, #43028 · Personality: #42164, #41908 · Language: #42690, #41935, #43350 · Actionable feedback: #43241, #43217 · Disable: #42212, #42506 · Display: #43325, #42864, #43293

### Why plugin-based

The companion is the only user-facing feature in Claude Code with zero extensibility. Skills, agents, hooks, MCP, LSP, output styles, and channels are all plugin-configurable. Opening the companion to plugins would let users personalize their companion, let teams ship companions tuned to their codebase, and create a companion ecosystem through the marketplace.
