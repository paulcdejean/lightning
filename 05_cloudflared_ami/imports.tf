# =============================================================================
# One-time import blocks to restore state for the `unstable` workspace.
#
# State for this segment was accidentally deleted during a migration. These
# import blocks tell OpenTofu to import the existing cloud resources back into
# state on the next `tofu plan` / `tofu apply`.
#
# After the import succeeds and state is reconciled, this file can be deleted.
# All IDs below are specific to the `unstable` workspace / account
# 593941967609 / region us-east-2.
# =============================================================================

# --- log_bucket.tf ---
import {
  to = aws_s3_bucket.imagebuilder_logs
  id = "lightning-imagebuilder-logs-593941967609-us-east-2-an"
}

# --- imagebuilder_role.tf ---
import {
  to = aws_iam_role.imagebuilder_execution
  id = "lightning-unstable-imagebuilder-execution"
}

import {
  to = aws_iam_role_policy_attachment.imagebuilder_execution_lifecycle_policy
  id = "lightning-unstable-imagebuilder-execution/arn:aws:iam::aws:policy/service-role/EC2ImageBuilderLifecycleExecutionPolicy"
}

import {
  to = aws_iam_role_policy.imagebuilder_defaults
  id = "lightning-unstable-imagebuilder-execution:imagebuilder_required"
}

import {
  to = aws_iam_role_policy.imagebuilder_ssm
  id = "lightning-unstable-imagebuilder-execution:ssm_access"
}

# --- instance_profile.tf ---
import {
  to = aws_iam_instance_profile.imagebuilder
  id = "lightning-unstable-imagebuilder"
}

import {
  to = aws_iam_role.imagebuilder
  id = "lightning-unstable-imagebuilder"
}

import {
  to = aws_iam_role_policy_attachment.imagebuilder_required
  id = "lightning-unstable-imagebuilder/arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

import {
  to = aws_iam_role_policy_attachment.imagebuilder_ssm_instance
  id = "lightning-unstable-imagebuilder/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

import {
  to = aws_iam_role_policy.logs_bucket_rw
  id = "lightning-unstable-imagebuilder:logs_bucket_rw"
}

# --- security_group.tf ---
import {
  to = aws_security_group.imagebuilder
  id = "sg-04cd895fc8881777b"
}

import {
  to = aws_vpc_security_group_egress_rule.allow_all_egress_ipv6
  id = "sgr-077a354b3dec132b7"
}

import {
  to = aws_vpc_security_group_egress_rule.allow_all_egress_ipv4
  id = "sgr-0b6078ad8071d3ffa"
}

# --- log_groups.tf ---
import {
  to = aws_cloudwatch_log_group.image_log_group
  id = "/aws/imagebuilder/lightning-unstable-cloudflared"
}

import {
  to = aws_cloudwatch_log_group.pipeline_log_group
  id = "/aws/imagebuilder/pipeline/lightning-unstable-cloudflared"
}

# --- ssm_parameter_output.tf ---
import {
  to = aws_ssm_parameter.cloudflared
  id = "/lightning-amis/unstable/cloudflared"
}

# --- ssm_parameter_base.tf ---
import {
  to = aws_ssm_parameter.base_image
  id = "/lightning-amis/unstable/cloudflared-baseimage"
}

# --- imagebuilder_recipe.tf ---
import {
  to = aws_imagebuilder_component.cloudflared
  id = "arn:aws:imagebuilder:us-east-2:593941967609:component/lightning-unstable-cloudflared/1.0.0/1"
}

import {
  to = aws_imagebuilder_image_recipe.cloudflared
  id = "arn:aws:imagebuilder:us-east-2:593941967609:image-recipe/lightning-unstable-cloudflared/1.0.0"
}

# --- imagebuilder_infra.tf ---
import {
  to = aws_imagebuilder_infrastructure_configuration.lightning
  id = "arn:aws:imagebuilder:us-east-2:593941967609:infrastructure-configuration/lightning-unstable"
}

# --- imagebuilder_distribution.tf ---
import {
  to = aws_imagebuilder_distribution_configuration.cloudflared
  id = "arn:aws:imagebuilder:us-east-2:593941967609:distribution-configuration/lightning-unstable-cloudflared"
}

# --- imagebuilder_pipeline.tf ---
import {
  to = aws_imagebuilder_image_pipeline.cloudflared
  id = "arn:aws:imagebuilder:us-east-2:593941967609:image-pipeline/lightning-unstable-cloudflared"
}

# --- trigger_update.tf ---
# null_resource cannot be imported (null provider 3.3.0 does not support
# import). It is a purely local resource with no cloud representation, so it
# will simply be recreated on the next apply. Note: this will trigger its
# local-exec provisioner, which starts an imagebuilder pipeline run.
