# Let us customize our `/buddy` companions

You hatched your companion. You like it. But you can't change its name. Can't change how it looks. Can't change what it says or what it pays attention to. The only setting is a mute button.

**35+ people have asked for this and new requests are still coming in a week later.** ([full list](docs/evidence-of-demand.md))

This repo is a proposal to make the companion customizable through the plugin system — the same way skills, agents, hooks, and everything else in Claude Code already works.

If you want this, star the repo and upvote [#41844](https://github.com/anthropics/claude-code/issues/41844).

---

## The idea

Right now everyone gets a random companion they can't change:

```
                                          ─     /\_/\
                                              (  +  +)
  *you're editing auth.ts*                    (  ω  )
                                             (")_(")~
                                               Tuft
```

What if you could define your own?

```
  *3 unused imports in auth.ts*             ╔═══╗
                                            ║ > ║
  "3 unused imports.                        ╠═══╣
  1 function with no callers."              ║ ▪ ║
                                            ╚═╤═╝
                                              │
                                          YourBuddy
```

Your name. Your art. Your personality. Your rules for when it speaks.

---

## How would this actually work?

### Today (what you're stuck with)

1. Run `/buddy`
2. Claude picks a random name, species, and personality based on your account
3. A companion appears in your sidebar
4. You can pet it. You can mute it. That's it. No other options.

### With this proposal

**Option A: Install someone else's companion from the marketplace**

```bash
claude plugin install cool-companion@marketplace
```

Done. Their companion replaces your default. Don't like it? Uninstall and try another one, or go back to your original.

**Option B: Build your own from scratch**

1. Create a folder with two files:

```
my-companion/
├── COMPANION.md    <- personality, triggers, rules
└── art.txt         <- your ASCII art
```

2. Write who your companion is in `COMPANION.md` (what it watches for, how it talks, when it shuts up)

3. Load it:
```bash
claude --plugin-dir ./my-companion
```

4. Your companion shows up in the sidebar instead of the default one. Your name. Your art. Your voice.

**Option C: Just change the name and personality, keep everything else**

If Anthropic adds even basic settings support:

```json
// ~/.claude/settings.json
{
  "companion": {
    "name": "whatever you want",
    "personality": "talks like a pirate, only comments on security issues"
  }
}
```

That alone would cover what most of those 30+ issues are asking for.

---

## The full spec (for plugin developers)

For people who want to build and share companion plugins, the `COMPANION.md` format looks like this:

```yaml
---
name: my-companion
displayName: My Companion
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

Then in settings:

```json
{
  "companion": {
    "active": "my-plugin:my-companion"
  }
}
```

That's it. One companion active at a time, same as output styles.

---

## What's in this repo

**The proposal:**
- [Technical findings](docs/technical-findings.md) — how `/buddy` actually works under the hood (the backend endpoint, the data it sees, how identity is assigned)
- [Competitive landscape](docs/competitive-landscape.md) — checked 7 major AI coding tools. None of them have this.
- [Evidence of demand](docs/evidence-of-demand.md) — 30+ issues categorized by what people are asking for
- [Proposed COMPANION.md spec](companion-packs/example/COMPANION.md) — event subscriptions, delivery modes, budget controls, security rules

**A working proof-of-concept plugin:**
- Hooks that detect real patterns (hardcoded secrets, iteration loops, missing tests, scope creep)
- A `/companion` command for on-demand session review
- A `companion-review` agent for deep code review

**A template to make your own:**
- [companion-packs/template/](companion-packs/template/) — blank `COMPANION.md` ready to fill in

### Try the PoC

```bash
claude --plugin-dir /path/to/claude-code-companion-rfc
```

---

## Why this matters

The companion is the only user-facing feature in Claude Code with zero extensibility. Everything else — skills, agents, hooks, MCP, LSP, output styles, channels — is plugin-configurable.

Opening the companion to plugins means:
- You name it. You design it. You write its personality.
- Teams ship companions tuned to their codebase.
- Community packs show up on the marketplace.

---

## The ask

1. Star this repo if you want customizable companions
2. Upvote [anthropics/claude-code#41844](https://github.com/anthropics/claude-code/issues/41844)
3. [Make your own companion](companion-packs/template/) and open a PR

## License

MIT
