locals {
  cloudflared_imagebuilder_component = {
    name          = "CloudflaredTunnel"
    description   = "Cloudflared tunnel AMI"
    schemaVersion = 1

    phases = [
      {
        name = "build"
        steps = [
          {
            name   = "AddCloudflareRepo"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "curl -fsSl https://pkg.cloudflare.com/cloudflared.repo | sudo tee /etc/yum.repos.d/cloudflared.repo"
              ]
            }
          },
          {
            name   = "InstallCloudflared"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "dnf install -y cloudflared"
              ]
            }
          },
          {
            name   = "CreateCloudflaredSystemdService"
            action = "CreateFile"
            inputs = [
              {
                path      = "/etc/systemd/system/cloudflared.service"
                content   = templatefile("${path.module}/templates/cloudflared.service.tftpl", {})
                overwrite = true
              }
            ]
          },
          {
            name   = "EnableCloudflaredService"
            action = "ExecuteBash"
            inputs = {
              commands = [
                "systemctl enable cloudflared"
              ]
            }
          }
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
