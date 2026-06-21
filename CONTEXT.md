# Code Rank — Project Context

## What is this?
A Ruby on Rails 8 app for ranking and reviewing open source software. Built in the open to demystify web app development.

## Tech Stack
- **Rails 8.1.1** / **Ruby 3.4.5**
- **SQLite3** (separate files for main DB, cache, queue, cable)
- **Hotwire** (Turbo + Stimulus) via Importmap
- **Puma** + **Thruster** (Rust HTTP accelerator)
- **Solid Queue / Solid Cache / Solid Cable** (Basecamp's modern Rails backends)
- **Kamal** for Docker deployment

---

## Production Deployment

### Server
- **IP**: `116.203.97.159` (Hetzner VPS)
- **Domain**: `code-rank.com` (SSL via Let's Encrypt, handled by Kamal proxy)
- **SSH key**: `~/.ssh/id_rsa` (user: `root`)
- **Note**: `deploy.yml` references `~/.ssh/hetzner-pc` in comments — that's stale/wrong. The actual key is `~/.ssh/id_rsa`

### Architecture
- **Single-server deployment** — no dedicated job worker server
- Solid Queue runs **inside Puma** via `SOLID_QUEUE_IN_PUMA: true`
- SQLite3 files stored in a **persistent Docker volume** (`code-rank-storage:/rails/storage`)
- Kamal proxy (`kamal-proxy:v0.9.0`) handles SSL termination on ports 80/443

### CI/CD
- GitHub Actions on push to `main`: Brakeman → Importmap audit → Rubocop → Tests → `kamal deploy`
- Deploy workflow uses `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, `KAMAL_REGISTRY_PASSWORD` from GitHub secrets
- Image published to Docker Hub as `gianniacquisto/code-rank`

---

## Kamal Commands (Production)

### Logs — the primary debugging tool
```bash
bin/kamal logs --lines 100        # Last 100 log lines (RECOMMENDED)
bin/kamal logs                    # Streams live logs (hangs — Ctrl+C to stop)
```

**Important**: `bin/kamal logs` without `--lines` uses `-f` (follow mode) and will hang after returning output. Always use `--lines N` for scripted/agent use.

### Other useful commands
```bash
bin/kamal console                 # Rails console on the server
bin/kamal shell                   # Bash shell on the server
bin/kamal logs -f                 # Live stream (interactive only)
bin/kamal deploy                  # Deploy from local to production
```

### Container naming
Kamal names containers with the commit digest: `code-rank-web-<sha>`.
Old containers from previous deploys stay as `Exited` — clean them up with `docker container prune` on the server if needed.

### Secrets
Stored in `.kamal/secrets` (gitignored). Generated from:
- `config/master.key` (RAILS_MASTER_KEY)
- `SECRET_KEY_BASE` (in `.kamal/secrets` directly)
- `KAMAL_REGISTRY_PASSWORD` (Docker Hub token)

---

## Known Issues / Gaps
- `/sitemap.xml` returns 404 — no sitemap implemented
- `/robots.txt` is minimal (99 bytes)
- No dedicated job worker server configured (commented out in `deploy.yml`)
- Recurring Solid Queue job runs every ~hour to clear finished jobs (normal, healthy)
- Constant scanner noise: `/wp-admin/install.php` probes from various IPs (normal for any public server)

---

## Current State
- **Last commit**: `44568cd` — "created technology model"
- **Running image**: `gianniacquisto/code-rank:7b4a4bd`
- **App is healthy** — no errors in production, response times ~10ms
