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
- Browser automation — no interactive browser (web_fetch is static only)
- Image generation (openrouter_image_generation) — **UNAVAILABLE**: OpenRouter account out of credits (402 Payment Required)
- Docker — need to verify Docker-in-Docker availability in this sandbox

### Action Items
- [ ] Verify browser automation availability
- [ ] Verify Docker-in-Docker if container image builds are needed
- [x] Verify AWS CLI is authenticated and functional
