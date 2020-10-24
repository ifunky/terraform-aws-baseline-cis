# --------------------------------------------------------------------------------------------------
# Clears rules associated with default resources.
# --------------------------------------------------------------------------------------------------
/*
resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_default_vpc.default.default_route_table_id}"

  tags = {
    Name = "Default Route Table"
  }
}

// Ignore "subnet_ids" changes to avoid the known issue below.
// https://github.com/hashicorp/terraform/issues/9824
// https://github.com/terraform-providers/terraform-provider-aws/issues/346
resource "aws_default_network_acl" "default" {
  lifecycle {
    ignore_changes = ["subnet_ids"]
  }

  default_network_acl_id = "${aws_default_vpc.default.default_network_acl_id}"
  tags = "${merge(map( "Name", "Default Network ACL"), var.tags )}"

}
*/

resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  tags = merge(map( "Name", "Default Security Group"), var.tags)
}
