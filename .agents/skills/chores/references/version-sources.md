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

Probe in the cluster's region (`us-east-2`). The highest `<v>` for which
addon versions are returned is the latest supported.

```bash
for v in 1.37 1.36 1.35 1.34; do
  n=$(aws eks describe-addon-versions --kubernetes-version "$v" \
        --region us-east-2 --query 'addons[].addonVersion' --output text \
        2>/dev/null | wc -w)
  echo "$v -> $n addon versions"
done
```

The first (highest) `v` with a non-zero count is the latest supported. Compare to
`kube_version` in `06_eks_cluster/workspace.tf` for the active workspace.
**Report only — never bump.**

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
