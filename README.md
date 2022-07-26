# publish-egress-ip-terraform #

[![GitHub Build Status](https://github.com/cisagov/publish-egress-ip-terraform/workflows/build/badge.svg)](https://github.com/cisagov/publish-egress-ip-terraform/actions)

This repository contains Terraform code to deploy
[`cisagov/publish-egress-ip-lambda`](https://github.com/cisagov/publish-egress-ip-lambda)
and related resources.

## Pre-requisites ##

- [Terraform](https://www.terraform.io/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified in [`backend.tf`](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified in [`backend.tf`](backend.tf)).
- Access to all of the Terraform remote states specified in
  [`remote_states.tf`](remote_states.tf).
- A valid Lambda deployment file must be present in the root directory and have
  the same name as `var.lambda_zip_filename` (e.g. "publish_egress_ip.zip").
- A Terraform [variables](variables.tf) file customized for your
  assessment environment, for example:

  ```console
  bucket_name         = "s3-cdn.egress-info.my.domain.gov"
  domain              = "egress-info.my.domain.gov"
  deployment_role_arn = "arn:aws:iam::123456789012:role/deployment-role"
  file_configs        = [
        {
            "filename": "all.txt",
            "app_regex": ".*",
            "static_ips": [],
            "description": "This file contains a list of all public IP addresses."
        },
        {
            "filename": "vs.txt",
            "app_regex": "^Vulnerability Scanning$",
            "static_ips": [
                "192.168.1.1/32",
                "192.168.2.2/32"
            ],
            "description": "This file contains a list of all IPs used for Vulnerability Scanning."
        }
    ]
  route53_role_arn    = "arn:aws:iam::123456789012:role/route53-role"

  tags = {
    Team        = "VM Fusion - Development"
    Application = "Publish Egress IP"
    Workspace   = "production"
  }
  ```

## Building the Terraform-based infrastructure ##

1. Create a Terraform workspace (if you haven't already done so) for
   your assessment by running `terraform workspace new <workspace_name>`.
1. Create a `<workspace_name>.tfvars` file with all of the required
   variables (see [Inputs](#Inputs) below for details).
1. Run the command `terraform init`.
1. Create all Terraform infrastructure by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars
   ```

After the Terraform code has been deployed and the Lambda has run
successfully, you will be able to see your published egress IP address
information at: `https://<var.domain>`

If you defined additional files via `var.file_configs`, they can be
accessed at: `https://<var.domain>/<var.file_configs.filename>`

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.38 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |
| aws.deploy | ~> 3.38 |
| aws.organizationsreadonly | ~> 3.38 |
| aws.route53resourcechange | ~> 3.38 |
| terraform | n/a |

## Modules ##

| Name | Source | Version |
|------|--------|---------|
| security\_header\_lambda | transcend-io/lambda-at-edge/aws | 0.5.0 |

## Resources ##

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.rules_s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudwatch_event_rule.lambda_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambdaexecution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambdaexecution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambdaexecution_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.publish_egress_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_record.rules_vm_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.rules_vm_AAAA](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.egress_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.lambda_at_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.egress_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_public_access_block.lambda_artifact_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.egress_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.lambda_at_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.lambda_at_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_acm_certificate.rules_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambdaexecution_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [terraform_remote_state.dns](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.dns_cyber_dhs_gov](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.terraform](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_name\_regex | A regular expression that will be applied against the names of all non-master accounts in the AWS organization.  If the name of an account matches the regular expression, that account will be queried for egress IP addresses to publish.  The default value should not match any valid account name. | `string` | `"^$"` | no |
| application\_tag | The name of the AWS tag whose value represents the application associated with an IP address. | `string` | `"Application"` | no |
| aws\_region | The AWS region to deploy into (e.g. us-east-1). | `string` | `"us-east-1"` | no |
| bucket\_name | The name of the S3 bucket to publish egress IP address information to. | `string` | n/a | yes |
| deployment\_role\_arn | The ARN of the IAM role to use to deploy the Lambda and all related resources. | `string` | n/a | yes |
| domain | The domain hosting the published file(s) containing egress IPs.  Also used for the CloudFront distribution and certificate. | `string` | n/a | yes |
| ec2\_read\_role\_name | The name of the IAM role that allows read access to the necessary EC2 attributes.  Note that this role must exist in each account that you want to query. | `string` | `"EC2ReadOnly"` | no |
| extraorg\_account\_ids | A list of AWS account IDs corresponding to "extra" accounts that you want to query for egress IPs to publish. | `list(string)` | `[]` | no |
| file\_configs | A list of objects that define the files to be published.  "app\_regex" specifies a regular expression matching the application name (based on the var.application\_tag).  "description" is the description of the published file.  "filename" is the name to assign the published file.  "static\_ips" is a list of CIDR blocks that will always be included in the published file.  An example file configuration looks like this: `[{"app\_regex": ".*", "description": "This file contains a list of all public IP addresses to be published.", "filename": "all.txt",  "static\_ips": []}, {"app\_regex": "^Vulnerability Scanning$", "description": "This file contains a list of all IPs used for Vulnerability Scanning.", "filename": "vs.txt",  "static\_ips": ["192.168.1.1/32", "192.168.2.2/32"]}]` | `list(object({ app_regex = string, description = string, filename = string, static_ips = list(string) }))` | `[]` | no |
| file\_header | The header template for each published file.  The following variables are available within the template: {domain} - the domain where the published files are located, {filename} - the name of the published file, {timestamp} - the timestamp when the file was published, {description} - the description of the published file | `string` | `"###\n# https://{domain}/{filename}\n# {timestamp}\n# {description}\n###\n"` | no |
| lambda\_function\_description | The description of the Lambda function. | `string` | `"Lambda function to publish egress IP addresses to an S3 bucket configured with a CloudFront distribution for HTTPS access."` | no |
| lambda\_function\_name | The name of the Lambda function to publish egress IP addresses. | `string` | `"publish-egress-ip"` | no |
| lambda\_schedule\_interval | The number of minutes between scheduled runs of the Lambda function to publish egress IP addresses. | `number` | `60` | no |
| lambda\_zip\_filename | The name of the ZIP file containing the Lambda function deployment package to publish egress IP addresses.  The file must be located in the root directory of this project. | `string` | `"publish_egress_ip.zip"` | no |
| lambdaexecution\_role\_description | The description to associate with the IAM role (and policy) that allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs. | `string` | `"Allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs."` | no |
| lambdaexecution\_role\_name | The name to assign the IAM role (and policy) that allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs. | `string` | `"PublishEgressIPLambda"` | no |
| publish\_egress\_tag | The name of the AWS tag whose value represents whether the EC2 instance or elastic IP should have its public IP address published. | `string` | `"Publish Egress"` | no |
| region\_filters | A list of AWS EC2 region filters to use when querying for IP addresses to publish.  If a filter is not specified, the query will be performed in all regions.  An example filter to restrict to US regions looks like this: `[{ "Name" : "endpoint", "Values" : ["*.us-*"] }]`.  For more information, refer to <https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-regions.html> | `list(object({ Name = string, Values = list(string) }))` | `[]` | no |
| root\_object | The root object in the S3 bucket to serve when no path is provided or an error occurs. | `string` | `"all.txt"` | no |
| route53\_role\_arn | The ARN of the IAM role to use to modify Route53 DNS resources. | `string` | n/a | yes |
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| bucket | The S3 bucket where egress IP address information is published. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, these are the main directory and
every directory under `examples/`.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
