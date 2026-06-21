# AI TODO - Tooling Assessment

Last assessed: 2026-06-21

### Available
- Full file CRUD (read_file, write_file, patch, search_files)
- Shell access (terminal)
- Git (via terminal)
- Web search + web fetch + fusion (parallel multi-model research)
- Code execution (execute_code / Python)
- Vision (vision_analyze for images)
- Persistent memory (cross-session)
- cronjob scheduling
- delegate_task / subagent for parallel work
- 71 skills loaded (~30 relevant to this project)
- AWS CLI — installed (v2.35.0), authenticated as `lightning-agent` (account 593941967609)
- gh CLI — installed (v2.94.0), authenticated as `paulcdejean` via token (HTTPS)

### Gaps / Needs Verification
- Browser automation — **NOT WORKING**: Playwright Node.js (v1.61.0) has browser binaries cached, but `playwright` Python package is installed but Chromium binary download failed. `browser-use` not installed. No `apt-get` in this Fedora sandbox to install system deps. Would need to fix the Python playwright install or use Node.js directly.
- Image generation (openrouter_image_generation) — **UNAVAILABLE**: OpenRouter account out of credits (402 Payment Required). Needs credit top-up at openrouter.ai/settings/credits.
- Docker — **NOT AVAILABLE**: `docker` command not found in this sandbox.

### Not Yet Verified (likely needed)
- OpenTofu (`tofu`) — not verified, but this project is entirely OpenTofu-driven
- `kubectl` / `helm` — git log shows they were added to the jail, not verified
- MCP servers — chores.md says "the needed MCP servers should be installed"; OpenTofu and Cloudflare docs MCPs exist in toolset but not verified working
- SSH — bastion layer (04_bastion) exists; SSH keys/config not verified
- Database tooling — no direct DB client; AWS CLI covers RDS/DynamoDB API but not interactive queries

### Verified
- [x] AWS CLI — WORKING
- [x] gh CLI — WORKING
- [x] Browser automation — NOT WORKING
- [x] Docker — NOT AVAILABLE
- [x] Image generation — UNAVAILABLE (no credits)
