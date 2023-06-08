resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name          = "${var.instance-id} High-CPU-Usage"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "60"
    alarm_description   = "This metric triggers when CPU usage is above 80%"
    alarm_actions       = [var.sns_topic-arn]
    dimensions = {
        InstanceId = var.instance-id
    }
    statistic     = "SampleCount"
    threshold     = "80"
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
    alarm_name          = "${var.instance-id} Status-Check-Failed"
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
    threshold     = "1"
}