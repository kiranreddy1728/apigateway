#https://andydote.co.uk/2017/03/17/terraform-aws-lambda-api-gateway/
#https://stackoverflow.com/questions/39040739/in-terraform-how-do-you-specify-an-api-gateway-endpoint-with-a-variable-in-the
#https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
#https://www.terraform.io/docs/providers/aws/r/api_gateway_integration_response.html



resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.MyDemoAPI.root_resource_id}"
  path_part   = "test"
}
resource "aws_api_gateway_resource" "accounts" {
    rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
    parent_id = "${aws_api_gateway_resource.MyDemoResource.id}"
    path_part = "{accounts}"
}
/*
// Unit
resource "aws_api_gateway_resource" "account" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  parent_id = "${aws_api_gateway_resource.accounts.id}"
  path_part = "{accountId}"
}
*/
resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id   = "${aws_api_gateway_resource.accounts.id}"
  http_method   = "GET"
  authorization = "NONE"
    request_parameters {
    "method.request.path.accountId" = true
  }
}
/*
resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id = "${aws_api_gateway_resource.accounts.id}"
  http_method = "${aws_api_gateway_method.MyDemoMethod.http_method}"
  type        = "MOCK"
}
*/
resource "aws_api_gateway_integration" "MyDemoIntegration" {
    rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
    resource_id = "${aws_api_gateway_resource.accounts.id}"
    http_method = "${aws_api_gateway_method.MyDemoMethod.http_method}"
   # type = "HTTP"
    type        = "MOCK"
    integration_http_method = "GET"
    uri = "/integration/accounts/{id}"
    passthrough_behavior = "WHEN_NO_MATCH"

    request_parameters {
        "integration.request.path.id" = "method.request.path.accountId"
    }
}

resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = ["aws_api_gateway_integration.MyDemoIntegration"]

  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  stage_name  = "test"

  variables = {
    "answer" = "42"
  }
}
