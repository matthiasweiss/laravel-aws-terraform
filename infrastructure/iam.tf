# TODO

data "aws_iam_policy_document" "ecs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "ecs_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_policy.json
}

resource "aws_iam_role_policy" "ecs_role_policy" {
  role   = aws_iam_role.ecs_role.name
  policy = data.aws_iam_policy_document.ecs_policy.json
}

