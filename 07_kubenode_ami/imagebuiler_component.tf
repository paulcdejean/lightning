locals {
  kubenode_imagebuilder_component = {
    name          = "CloudflaredTunnel"
    description   = "Cloudflared tunnel AMI"
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
            name   = "InstallKube"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf install -y kubernetes1.34"
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
                path      = "/etc/profile.d/lightning_env_vars.bash"
                content   = templatefile("${path.module}/templates/lightning_env_vars.sh", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateWrapperScript"
            action = "CreateFile"
            inputs = [
              {
                path      = "/usr/local/bin/lightning_kubelet_wrapper.bash"
                content   = templatefile("${path.module}/templates/kubelet_wrapper.bash", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateWrapperScript"
            action = "CreateFile"
            inputs = [
              {
                path      = "/usr/local/bin/lightning_kubelet_wrapper.bash"
                content   = templatefile("${path.module}/templates/kubelet_wrapper.bash", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateKubeletConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/kubernetes/kubelet/config.yaml"
                content   = templatefile("${path.module}/templates/kublet_config.bash", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateKubeConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/var/lib/kubelet/kubeconfig"
                content   = templatefile("${path.module}/templates/kubeconfig.yaml", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateImageCredProviderFolder"
            action = "CreateFolder"
            inputs = [
              {
                path      = "/etc/eks/image-credential-provider"
                overwrite = true
              }
            ]
          },
          {
            name   = "CreateImageCredProviderConfig"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/eks/image-credential-provider/config.json"
                content   = templatefile("${path.module}/templates/image_credential_provider.yaml", {})
                overwrite = true
              }
            ]
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
                "rpm -V kubernetes1.34"
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
      },
      {
        name = "test"
        steps = [
          {
            name   = "NoopTestStep"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'No testing performed.'"
              ]
            }
          }
        ]
      }
    ]
  }
}
