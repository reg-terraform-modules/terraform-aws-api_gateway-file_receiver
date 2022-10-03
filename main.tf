resource "aws_api_gateway_rest_api" "this" {
  api_name = name = join("-", [var.project_name, var.module_name, var.env])
	name = join("-", [var.project_name, var.module_name, var.env])
	body = data.template_file.api_setup.rendered
  tags = var.resource_tags
}

data "template_file" "api_setup" {
  template = file("${path.module}/api_specification/api.yaml")
  vars = {
    api_specification_name          = var.module_name
    iam_api_role_arn                = var.iam_api_role_arn
    api_description                 = var.api_description
  }
}

resource "aws_api_gateway_deployment" "this" {
	rest_api_id = aws_api_gateway_rest_api.this.id
	
    triggers = {
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.module_name
  tags = var.resource_tags
}

resource "aws_api_gateway_usage_plan" "this" {
  name = join("", [local.api_name, "-usage_plan-", var.env])

  api_stages {
    api_id = "${aws_api_gateway_rest_api.this.id}"
    stage  = "${aws_api_gateway_stage.this.stage_name}"
  }
}

resource "aws_api_gateway_api_key" "apikey" {
  name = join("", [local.api_name, "-api_key-", var.env])
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

