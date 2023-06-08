resource "aws_sns_topic" "topic_ec2" {
    name = "ec2-down-topic"
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