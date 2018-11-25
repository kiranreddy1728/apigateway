resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "mylambda"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${path.module}/lambda.zip"))}"
  memory_size      = 128
  timeout          = 120   

     vpc_config {
       subnet_ids = ["${var.subnet_ids}"] //["subnet-9e76a8f9", "subnet-2f75ab48"]
       security_group_ids = ["${var.security_group_ids}"]
   }
     environment {
    variables = {
      //AWS_SQS_URL = "${aws_sqs_queue.some_queue.id}"
      //ASG_NAME    = "${aws_autoscaling_group.some_asg.name}"
      http_proxy = "http://proxy.svpc.pre-prod.eu-west-1.aws.internal:3128"
      https_proxy = "http://proxy.svpc.pre-prod.eu-west-1.aws.internal:3128"
      no_proxy = "169.254.169.254, .hsbc"
    }
  }
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method} ${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "mylambda"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${path.module}/lambda.zip"))}"
  memory_size      = 128
  timeout          = 120   

     vpc_config {
       subnet_ids = ["${var.subnet_ids}"] //["subnet-9e76a8f9", "subnet-2f75ab48"]
       security_group_ids = ["${var.security_group_ids}"]
   }
     environment {
    variables = {
      //AWS_SQS_URL = "${aws_sqs_queue.some_queue.id}"
      //ASG_NAME    = "${aws_autoscaling_group.some_asg.name}"
      http_proxy = "http://proxy.svpc.pre-prod.eu-west-1.aws.internal:3128"
      https_proxy = "http://proxy.svpc.pre-prod.eu-west-1.aws.internal:3128"
      no_proxy = "169.254.169.254, .hsbc"
    }
  }
}

# Lambda
resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "s3.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method} ${aws_api_gateway_resource.resource.path}"
}


resource "aws_s3_bucket_notification" "ihub_load_data_s3_aurora" {
    bucket = "<bucketname>"

    lambda_function {
        lambda_function_arn = ""
        events              = ["s3:objectCreated:*"]
        filter_prefix       = "offersdata/rewardsoffers"  
        filter_suffix       = ".csv"
    }
  
}



