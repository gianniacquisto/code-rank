# Code Rank — Project Context

## What is this?
A Ruby on Rails 8 app for ranking and reviewing open source software. Built in the open to demystify web app development.

## Tech Stack
- **Rails 8.1.3** / **Ruby 3.4.5**
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

### Architecture
- **Single-server deployment** — no dedicated job worker server
- Solid Queue runs **inside Puma** via `SOLID_QUEUE_IN_PUMA: true`
- SQLite3 files stored in a **persistent Docker volume** (`code-rank-storage:/rails/storage`)
- Kamal proxy (`kamal-proxy:v0.9.2`) handles SSL termination on ports 80/443

### CI/CD
- GitHub Actions on push to `main`: Brakeman → Importmap audit → Rubocop → Tests → `kamal deploy`
- Deploy workflow uses `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, `KAMAL_REGISTRY_PASSWORD` from GitHub secrets
- Image published to Docker Hub as `gianniacquisto/code-rank`
- **Deploy lock**: Kamal acquires a deploy lock automatically. Do **not** add `kamal lock release` before `kamal deploy` — it risks concurrent deploys if a previous run is slow.

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

## Operational Notes

### Deploy lock troubleshooting
Kamal uses a directory-based lock (`.kamal/lock-code-rank/`). If a GitHub Actions workflow is cancelled mid-deploy, the lock is left behind and blocks subsequent deploys. This is intentional — it prevents two deploys from running concurrently on the same server.

**To clear a stuck lock:**
```bash
ssh -i ~/.ssh/id_rsa root@116.203.97.159 'rm -rf .kamal/lock-code-rank'
```

**Why we don't auto-release the lock:** Adding `kamal lock release` before `kamal deploy` risks concurrent deploys if a previous run is still in progress. A stuck lock is rare and easy to clear; concurrent deploys are dangerous.

- **kamal-proxy version**: Kamal 2.9.0 requires kamal-proxy ≥ v0.9.2. If upgrading kamal locally, update the proxy on the server first: set `.kamal/proxy/image_version` to the desired version, then `docker stop kamal-proxy && docker rm kamal-proxy` on the server, then `bin/kamal proxy boot`.
