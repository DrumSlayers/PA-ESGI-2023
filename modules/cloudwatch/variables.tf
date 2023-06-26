variable "instance-id" {
  description = "ID of the EC2 instance"
}

variable "instance-name" {
  description = "Name of the EC2 instance"
}

variable "sns_topic-arn" {
  description = "ARN of the SNS topic"
}

variable "sns_topic-arn-guardduty" {
  description = "ARN of the SNS topic for GuardDuty alerts"
}
