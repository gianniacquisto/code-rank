# ADR-0002: Sitemap and SEO

## Status
Accepted

## Context
The application had two SEO gaps:
- `/sitemap.xml` returned 404 — no sitemap implemented
- `/robots.txt` was minimal (99 bytes) with no directives

## Decision
Use the `sitemap_generator` gem for sitemap generation with the following configuration:

- **Sitemap location:** `/sitemap/sitemap.xml` (uncompressed, standard approach)
- **Host:** `https://code-rank.com` (hardcoded with TODO for future configurability)
- **Content:** Root page (priority 1.0, changefreq daily) + all technology pages (priority 0.8, changefreq weekly, `lastmod` from `updated_at`)
- **Regeneration:** Daily at 2am via Solid Queue recurring job (`SitemapRefreshJob`)
- **Discovery:** `<link rel="sitemap">` tag in application layout head
- **robots.txt:** Updated with `User-agent: *`, `Allow: /`, and `Sitemap:` directive
- **Generated files:** `public/sitemap/` added to `.gitignore`

## Consequences

### Positive
- **Search engine discoverability** — all public pages are now listed in a valid sitemap
- **Automatic updates** — daily job keeps sitemap in sync without manual intervention
- **Standard format** — uncompressed `.xml` is the expected format for search engines
- **Self-contained** — everything lives in Rails via Solid Queue, no external cron needed
- **Observable** — job logs success/failure to container logs for debugging

### Negative
- **24h stale window** — new technologies won't appear in sitemap until the next daily run (acceptable tradeoff)
- **Hardcoded host** — domain is hardcoded; would need manual update if the deployment domain changes
- **No error notifications** — job failures are logged but no alerting (can add later if needed)

## Alternatives Considered

### 1. External cron job
- **Rejected:** Adds server-level dependency; Solid Queue recurring jobs keep everything in Rails

### 2. `after_commit` callback on Technology
- **Rejected:** Adds complexity (job failure handling, DB locking) for marginal gain over daily refresh

### 3. Compressed `.xml.gz`
- **Rejected:** Standard approach is uncompressed `.xml`; browsers and search engines expect it; no meaningful size savings for a small sitemap

### 4. Dynamic robots.txt via controller
- **Rejected:** Overkill; domain changes are rare infrastructure events

## Migration
No migration needed — this is a new feature. The sitemap is generated on first run and refreshed daily.
