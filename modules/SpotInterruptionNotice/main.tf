## SNS

resource "aws_sns_topic" "topic" {
  name       = "spot-notice-topic"
  fifo_topic = false
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.topic.arn]
  }
}

## EventBridge
resource "aws_cloudwatch_event_rule" "spot-interruption-rule" {
  name           = "spot-interruption-rule"
  event_bus_name = "default"

  tags = {
    Name = "spot-interruption-rule"
  }

  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Spot Instance Interruption Warning"]
}
EOF
}

resource "aws_cloudwatch_event_target" "sns" {
  rule = aws_cloudwatch_event_rule.spot-interruption-rule.name
  arn  = aws_sns_topic.topic.arn
}