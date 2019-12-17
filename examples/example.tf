provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "autoscaling" {
  source = "git@github.com:byu-oit/terraform-aws-app-autoscaling.git?ref=v1.0.0"
//  source = "../"
  app_name = "example"
  resource_id = "service/example/example"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  min_capacity = 1
  max_capacity = 3
  step_up = {
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    metric_aggregation_type = null // use default
    step_adjustments = [
      {
        lower_bound = 0
        upper_bound = 10
        scaling_adjustment = 1
      },
      {
        lower_bound = 10
        upper_bound = null
        scaling_adjustment = 2
      }
    ]

    alarm = {
      namespace = "AWS/ECS"
      dimensions = {
        ClusterName = "example"
        ServiceName = "example"
      }
      statistic = null // use default
      metric_name = "CPUUtilization"
      comparison_operator = "GreaterThanThreshold"
      threshold = 75
      period = null // use default
      evaluation_periods = null // use default
    }
  }

  step_down = {
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    metric_aggregation_type = null // use default
    step_adjustments = [
      {
        lower_bound = null
        upper_bound = -10
        scaling_adjustment = -2
      },
      {
        lower_bound = -10
        upper_bound = 0
        scaling_adjustment = -1
      }
    ]

    alarm = {
      namespace = "AWS/ECS"
      dimensions = {
        ClusterName = "example"
        ServiceName = "example"
      }
      statistic = null // use default
      metric_name = "CPUUtilization"
      comparison_operator = "LessThanThreshold"
      threshold = 25
      period = null // use default
      evaluation_periods = null // use default
    }
  }
}