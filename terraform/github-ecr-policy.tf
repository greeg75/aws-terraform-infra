# Permissions required to publish Docker images to ECR
data "aws_iam_policy_document" "github_actions_ecr" {
  # ECR requires this actions to obtain a registry authentication token
  # AWS requires Resource = "*" for this action
  statement {
    sid       = "ECRAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }


  # Restrict image publishing operations to this repository only
  statement {
    sid    = "ECRPushImages"
    effect = "Allow"


    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]


    resources = [
      aws_ecr_repository.app.arn
    ]
  }
}


# Attach the minimal ECR permissions to the GitHub Actions role
resource "aws_iam_role_policy" "github_actions_ecr" {
  name   = "github-actions-ecr-push"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.github_actions_ecr.json
}