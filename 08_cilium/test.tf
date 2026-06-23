data "github_rest_api" "crds" {
  endpoint = "repos/cilium/cilium/contents/pkg/k8s/apis/cilium.io/client/crds?ref=main"
}

output "files" {
  value = jsondecode(data.github_rest_api.crds.body)
}
