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

### Gaps / Needs Verification
- Browser automation — **NOT WORKING**: Playwright Node.js (v1.61.0) has browser binaries cached, but `playwright` Python package is installed but Chromium binary download failed. `browser-use` not installed. No `apt-get` in this Fedora sandbox to install system deps. Would need to fix the Python playwright install or use Node.js directly.
- Image generation (openrouter_image_generation) — **UNAVAILABLE**: OpenRouter account out of credits (402 Payment Required). Needs credit top-up at openrouter.ai/settings/credits.
- Docker — **NOT AVAILABLE**: `docker` command not found in this sandbox.

### Action Items
- [x] Verify browser automation availability — NOT WORKING (see above)
- [x] Verify Docker availability — NOT AVAILABLE
- [x] Verify AWS CLI is authenticated and functional — WORKING
