# AI TODO - Lightning Homelab

Active task list for the AI agent working on Paul's Kubernetes homelab.
Completed items get struck through. Add new items as they come up.

---

## Stale / Older Items (from previous sessions)

- ~~Switch to IPv6-only networking (ENI-based IPv6 prefix allocation on boot)~~
- Write the script for allocating ENIs on node boot
- Break ENI allocation into a separate unit/module
- Get Cilium image pulled into the AMI
- Adjust pod affinity rules to eliminate "no new claims to deallocate" noise
- Explore workaround for https://github.com/cilium/cilium/issues/44199
- Install AWS Node Termination Handler to reduce shutdown noise
- Get ECR credential helper working; prove ability to pull a private image

## Infrastructure Maintenance (recurring)

- Keep Fedora version up to date
- Keep OpenTofu up to date
- Keep OpenTofu provider versions up to date
- Keep Kubernetes version up to date
- Keep Helm chart versions up to date
- Clean up old AMIs

## Active / Current

(None right now — see objectives.md)

---

## AI Tooling Notes

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

### Gaps / Needs Verification
- Browser automation — no interactive browser (web_fetch is static only)
- Image generation (openrouter_image_generation) — installed but untested
- Docker — need to verify Docker-in-Docker availability in this sandbox
- Cloud CLIs (AWS CLI) — chores.md assumes it's available; should verify

### Action Items
- [ ] Verify browser automation availability (or work around with curl/web_fetch)
- [ ] Verify Docker-in-Docker if container image builds are needed
- [ ] Verify AWS CLI is authenticated and functional
