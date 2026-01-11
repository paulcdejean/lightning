# Adapted from https://github.com/awslabs/amazon-eks-ami/blob/main/nodeadm/test/e2e/cases/kubelet-config-new-instance-type/expected-kubelet-config.json

locals {
  kubelet_config = {
    kind = "KubeletConfiguration"
    # The offical version, used here: https://github.com/tarvitz/kubernetes/blob/master/etc/kubelet-config.yaml
    apiVersion = "kubelet.config.k8s.io/v1beta1"
    # Will make it serve on all interfaces including ipv6.
    address = "0.0.0.0"
    authentication = {
      x509 = {
        clientCAFile = "/etc/kubernetes/pki/ca.crt"
      }
      webhook = {
        enabled  = true
        cacheTTL = "2m0s"
      }
      anonymous = {
        enabled = false
      }
    }
    authorization = {
      mode = "Webhook"
      webhook = {
        cacheAuthorizedTTL   = "5m0s"
        cacheUnauthorizedTTL = "30s"
      }
    }
    cgroupDriver             = "systemd"
    cgroupRoot               = "/"
    containerRuntimeEndpoint = "unix:///run/containerd/containerd.sock"
    featureGates = {
      RotateKubeletServerCertificate = true
    }
    hairpinMode           = "hairpin-veth"
    protectKernelDefaults = true
    # Disables the read only service.
    readOnlyPort        = 0
    serializeImagePulls = false
    serverTLSBootstrap  = true
    # This is a stange default, but it is the default...
    maxPods = 110
    logging = {
      verbosity = 3
    }
    tlsCipherSuites = [
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
    ]
    evictionHard = {
      "memory.available"  = "100Mi"
      "nodefs.available"  = "10%"
      "nodefs.inodesFree" = "5%"
    }
    kubeReserved = {
      ephemeral-storage = "1G"
      memory            = "1G"
    }
    providerID = "aws:///us-west-2f/i-1234567890abcdef0"
  }
}
