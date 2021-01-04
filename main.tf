#### AppSync #### 

resource "aws_appsync_graphql_api" "main" {
  authentication_type = "AWS_IAM"
  name                = "terraforming-appsync"
  schema              = file("${path.module}/schema.graphql")

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.graph_log_role.arn
    field_log_level          = "ALL"
    exclude_verbose_content  = false
  }

  additional_authentication_provider {
    authentication_type = "API_KEY"
  }
}

resource "aws_cloudwatch_log_group" "graph" {
  name = "graph"

  tags = {
    application = "graph"
  }
}

#### AppSync Utilities ####

data "aws_iam_policy_document" "graph_log_role" {
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

resource "aws_iam_role" "graph_log_role" {
  name = "graph_log_role"

  assume_role_policy = data.aws_iam_policy_document.graph_log_role.json
}

data "aws_iam_policy_document" "graph_log_policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "graph_log" {
  name   = "graph_log_policy"
  role   = aws_iam_role.graph_log_role.id
  policy = data.aws_iam_policy_document.graph_log_policy.json
}
