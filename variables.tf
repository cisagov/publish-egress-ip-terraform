# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "bucket_name" {
  description = "The name of the S3 bucket to publish egress IP address information to."
  type        = string
}

variable "domain" {
  description = "The domain hosting the published file(s) containing egress IPs.  Also used for the CloudFront distribution and certificate."
  type        = string
}

variable "deployment_role_arn" {
  description = "The ARN of the IAM role to use to deploy the Lambda and all related resources."
  type        = string
}

variable "route53_role_arn" {
  description = "The ARN of the IAM role to use to modify Route53 DNS resources."
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "account_name_regex" {
  default     = "^$"
  description = "A regular expression that will be applied against the names of all non-master accounts in the AWS organization.  If the name of an account matches the regular expression, that account will be queried for egress IP addresses to publish.  The default value should not match any valid account name."
  type        = string
}

variable "application_tag" {
  default     = "Application"
  description = "The name of the AWS tag whose value represents the application associated with an IP address."
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to deploy into (e.g. us-east-1)."
  type        = string
}

variable "ec2_read_role_name" {
  default     = "EC2ReadOnly"
  description = "The name of the IAM role that allows read access to the necessary EC2 attributes.  Note that this role must exist in each account that you want to query."
  type        = string
}

variable "extraorg_account_ids" {
  default     = []
  description = "A list of AWS account IDs corresponding to \"extra\" accounts that you want to query for egress IPs to publish."
  type        = list(string)
}

variable "file_configs" {
  default     = []
  type        = list(object({ app_regex = string, description = string, filename = string, static_ips = list(string) }))
  description = "A list of objects that define the files to be published.  \"app_regex\" specifies a regular expression matching the application name (based on the var.application_tag).  \"description\" is the description of the published file.  \"filename\" is the name to assign the published file.  \"static_ips\" is a list of CIDR blocks that will always be included in the published file.  An example file configuration looks like this: `[{\"app_regex\": \".*\", \"description\": \"This file contains a list of all public IP addresses to be published.\", \"filename\": \"all.txt\",  \"static_ips\": []}, {\"app_regex\": \"^Vulnerability Scanning$\", \"description\": \"This file contains a list of all IPs used for Vulnerability Scanning.\", \"filename\": \"vs.txt\",  \"static_ips\": [\"192.168.1.1/32\", \"192.168.2.2/32\"]}]`"
}

variable "file_header" {
  default     = "###\n# https://{domain}/{filename}\n# {timestamp}\n# {description}\n###\n"
  description = "The header template for each published file.  The following variables are available within the template: {domain} - the domain where the published files are located, {filename} - the name of the published file, {timestamp} - the timestamp when the file was published, {description} - the description of the published file"
  type        = string
}

variable "lambda_function_description" {
  default     = "Lambda function to publish egress IP addresses to an S3 bucket configured with a CloudFront distribution for HTTPS access."
  description = "The description of the Lambda function."
  type        = string
}

variable "lambda_function_name" {
  default     = "publish-egress-ip"
  description = "The name of the Lambda function to publish egress IP addresses."
  type        = string
}

variable "lambda_schedule_interval" {
  default     = 60
  description = "The number of minutes between scheduled runs of the Lambda function to publish egress IP addresses.  This value must be an integer greater than 0."
  type        = number

  validation {
    condition     = alltrue([floor(var.lambda_schedule_interval) == var.lambda_schedule_interval, var.lambda_schedule_interval > 0])
    error_message = "lambda_schedule_interval must be an integer greater than zero."
  }
}

variable "lambda_zip_filename" {
  default     = "publish_egress_ip.zip"
  description = "The name of the ZIP file containing the Lambda function deployment package to publish egress IP addresses.  The file must be located in the root directory of this project."
  type        = string
}

variable "lambdaexecution_role_description" {
  default     = "Allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs."
  description = "The description to associate with the IAM role (and policy) that allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs."
  type        = string
}

variable "lambdaexecution_role_name" {
  default     = "PublishEgressIPLambda"
  description = "The name to assign the IAM role (and policy) that allows the publish-egress-ip Lambda to query other accounts for public EC2 IP information, publish objects to the S3 bucket, and write CloudWatch logs."
  type        = string
}

variable "publish_egress_tag" {
  default     = "Publish Egress"
  description = "The name of the AWS resource tag whose value represents whether the EC2 instance or elastic IP should have its public IP address published."
  type        = string
}

variable "region_filters" {
  default     = []
  description = "A list of AWS EC2 region filters to use when querying for IP addresses to publish.  If a filter is not specified, the query will be performed in all regions.  An example filter to restrict to US regions looks like this: `[{ \"Name\" : \"endpoint\", \"Values\" : [\"*.us-*\"] }]`.  For more information, refer to <https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-regions.html>."
  type        = list(object({ Name = string, Values = list(string) }))
}

variable "root_object" {
  default     = "all.txt"
  description = "The root object in the S3 bucket to serve when no path is provided or an error occurs."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created."
  default     = {}
}
