# Version sources runbook

Exact, authoritative commands for the "look up latest versions" step of chores.
**Look these up every run — never hardcode version numbers.**

Constraint: no `curl`/web fetch. Use `gh`, `aws`, and the opentofu MCP only.

## OpenTofu (the `tofu` binary + `required_version`)

```bash
gh release view --repo opentofu/opentofu --json tagName -q .tagName
#   → e.g. "v1.12.3"  (strip the leading "v" for required_version)
tofu version      # installed binary, for comparison
```

Prompt the user to upgrade OpenTofu if the installed binary is behind the latest
release. Do **not** edit anything to change the installed binary — that's a
`jail.containerfile` change the user applies.

## Registry providers (opentofu MCP)

Use the opentofu MCP gateway tools. For each provider source found in a folder's
`required_providers`, query the latest version. Sources look like
`hashicorp/aws`, `cloudflare/cloudflare`, `hashicorp/local`, etc.

Typical MCP calls (via the `mcp` tool):
- list available tools: `mcp({ server: "opentofu" })`
- query a provider's latest version using the appropriate opentofu MCP tool
  (e.g. a latest-provider-versions / provider-info tool)

Confirm the exact tool names by running `mcp({ server: "opentofu" })` first —
tool surface can change between MCP versions.

## GitHub-only providers (opentofu MCP 404s → fall back to `gh`)

Some providers are not published to the registry the opentofu MCP indexes, e.g.
`Tobotimus/toml`. The MCP returns 404 for these. Fall back to the GitHub
releases API:

```bash
# source = "Tobotimus/toml"
gh api repos/Tobotimus/terraform-provider-toml/releases/latest -q .tag_name
#   → e.g. "v0.3.0"  (strip leading "v")
```

Note the repo name pattern is usually `terraform-provider-<name>` even when the
source is `<org>/<name>`. Verify the repo path if the call 404s (`gh repo view`
or `gh api repos/<org>` to list).

## EKS (latest AWS-supported Kubernetes version) — `aws` CLI

`describe-cluster-versions` lists every Kubernetes version EKS supports — no
hardcoded candidate list, no probing. Query it in the cluster's region
(`us-east-2`) and take the highest:

```bash
aws eks describe-cluster-versions --region us-east-2 \
  --query 'clusterVersions[].clusterVersion' --output text \
  | tr '\t' '\n' | sort -V | tail -1
#   → e.g. "1.34"  (latest supported)
```

Useful filters:
- `--default-only` — only AWS's current default version.
- `--status STANDARD_SUPPORT` / `--status EXTENDED_SUPPORT` — filter by support tier.
- `--include-all` — include versions outside standard support.

Compare the result to `kube_version` in `06_eks_cluster/workspace.tf` for the
active workspace. **Report only — never bump.**

## Fedora (latest stable major) — `skopeo` preferred

`jail.containerfile` pins e.g. `quay.io/fedora/fedora:44`. Check available tags
without curl:

```bash
skopeo list-tags docker://quay.io/fedora/fedora 2>/dev/null \
  | grep -oE '"[0-9]+"' | tr -d '"' | sort -n | tail
```

If `skopeo` is not installed, report the pinned vs. running version
(`/etc/os-release`) and ask the user to confirm latest — do not use curl as a
substitute.
