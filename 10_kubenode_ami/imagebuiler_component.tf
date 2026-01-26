locals {
  kubenode_imagebuilder_component = {
    name          = "LightningKubeNode"
    description   = "Lightning Kubernetes node AMI"
    schemaVersion = 1

    phases = [
      {
        name = "build"
        steps = [
          {
            # Kube nodes shouldn't use swap, but fedora has this new fancy swap it thinks everyone should use.
            name   = "NoSwap"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf remove -y zram-generator-defaults"
              ]
            }
          },
          {
            name   = "UpgradePackages"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf upgrade -y"
              ]
            }
          },
          {
            name   = "InstallKube"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf --setopt=install_weak_deps=False -y install kubernetes${local.workspace.kube_version}-systemd kubernetes${local.workspace.kube_version}-client"
              ]
            }
          },
          {
            name   = "InstallContainerd"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf install -y containerd"
              ]
            }
          },
          {
            name   = "EnableContainerd"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "systemctl enable containerd"
              ]
            }
          },
          {
            name   = "CreateKubenodeKernelDefaults"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/sysctl.d/kubenode.conf"
                content   = templatefile("${path.module}/templates/kernel_settings.config", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateSystemEnvVars"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/profile.d/lightning_env_vars.sh"
                content   = templatefile("${path.module}/templates/env_vars.sh", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateWrapperScript"
            action = "CreateFile"
            inputs = [
              {
                path        = "/usr/local/bin/lightning_kubelet_wrapper.bash"
                content     = templatefile("${path.module}/templates/kubelet_wrapper.bash", {})
                overwrite   = true
                permissions = "0755"
              }
            ]
          },
          {
            name   = "CreateImageCredProviderFolder"
            action = "CreateFolder"
            inputs = [
              {
                path      = "/etc/lightning"
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateKubeletConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/lightning/kublet_config.yaml"
                content   = templatefile("${path.module}/templates/kubelet_config.yaml", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateKubeConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/lightning/kube_client_config.yaml"
                content   = templatefile("${path.module}/templates/kube_client_config.yaml", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateImageCredProviderConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/lightning/credential_provider_config.yaml"
                content   = templatefile("${path.module}/templates/image_credential_provider.yaml", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateKubeletServiceOverride"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/systemd/system/kubelet.service.d/lightning.conf"
                content   = templatefile("${path.module}/templates/kubelet.service", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateCiliumNodeTemplate"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/lightning/cilium_node.yaml"
                content   = templatefile("${path.module}/templates/cilium_node.yaml", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "InstallEcrHelper"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "AWS_USE_DUALSTACK_ENDPOINT=true aws --no-sign-request s3 cp s3://${local.workspace.ecr_credential_helper_path} /usr/local/bin/ecr-credential-provider",
                "chmod a+x /usr/local/bin/ecr-credential-provider"
              ]
            }
          },
          {
            name   = "InstallBashEssentials"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf install -y tmux jq"
              ]
            }
          },
          {
            name   = "EnableKubelet"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "systemctl enable kubelet"
              ]
            }
          },
        ]
      },
      {
        name = "validate"
        steps = [
          {
            name   = "VerifyKubePackage"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "rpm -V kubernetes${local.workspace.kube_version}"
              ]
            }
          },
          {
            name   = "VerifyContainerdPackage"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "rpm -V containerd"
              ]
            }
          }
        ]
      }
    ]
  }
}
