#### Lambda ####

resource "aws_iam_role" "lambda_hello_world" {
  name = "lambda_hello_world"

  assume_role_policy = data.aws_iam_policy_document.lambda_hello_world.json
}


data "aws_iam_policy_document" "lambda_hello_world" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_function" "hello_world" {
  filename      = "hello_world.zip"
  function_name = "hello_world"
  role          = aws_iam_role.lambda_hello_world.arn
  handler       = "src.main.hello_world"

  source_code_hash = filebase64sha256("src/main.py")

  runtime = "python3.8"
}


#### AppSync Wiring ####

data "aws_iam_policy_document" "hello_world_service" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hello_world" {
  name = "hello_world_service_role"

  assume_role_policy = data.aws_iam_policy_document.hello_world_service.json
}


data "aws_iam_policy_document" "hello_world" {
  statement {
    sid = "1"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [aws_lambda_function.hello_world.arn]
  }
}

resource "aws_iam_role_policy" "hello_world" {
  name   = "hello_world_role_policy"
  role   = aws_iam_role.hello_world.id
  policy = data.aws_iam_policy_document.hello_world.json
}

resource "aws_appsync_datasource" "hello_world" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "hello_world"
  service_role_arn = aws_iam_role.hello_world.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = aws_lambda_function.hello_world.arn
  }
}

resource "aws_appsync_function" "hello_world_lambda" {
  api_id                   = aws_appsync_graphql_api.main.id
  data_source              = "hello_world"
  name                     = "hello_world_lambda"
  request_mapping_template = <<EOF
    {
        "version": "2017-02-28",
        "operation": "Invoke",
        "payload": {
            "field": "helloWorld",
            "arguments":  $utils.toJson({"greeting": $ctx.args.greeting})
        }
    }
  EOF

  response_mapping_template = <<EOF
    $utils.toJson($context.result)
  EOF
}

resource "aws_appsync_resolver" "hello_world_lambda" {
  type              = "Query"
  api_id            = aws_appsync_graphql_api.main.id
  field             = "helloWorldLambda"
  request_template  = "{}"
  response_template = "$util.toJson($ctx.prev.result)"
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.hello_world_lambda.function_id
    ]
  }
}

