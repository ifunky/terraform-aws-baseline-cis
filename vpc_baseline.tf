# --------------------------------------------------------------------------------------------------
# Clears rules associated with default resources.
# --------------------------------------------------------------------------------------------------

locals {
   default_network_acl_id = var.vpc_default_clear ? aws_default_vpc.default[0].default_network_acl_id : var.vpc_default_network_acl
}

resource "aws_default_vpc" "default" {

  count  = var.vpc_default_clear ? 1 : 0

  tags = merge(
    var.tags,
    { Name = "Default VPC" }
  )
}

resource "aws_default_route_table" "default" {
  count                  = var.vpc_default_clear ? 1 : 0
  default_route_table_id = aws_default_vpc.default[count.index].default_route_table_id

  tags = {
    Name = "Default Route Table"
  }
}

// Ignore "subnet_ids" changes to avoid the known issue below.
// https://github.com/hashicorp/terraform/issues/9824
// https://github.com/terraform-providers/terraform-provider-aws/issues/346
# resource "aws_default_network_acl" "default" {
#   lifecycle {
#     ignore_changes = [subnet_ids]
#   }

#   default_network_acl_id = local.default_network_acl_id
#   tags = merge({ "Name" = "Default Network ACL" }, var.tags)

# }


resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  tags = merge({ "Name" = "Default Security Group" }, var.tags)
}
