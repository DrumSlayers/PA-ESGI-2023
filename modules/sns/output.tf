output "sns_topic-arn" {
    description = "ARN of the SNS topic"
    value = aws_sns_topic.topic_ec2.arn
}

output "sns_topic-arn-guardduty" {
    description = "ARN of the SNS topic for GuardDuty alerts"
    value = aws_sns_topic.guardduty_alerts.arn
}