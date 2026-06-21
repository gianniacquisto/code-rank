# ADR-0001: Star System

## Status
Accepted

## Context
The original codebase used a `Vote` model with an integer column (`-1`, `0`, `1`) to let users rate technologies. This was causing two problems:

1. **Negative votes** (`-1`) could create a hostile environment in the community
2. **Terminology mismatch** — "vote" and "rating" don't match the domain of ranking open source projects

## Decision
Replace the vote system with a GitHub-style star system:

- **Model:** `Vote` → `Star` (boolean `starred` column)
- **Table:** `votes` → `stars`
- **Controller:** `VotesController` → `StarsController`
- **Routes:** Nested under technologies (`POST /technologies/:id/stars`, `DELETE /technologies/:id/stars/unstar`)
- **UI:** Star icon (outline/filled) + count, aligned right of technology name
- **Interaction:** Full page redirect on star/unstar (no Turbo Stream)

## Consequences

### Positive
- **No negativity** — users can only star or not star, no downvotes
- **Domain alignment** — "star" is the universal open source metaphor (GitHub, GitLab)
- **Simple** — no Turbo Stream, no partials, no complex JS. Just save and redirect.
- **Data preserved** — existing votes migrated to stars

### Negative
- **Loss of nuance** — can't express "I dislike this" (but that's intentional)
- **Full page reload** — star/unstar causes a redirect instead of partial update (acceptable for low-frequency action)

## Alternatives Considered

### 1. Keep Vote model, make it boolean
- **Rejected:** Mixing metaphors (Vote model with boolean doesn't make sense)

### 2. Turbo Stream for star/unstar
- **Rejected:** Database reads aren't expensive on this scale, star/unstar is infrequent, adds complexity for no real benefit

### 3. Star button as a separate row
- **Rejected:** GitHub's inline layout (name left, star + count right) is more compact and familiar

## Migration
The migration creates a new `stars` table, copies data (`vote=1` → `starred=true`), then drops the old `votes` table. Full rollback is supported.
