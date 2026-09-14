# Who may wear this badge: the Lambda service
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "visit_counter" {
  name               = "visit-counter-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# What the badge allows: update items in this one table only
data "aws_iam_policy_document" "visit_counter_dynamodb" {
  statement {
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visits.arn]
  }
}

resource "aws_iam_role_policy" "visit_counter_dynamodb" {
  name   = "visit-counter-dynamodb"
  role   = aws_iam_role.visit_counter.id
  policy = data.aws_iam_policy_document.visit_counter_dynamodb.json
}

# Logging: an AWS-managed policy that only allows writing to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "visit_counter_logs" {
  role       = aws_iam_role.visit_counter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}