# Handoff — iteration 2 (read-only AWS IAM user → .env)

## What this iteration did
- Added `00_aws_users/iam.tf`: an `aws_iam_user` (`lightning-agent`), a
  `ReadOnlyAccess` policy attachment, and an `aws_iam_access_key`.
- Updated `00_aws_users/env_file.tf` + `templates/env.tftpl` to template the
  access key into `../.env` as `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`.
- No change to `jail.containerfile` this iteration (see note on awscli below).

## How the iteration loop works (read me first)
See `objectives.md`. Short version:
1. Agent edits terraform / containerfile to gain a capability.
2. Agent commits + updates this file.
3. User applies terraform with their **admin** credentials, then rebuilds the
   container from `jail.containerfile`.
4. Repeat. The agent starts each iteration with no memory — this file IS its
   memory.

Key implication: the agent has no AWS/Cloudflare credentials inside the
container yet. The user applies terraform externally with admin creds. So the
agent writes terraform that creates credentials and templates them into `.env`
(via `local_sensitive_file`). It just can't *apply* that terraform itself until
it has creds — chicken-and-egg, broken one step at a time.

## Resolved: the awscli question (iteration 1 feedback was a non-issue)
- The iteration-1 feedback declined `awscli` claiming Fedora installs legacy
  v1. **This was incorrect for Fedora 44.** In Fedora 44 there is no `awscli`
  (v1) package at all; only `awscli2` (v2) exists.
- `dnf install awscli` succeeds via dnf substring matching and installs
  `awscli2`. So the existing `jail.containerfile` line `dnf install ... awscli`
  is fine and reproducible; it yields AWS CLI v2.
- Confirmed in the running container: `aws --version` → `aws-cli/2.35.0`,
  installed package `awscli2-2.35.0-1.fc44.noarch`. No action needed.

## Current state of the jail
- Installed: bun, pi (+ pi-mcp-adapter), goose, opentofu 1.12.3, ripgrep, fd,
  git, awscli2 (AWS CLI v2.35.0).
- `.env` currently contains: `CLOUDFLARE_API_KEY`, `CLOUDFLARE_ACCOUNT_ID`,
  `CLOUDFLARE_GATEWAY_ID`. **After the user applies iteration 2's terraform,
  `.env` will also contain `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`** for
  the read-only `lightning-agent` IAM user.
- `~/.aws/credentials` does NOT exist in the container yet.
- MCP servers configured (`jail/mcp.json`): **opentofu** only.

## What "running the chores" actually requires
The chores (see `AGENTS.md`) boil down to, per folder:
- Check latest opentofu CLI version, latest fedora version, latest EKS version
  supported by AWS, latest provider versions.
- Bump `required_version` and provider versions in each `tofu.tf`.
- Run `tofu init -upgrade` + `tofu plan -lock=false` and report non-clean plans
  + deprecation warnings.

So the agent ultimately needs, inside the container:
1. **AWS credentials** for `tofu` to read state and the AWS provider to `plan`.
   - This iteration (2) adds the read-only IAM access key to `.env` (env vars).
     This satisfies the **AWS provider** (no explicit profile → default chain →
     env vars). ReadOnlyAccess is enough for `plan`.
   - **STILL MISSING:** the **state backend**. The backend is S3-on-Cloudflare-R2
     using `profile = "cloudflare"` (see any `tofu.tf`). So `~/.aws/credentials`
     needs a `[cloudflare]` profile with **R2 S3-compatible access keys**
     (access_key_id + secret_access_key). The Cloudflare terraform provider does
     NOT manage R2 S3 access keys (no such resource) — the user must supply
     these (e.g. as terraform variables templated into a `local_sensitive_file`
     for `~/.aws/credentials`). Until this is done, `tofu init` will still fail
     on the backend even with the AWS provider creds present.
2. **GitHub MCP** for checking latest releases (opentofu, cilium, etc.). Not
   configured yet. Needs a GitHub token the user must provide. Remote GitHub MCP
   is `https://api.githubcopilot.com/mcp/` with a bearer token; pi-mcp-adapter
   supports `"url"`, `"headers"`, `"auth": "bearer"` / `"bearerTokenEnv"`. A
   stdio server via `bunx` is also an option since bun is installed.
3. **opentofu MCP** — already done.

## Suggested next steps (pick ONE per iteration, don't blow up scope)
- NEXT (iteration 3): wire R2 state creds into `~/.aws/credentials`. Add a
  `local_sensitive_file` for `/root/.aws/credentials` with a `[cloudflare]`
  profile, sourced from user-supplied variables (R2 access key id + secret).
  This unblocks `tofu init` on the backend. (User must supply R2 keys; can't be
  bootstrapped by terraform.)
- After that: add GitHub MCP + token.
- Only then can chores actually run end-to-end.

## Gotchas learned
- `tofu init` / `tofu validate` in the container fails for two reasons:
  (a) backend `failed to get shared config profile, cloudflare` — no
  `~/.aws/credentials` yet (fixed in iteration 3); (b) provider plugins not
  cached in `.terraform` because init never succeeded. Both are expected.
- `tofu fmt -check -diff` errors because `diff` is not installed in the jail —
  harmless; use plain `tofu fmt` instead. (Could add `diffutils` to the
  containerfile later if desired.)
- The cloudflare provider (v5.21.0) has no resource for R2 S3-compatible access
  keys. Don't waste time looking for one.
- Chores must run in order, folder by folder, not in parallel. Always use
  `-lock=false` on `tofu plan`.
- `01_ipspace` and `05_cloudflare_tunnel` pin cloudflare provider to 5.20.0
  while `00_aws_users` is on 5.21.0 — a chore will likely want to align these.

## Git
This iteration's commit (iteration 2): add read-only IAM user + access key
templated into `.env`. Containerfile unchanged.
