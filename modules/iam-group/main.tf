resource "aws_iam_group" "this" {
  name = var.group_name
}

resource "aws_iam_group_policy_attachment" "attach" {
  for_each = var.policy_arns

  group      = aws_iam_group.this.name
  policy_arn = each.value
}
