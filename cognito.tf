 resource "aws_cognito_identity_pool" "main" {
      identity_pool_name               = "testnabcognito"
      allow_unauthenticated_identities = false
 }

  resource "aws_cognito_identity_pool_roles_attachment" "main" {
      identity_pool_id = aws_cognito_identity_pool.main.id

      roles = {
           authenticated   = aws_iam_role.auth_iam_role.arn
           unauthenticated = aws_iam_role.unauth_iam_role.arn
      }
 }

 resource "aws_iam_role" "auth_iam_role" {
      name = "auth_iam_role"
      assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Federated": "cognito-identity.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
 EOF
 }

 resource "aws_iam_role" "unauth_iam_role" {
      name = "unauth_iam_role"
      assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Action": "sts:AssumeRole",
 		"Principal": {
 			"Federated": "cognito-identity.amazonaws.com"
 		},
 		"Effect": "Allow",
 		"Sid": ""
 	  }
  ]
 }
 EOF
 }

  resource "aws_iam_role_policy" "web_iam_unauth_role_policy" {
      name = "web_iam_unauth_role_policy"
      role = aws_iam_role.unauth_iam_role.id
      policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "mobileanalytics:PutEvents",
                "cognito-sync:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
 EOF
 }

 resource "aws_iam_role_policy" "web_iam_auth_role_policy" {
      name = "web_iam_auth_role_policy"
      role = aws_iam_role.auth_iam_role.id
      policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "mobileanalytics:PutEvents",
                "cognito-sync:*",
                "cognito-identity:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
 EOF
 }


