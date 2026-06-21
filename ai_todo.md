# AI TODO - Tooling Assessment

### Gaps / Needs Verification
- Browser automation — **NOT WORKING**: Playwright Node.js (v1.61.0) has browser binaries cached, but `playwright` Python package is installed but Chromium binary download failed. `browser-use` not installed. No `apt-get` in this Fedora sandbox to install system deps. Would need to fix the Python playwright install or use Node.js directly.
- Image generation (openrouter_image_generation) — **UNAVAILABLE**: OpenRouter account out of credits (402 Payment Required). Needs credit top-up at openrouter.ai/settings/credits.
- Docker — **NOT AVAILABLE**: `docker` command not found in this sandbox.
- SSH — bastion layer (04_bastion) exists; SSH keys/config not verified
- Database tooling — no direct DB client; AWS CLI covers RDS/DynamoDB API but not interactive queries
