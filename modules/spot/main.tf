## for SSM
resource "aws_iam_role" "SSMRole" {
  name               = "SSMRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "SSM-instance-profile" {
  name = "SSM-instance-profile"
  role = aws_iam_role.SSMRole.name
}

resource "aws_iam_policy_attachment" "SSM-policy-attachment" {
  name       = "SSM-policy-attachment"
  roles      = [aws_iam_role.SSMRole.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## SG
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg"
  vpc_id      = var.VPCID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## SpotInstance
resource "aws_spot_instance_request" "test" {
  ami                            = "ami-0c16ff0f860575572"
  associate_public_ip_address    = true
  instance_type                  = "t3.small"
  iam_instance_profile           = aws_iam_instance_profile.SSM-instance-profile.name
  vpc_security_group_ids         = [aws_security_group.sg.id]
  subnet_id                      = var.public1ID
  spot_type                      = "one-time"
  instance_interruption_behavior = "terminate"
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "test-spot"
  }
}

resource "aws_ec2_tag" "tag" {
  resource_id = aws_spot_instance_request.test.spot_instance_id
  key         = "Name"
  value       = "SpotTest"
}

## CloudwatchLogs
resource "aws_cloudwatch_log_group" "log" {
  name              = "/fis/logs/"
  retention_in_days = 1
}

## FIS IAMRole
resource "aws_iam_role" "FISRole" {
  name               = "FISRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "fis.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "FIS-policy-attachment" {
  role       = aws_iam_role.FISRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
}

resource "aws_iam_role_policy_attachment" "FIS-Logs-policy-attachment" {
  role       = aws_iam_role.FISRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}