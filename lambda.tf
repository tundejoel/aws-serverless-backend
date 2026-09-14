# Zip the Python file so Lambda can accept it
data "archive_file" "visit_counter" {
  type        = "zip"
  source_file = "${path.module}/lambda/visit_counter.py"
  output_path = "${path.module}/build/visit_counter.zip"
}

# Keep logs 14 days instead of forever
resource "aws_cloudwatch_log_group" "visit_counter" {
  name              = "/aws/lambda/portfolio-visit-counter"
  retention_in_days = 14
}

resource "aws_lambda_function" "visit_counter" {
  function_name    = "portfolio-visit-counter"
  role             = aws_iam_role.visit_counter.arn
  runtime          = "python3.13"
  handler          = "visit_counter.handler"
  filename         = data.archive_file.visit_counter.output_path
  source_code_hash = data.archive_file.visit_counter.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visits.name
    }
  }

  tags = {
    Project = "aws-serverless-backend"
  }

  depends_on = [aws_cloudwatch_log_group.visit_counter]
}