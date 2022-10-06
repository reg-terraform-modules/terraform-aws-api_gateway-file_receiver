locals { 
    service_name  = join("_", ["api_for",var.module_name])
    api_full_name = join("-", [var.project_name,local.service_name,var.env])
    stage_name    = join("_", [var.api_name, "api"])
    usage_plan    = join("-", [var.api_name,"usage_plan",var.env])
    api_key       = join("-", [var.api_name,"api_key", var.env])
}

resource "aws_api_gateway_rest_api" "this" {
	name = local.api_full_name
	body = data.template_file.api_setup.rendered
  tags = var.resource_tags
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_api_function_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}

data "template_file" "api_setup" {
  template = file("${path.module}/api_specification/api.yaml")
  vars = {
    api_specification_name          = local.api_full_name
    lambda_api_function_arn         = var.lambda_api_function_arn
    api_description = var.api_description
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
  stage_name    = local.stage_name
  tags = var.resource_tags
}

resource "aws_api_gateway_usage_plan" "this" {
  name = local.usage_plan

  api_stages {
    api_id = "${aws_api_gateway_rest_api.this.id}"
    stage  = "${aws_api_gateway_stage.this.stage_name}"
  }
}

resource "aws_api_gateway_api_key" "this" {
  name = local.api_key
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.this.id
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