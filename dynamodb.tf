resource "aws_dynamodb_table" "visits" {
  name         = "portfolio-visits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "aws-serverless-backend"
  }
}