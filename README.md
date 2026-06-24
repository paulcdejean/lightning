# Lightning in a bottle

Paul's Kubernetes homelab.

Note: This will **not** work out of the box on us-east-1, because us-east-1 has 6 availability zones and one is cursed.

# ipv6 address layout

* ipam cidr /52 (only allowed size by AWS without a limit increase)
* environment /56, 16 possible environments in the allocation
* vpc /56, 1 possible VPC per environment
* subnet /64, 256 possible subnets per vpc
* ENI prefix /80 (FIXED SIZE by amazon), 65536 possible ENIs per subnet

# AI support
Personally I set:
`alias ai='$(git rev-parse --show-toplevel)/01_agent/scripts/ai.bash'`

Note you will need dnsmasq installed, this is because cloudflare warp and apple containers are not playing nice together.

My /opt/homebrew/etc/dnsmasq.conf is:
```
listen-address=127.0.0.1
bind-interfaces
port=53
cache-size=0
```

Then you will need to run:
`sudo container system dns create host.container.internal --localhost 203.0.113.113`

Docs say you need to run this every time, but I just had to run it once.
