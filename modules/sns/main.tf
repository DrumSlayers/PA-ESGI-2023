resource "aws_sns_topic" "topic_ec2" {
    name = "ec2-down-topic"
}

#create a SNS topic for GuardDuty alerts
resource "aws_sns_topic" "guardduty_alerts" {
  name = "guardduty-alerts"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
    topic_arn = aws_sns_topic.topic_ec2.arn
    protocol  = "sms"
    endpoint  = var.sns_phone_number
}

resource "aws_sns_topic_subscription" "email_subscription" {
    topic_arn = aws_sns_topic.topic_ec2.arn
    protocol  = "email"
    endpoint  = var.sns_email_address
}

resource "aws_sns_topic_subscription" "email_subscription_guardduty" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email_address_guard
}

resource "aws_sns_topic_subscription" "sms_subscription_guardduty" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "sms"
  endpoint  = var.sns_phone_number_guard
}