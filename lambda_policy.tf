# ------------------------------------------------------------------------------
# Create the IAM policy that allows the publish-egress-ip Lambda to access
# all resources needed to do its job.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambdaexecution_doc" {
  statement {
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      format("arn:aws:logs:%s:%s:*", var.aws_region, local.deployment_account_id)
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      format("arn:aws:logs:%s:%s:log-group:/aws/lambda/%s:*",
      var.aws_region, local.deployment_account_id, var.lambda_function_name)
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]
    resources = [
      "${aws_s3_bucket.egress_info.arn}/*"
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    resources = [
      format("arn:aws:iam::*:role/%s", var.ec2_read_role_name),
    ]
  }
}

resource "aws_iam_policy" "lambdaexecution_policy" {
  provider = aws.deploy

  description = var.lambdaexecution_role_description
  name        = var.lambdaexecution_role_name
  policy      = data.aws_iam_policy_document.lambdaexecution_doc.json
}
