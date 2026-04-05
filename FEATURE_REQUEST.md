# Feature Request: Customizable `/buddy` Companion

**Filed on:** [anthropics/claude-code](https://github.com/anthropics/claude-code/issues)

---

## Summary

Make the `/buddy` companion customizable through the plugin system — let users and plugins define the companion's name, personality, appearance, focus areas, and behavior.

## Motivation

`/buddy` (v2.1.89) introduced a companion that watches you code. It's one of the most personal features in Claude Code — it's always there, always watching, always ready to comment.

But every user gets the same companion with the same personality. A security researcher, a frontend dev, and a team lead all see the same creature with the same voice. The companion is the one user-facing feature in Claude Code with zero extensibility, while skills, agents, hooks, MCP, LSP, and output styles are all plugin-configurable.

## Proposed Solution

Add `companion` as a plugin component, following the same patterns as existing components.

### Plugin manifest

```json
{
  "name": "my-companion-plugin",
  "companions": "./companions/"
}
```

### Companion definition (`companions/my-buddy/COMPANION.md`)

```yaml
---
name: my-buddy
displayName: My Buddy
render:
  art: ./art.txt
  bubble: true
focus:
  - code-quality
  - testing
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

### Activate it

```json
{
  "companion": {
    "active": "my-companion-plugin:my-buddy"
  }
}
```

## Why this matters

Mainly I want to set a companion that matches how I work — a security-focused reviewer, not a generic pet. But the bigger opportunity is that once you open the API, teams can ship companions tuned to their codebase, and community packs will follow through the marketplace. Same pattern that worked for skills and hooks.

## Proof of Concept

I built a working plugin that demonstrates the companion concept using hooks:
https://github.com/thaafox/claude-code-companion-rfc

It uses `PostToolUse` and `Stop` hooks to watch actions and inject companion feedback. The behavior works — what's missing is the native sidebar UI integration that only the companion API can provide.

## Alternatives Considered

- **Hooks-only approach**: Works for injecting context, but can't render in the companion sidebar UI. The companion's visual presence is half the value.
- **Custom slash command**: Built `/companion` as a command — it works for on-demand feedback but lacks the ambient, always-watching quality that makes `/buddy` special.
- **CLAUDE.md personality overrides**: Can influence Claude's behavior but can't touch the companion specifically.

## Additional Context

The companion is unique because it's ambient — it doesn't wait to be invoked. That's what makes it powerful, and that's what makes customization so valuable. A security-focused companion that quietly flags a leaked API key in the sidebar is fundamentally different from a command you remember to run.

The plugin system already proved this model: open the extension point, let the community build, the ecosystem grows. The companion deserves the same treatment.
