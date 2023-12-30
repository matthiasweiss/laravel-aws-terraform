resource "aws_iam_role" "ecs_role" {
  assume_role_policy = jsonencode({
    Statement = {
      Effect = "Allow"
      Action = [
        "sts:AssumeRole"
      ]
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
    }
  })
}

resource "aws_iam_role_policy" "ecs_role_policy" {
  role = aws_iam_role.ecs_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect   = "Allow"
      Resource = "*"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
    }
  })
}
