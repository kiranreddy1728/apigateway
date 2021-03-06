#API Creation
resource "aws_api_gateway_rest_api" "rewardsapi" {
  name        = "rewardsapi"
  description = "Rewards Application api gateway ID"
}

#Resorce Creation
resource "aws_api_gateway_resource" "resource1" {
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.rewardsapi.root_resource_id}"
  path_part   = "rewards"
}

# Another Resoucre creation
resource "aws_api_gateway_resource" "resource2" {
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.rewardsapi.resource1.id}"
  path_part   = "{id}"
}

# Method Creation
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.rewardsapi.id}"
  resource_id   = "${aws_api_gateway_resource.resource2.id}"
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
    request_parameters {
        "method.request.path.id" = true
    }
}

# Intergration Creation
resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  resource_id = "${aws_api_gateway_resource.resource2.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type        = "AWS"
  uri         = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/${aws_lambda_function.apigatwayprod.arn}/invocations"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_parameters {
      "integration.request.path.id" = "method.request.path.id"
  }
  request_templates = {
      "application/json" = "${file("api_gateway_body_mapping.template")}"
  }
}

# Method Response
resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  resource_id = "${aws_api_gateway_resource.resource2.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  response_models = {
      "application/json" = "Empty"
  }
}

# IntegrationResponse

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  resource_id = "${aws_api_gateway_resource.resource2.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  #response_models = {
   #   "application/json" = "Empty"
  #}
}

# Deployment Creation
resource "aws_api_gateway_deployment" "Deployment" {
  depends_on = ["aws_api_gateway_integration.integration"]
  rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
  stage_name  = "PROD"

  variables = {
    "answer" = "42"
  }
}

# ApiKey Creation
resource "aws_api_gateway_api_key" "ApiKey" {
  name = "Apikeyprod"

  stage_key {
    rest_api_id = "${aws_api_gateway_rest_api.rewardsapi.id}"
    stage_name  = "${aws_api_gateway_deployment.Deployment.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan" "usageplan" {
  name = "usage_plan_prod"
}

resource "aws_api_gateway_usage_plan_key" "plan" {
  key_id        = "${aws_api_gateway_api_key.ApiKey.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.usageplan.id}"
}

# Output DNS origin
output "dns" {
  value = "${aws_api_gateway_rest_api.rewardsapi.id}.execute-api.$(var.region).amazon.com"
}


