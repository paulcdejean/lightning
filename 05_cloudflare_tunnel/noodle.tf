resource "aws_network_interface" "noodle" {
  subnet_id       = "subnet-07d01a394ad69af51"
  ipv6_prefix_count = 1
  tags = {
    Name = "noodle"
  }
}

# 2^64 different nodes


# 2^48 in a /80

# 16 difference

# 2^64 in a /64

# A min size subnet can have 2^16 different ranges
# A max size subnet can have 2^36 different ranges


# 281474976710656


# 2^68 different eni ids


# Subnets between 44 and 64 in increments of 4

# prefixes are /80


# 074368ef2c6ab5ae3
# fffffffffffffffff
# 05786e5591af0bfb0

# This means I need a unique value less than 2^36

# 32 bits 

# We have 36 bits
# 32 can store the seconds
