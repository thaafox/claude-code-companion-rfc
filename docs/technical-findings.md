# Technical Findings: How `/buddy` Works Internally

Research compiled from reverse-engineering analyses, mirrored source files, and GitHub issues.

## Architecture Overview

The companion is a **hybrid system**:

1. **Deterministic local model** for species/rarity/stats/rendering (bones)
2. **Stored "soul"** for name/personality generated at first hatch
3. **Prompt attachment** telling main Claude that a separate watcher exists
4. **Separate backend API call** for speech-bubble comments

## Comment Generation

- **Rule-based logic** decides **when** to react
- A **dedicated backend endpoint** (`/api/organizations/{org}/claude_code/buddy_react`) generates the bubble text
- A **prompt attachment** (`buddy/prompt.ts`) only coordinates coexistence with the main Claude reply — it does NOT generate comments
- The initial hatch identity uses the fast model path (Haiku 4.5 fallback)

**Sources:** [wasnotwas.com analysis](https://wasnotwas.com/writing/how-claude-code-s-buddy-works/), [buddy/prompt.ts](https://github.com/alex000kim/claude-code/blob/main/src/buddy/prompt.ts) (prompt attachment only, not the endpoint)

## Data Access

The companion sees a **constrained observation window**:

| Data | Limit |
|------|-------|
| Recent messages | Last 12 user/assistant messages |
| Message length | 300 chars per message |
| Tool output | 1000 chars |
| Total transcript | 5000 chars |
| Recent buddy reactions | Last 3, 200 chars each |
| Meta messages | Excluded |

The reaction payload includes:
- Companion identity: `name`, `personality`, `species`, `rarity`, `stats`
- Clipped `transcript`
- `reason` code (classification of why it's reacting)
- `recent` prior buddy reactions
- `addressed` boolean (user said buddy's name)

**Does NOT see:** full file diffs, raw tool-call objects, arbitrary repository state, full conversation context.

**Special hatch path:** at hatch time, sees `package.json` name/description and last 3 git commits.

## Rendering

- **Ink/React terminal UI** — `CompanionSprite.tsx` imports React, Box, Text from the Ink layer
- NOT raw escape sequences
- Source: [CompanionSprite.tsx](https://github.com/alex000kim/claude-code/blob/main/src/buddy/CompanionSprite.tsx)

## ASCII Art Format

- Stored as **in-code string arrays** in `sprites.ts`
- `BODIES: Record<Species, string[][]>` constant
- Each sprite: **5 lines tall**, **12 characters wide**
- **Multiple frames** per species for idle animation
- Line 0 is a **hat slot**
- Runtime substitution for eye characters and hat overlays
- NOT template files on disk, NOT procedurally generated

**Source:** [sprites.ts](https://github.com/alex000kim/claude-code/blob/main/src/buddy/sprites.ts)

## Identity Assignment

Deterministic from user identity, NOT random per session:

```
companionUserId() → oauthAccount.accountUuid || userID || "anon"
salt: "friend-2026-401"
hash(userId + salt) → deterministic bones
```

| Component | Source | Persistence |
|-----------|--------|-------------|
| Species | `hash(userId)` | Deterministic, regenerated each read |
| Rarity | `hash(userId)` | Deterministic |
| Stats | `hash(userId)` | Deterministic |
| Eyes | `hash(userId)` | Deterministic |
| Hat | `hash(userId)` | Deterministic |
| Shiny | `hash(userId)` | Deterministic |
| Name | Model-generated at hatch | Stored in `StoredCompanion` |
| Personality | Model-generated at hatch | Stored in `StoredCompanion` |
| hatchedAt | Timestamp | Stored in `StoredCompanion` |

Users cannot edit config to fake rarity/species — bones are always regenerated from identity hash.

**Source:** [companion.ts](https://github.com/alex000kim/claude-code/blob/main/src/buddy/companion.ts), [types.ts](https://github.com/alex000kim/claude-code/blob/main/src/buddy/types.ts)

## Existing Configuration

Only one setting exists: **`companionMuted`** (boolean).

No other companion customization is exposed through settings, plugins, or CLI flags.

## Official Statements

- **Changelog:** "/buddy is here for April 1st — hatch a small creature that watches you code" (v2.1.89)
- **No official blog post, engineering post, or roadmap item found** for companion customization
- **No Anthropic team member has commented** on any companion customization issue (as of April 4, 2026)
