output "arn" {
    value = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
    value = aws_api_gateway_rest_api.this.execution_arn
}

output "id" {
    value = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
    value = aws_api_gateway_deployment.this.invoke_url
}