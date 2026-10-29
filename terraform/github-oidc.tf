# GitHub Actions OIDC identity provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"


  client_id_list = [
    "sts.amazonaws.com"
  ]


  tags = {
    Name      = "github-actions-oidc"
    ManagedBy = "Terraform"
    Project   = "aws-terraform-infra"
  }
}


# Trust policy: only this repository's main branch can assume the role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "GitHubActionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]


    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }


    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }


    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:greeg75/aws-terraform-infra:refs/heads/main"]
    }
  }
}


# IAM role assumed by GitHub Actions
resource "aws_iam_role" "github_actions_ecr" {
  name                 = "github-actions-ecr-publisher"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600


  tags = {
    Name      = "github-actions-ecr-publisher"
    ManagedBy = "Terraform"
    Project   = "aws-terraform-infra"
  }
}