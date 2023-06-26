resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name          = "${var.instance-name} High CPU Usage"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "180"
    alarm_description   = "This metric triggers when CPU usage is above 80% for more than 3 minutes"
    alarm_actions       = [var.sns_topic-arn]
    dimensions = {
        InstanceId = var.instance-id
    }
    statistic     = "Average"
    threshold     = "80"
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
    alarm_name          = "${var.instance-name} Status Check Failed"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "StatusCheckFailed"
    namespace           = "AWS/EC2"
    period              = "60"
    alarm_description   = "This metric triggers when the instance status check fails"
    alarm_actions       = [var.sns_topic-arn]
    dimensions = {
        InstanceId = var.instance-id
    }
    statistic     = "SampleCount"
    threshold     = "0.99"
}

#Create CloudWatch Event Rule triggered by GuardDuty finding
resource "aws_cloudwatch_event_rule" "guardduty_finding" {
  name        = "guardduty-finding"
  description = "GuardDuty finding"

  event_pattern = <<EOF
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
EOF
}

# CloudWatch Event target that sends GuardDuty findings to an SNS topic
resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_finding.name
  target_id = "SendToSNS"
  arn       = var.sns_topic-arn-guardduty

  input_transformer {
    input_paths = {
      instance = "$.detail.resource.instanceDetails.instanceId",
      state = "$.detail.service.action.networkConnectionAction.connectionDirection"
    }

    input_template = "\"GuardDuty finding for instance: <instance>, State: <state>\""
  }
}