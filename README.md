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
`alias ai='t=$(git rev-parse --show-toplevel) && container run --env-file $t/01_agent/.env -v $t:/root/lightning/ -it $(container build -f $t/01_agent/jail.containerfile $t/01_agent/)'`
