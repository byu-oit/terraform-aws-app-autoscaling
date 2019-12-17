locals {
  default_metric_aggregation_type = "Average"
  default_alarm_statistic = "Average"
  default_alarm_period = 300
  default_alarm_evaluation_periods = 5
}

resource "aws_appautoscaling_target" "main" {
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  resource_id = var.resource_id
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
}

resource "aws_appautoscaling_policy" "up" {
  name = "${var.app_name}-autoscale-step-up"
  resource_id = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace = aws_appautoscaling_target.main.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = var.step_up.adjustment_type
    metric_aggregation_type = var.step_up.metric_aggregation_type != null ? var.step_up.metric_aggregation_type : local.default_metric_aggregation_type
    cooldown = var.step_up.cooldown

    dynamic "step_adjustment" {
      for_each = toset(var.step_up.step_adjustments)
      content {
        scaling_adjustment = step_adjustment.value.scaling_adjustment
        metric_interval_lower_bound = step_adjustment.value.lower_bound
        metric_interval_upper_bound = step_adjustment.value.upper_bound
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name = "${var.app_name}-alarm-step-up"
  namespace = var.step_up.alarm.namespace
  dimensions = var.step_up.alarm.dimensions
  statistic = var.step_up.alarm.statistic != null ? var.step_up.alarm.statistic : local.default_alarm_statistic
  metric_name = var.step_up.alarm.metric_name
  comparison_operator = var.step_up.alarm.comparison_operator
  threshold = var.step_up.alarm.threshold

  period = var.step_up.alarm.period != null ? var.step_up.alarm.period : local.default_alarm_period
  evaluation_periods = var.step_up.alarm.evaluation_periods != null ? var.step_up.alarm.evaluation_periods : local.default_alarm_evaluation_periods

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_appautoscaling_policy" "down" {
  name = "${var.app_name}-autoscale-step-down"
  resource_id = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace = aws_appautoscaling_target.main.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = var.step_down.adjustment_type
    metric_aggregation_type = var.step_down.metric_aggregation_type != null ? var.step_down.metric_aggregation_type : local.default_metric_aggregation_type
    cooldown = var.step_down.cooldown

    dynamic "step_adjustment" {
      for_each = toset(var.step_down.step_adjustments)
      content {
        scaling_adjustment = step_adjustment.value.scaling_adjustment
        metric_interval_lower_bound = step_adjustment.value.lower_bound
        metric_interval_upper_bound = step_adjustment.value.upper_bound
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name = "${var.app_name}-alarm-step-down"
  namespace = var.step_down.alarm.namespace
  dimensions = var.step_down.alarm.dimensions
  statistic = var.step_down.alarm.statistic != null ? var.step_down.alarm.statistic : local.default_alarm_statistic
  metric_name = var.step_down.alarm.metric_name
  comparison_operator = var.step_down.alarm.comparison_operator
  threshold = var.step_down.alarm.threshold

  period = var.step_down.alarm.period != null ? var.step_down.alarm.period : local.default_alarm_period
  evaluation_periods = var.step_down.alarm.evaluation_periods != null ? var.step_down.alarm.evaluation_periods : local.default_alarm_evaluation_periods

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}