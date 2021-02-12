resource "aws_route53_zone" "this" {
  for_each = var.create ? var.zones : tomap({})

  name          = each.key
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  dynamic "vpc" {
    for_each = length(keys(lookup(each.value, "vpc", {}))) == 0 ? [] : [lookup(each.value, "vpc", {})]

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", null)
    }
  }

  # https://github.com/hashicorp/terraform/issues/3116
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association
  # https://github.com/hashicorp/terraform-provider-aws/issues/7812
  lifecycle {
    ignore_changes = [vpc]
  }

  tags = lookup(each.value, "tags", null)
}
