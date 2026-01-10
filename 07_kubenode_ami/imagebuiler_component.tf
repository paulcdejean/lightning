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
            name   = "RemoveKubeadmDropin"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "rm /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
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
        ]
      },
      {
        name = "validate"
        steps = [
          {
            name   = "NoopValidateStep"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "echo 'No validation performed.'"
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
