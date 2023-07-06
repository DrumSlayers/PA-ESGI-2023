resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name          = "${var.instance-name} High CPU Usage"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "60" # 60 seconds for reactive alarm
    alarm_description   = "This metric triggers when CPU usage is above 80% for more than 60 seconds (or 1 evaluation period)"
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
  ],
    "detail": {
    "severity": [
      4,
      4.0,
      4.1,
      4.2,
      4.3,
      4.4,
      4.5,
      4.6,
      4.7,
      4.8,
      4.9,
      5,
      5.0,
      5.1,
      5.2,
      5.3,
      5.4,
      5.5,
      5.6,
      5.7,
      5.8,
      5.9,
      6,
      6.0,
      6.1,
      6.2,
      6.3,
      6.4,
      6.5,
      6.6,
      6.7,
      6.8,
      6.9,
      7,
      7.0,
      7.1,
      7.2,
      7.3,
      7.4,
      7.5,
      7.6,
      7.7,
      7.8,
      7.9,
      8,
      8.0,
      8.1,
      8.2,
      8.3,
      8.4,
      8.5,
      8.6,
      8.7,
      8.8,
      8.9
    ]
  }

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
      severity = "$.detail.severity",
      region = "$.region",
      account = "$.account",
      FindingType = "$.detail.type",
      FindingDescription = "$.detail.description"
    }

    input_template = "\"GuardDuty finding for instance: <instance>, State: <state>\""
  }
}