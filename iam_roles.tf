#
# Instance profile for bastion host
#

resource "aws_iam_instance_profile" "instance_profile_adwriter" {
  role = "${aws_iam_role.iam_role_adwriter.name}"
}

resource "aws_iam_role" "iam_role_adwriter" {
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy_allow_all_ssm" {
  role = "${aws_iam_role.iam_role_adwriter.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:ListAssociations",
                "ssm:GetDocument",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
