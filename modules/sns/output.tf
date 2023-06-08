output "sns_topic-arn" {
    description = "ARN of the SNS topic"
    value = aws_sns_topic.topic_ec2.arn
}