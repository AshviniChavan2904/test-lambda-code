provider "aws" {
  region = "us-west-2"
}

data "aws_s3_bucket" "test_bucket" {
  bucket = "my-hello-world-lambda-functions-bucket"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name    = "hello-world-lambda"
  s3_bucket        = data.aws_s3_bucket.test_bucket.id
  s3_key           = "hello-world-lambda.zip"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("hello-world-lambda.zip")
}