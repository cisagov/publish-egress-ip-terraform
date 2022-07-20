# ------------------------------------------------------------------------------
# Create an IAM policy document that only allows AWS Lambdas to assume the
# role this policy is attached to.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
