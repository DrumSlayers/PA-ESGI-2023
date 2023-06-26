# Enable GuardDuty option is 'ONE_HOUR' or 'SIX_HOURS' or 'FIFTEEN_MINUTES'
resource "aws_guardduty_detector" "primary" {
  enable = true
  finding_publishing_frequency = "SIX_HOURS"
}