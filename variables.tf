variable "app_name" {
  type = string
  description = "Application name to be used for naming resources"
}
variable "resource_id" {
  type = string
  description = "The resource type and unique identifier string for the resource associated with the scaling policy"
}
variable "scalable_dimension" {
  type = string
  description = "The scalable dimension of the scalable target"
}
variable "service_namespace" {
  type = string
  description = "The AWS service namespace of the scalable target"
}
variable "min_capacity" {
  type = number
  description = "The minimum capacity of the scalable target"
}
variable "max_capacity" {
  type = number
  description = "The max capacity of the scalable target"
}

variable "step_up" {
  type = object({
    adjustment_type = string
    cooldown = number
    metric_aggregation_type = string // default = "Average"

    step_adjustments = list(object({
      lower_bound = number
      upper_bound = number
      scaling_adjustment = number
    }))

    alarm = object({
      namespace = string
      dimensions = map(string)
      statistic = string // default = "Average"
      metric_name = string
      comparison_operator = string
      threshold = number
      period = number // default = 300
      evaluation_periods = number // default = 5
    })
  })
  description = "Step scaling policy configuration for scaling out"
}
variable "step_down" {
  type = object({
    adjustment_type = string
    cooldown = number
    metric_aggregation_type = string // default = "Average"

    step_adjustments = list(object({
      lower_bound = number
      upper_bound = number
      scaling_adjustment = number
    }))

    alarm = object({
      namespace = string
      dimensions = map(string)
      statistic = string // default = "Average"
      metric_name = string
      comparison_operator = string
      threshold = number
      period = number // default = 300
      evaluation_periods = number // default = 5
    })
  })
  description = "Step scaling policy configuration for scaling back"
}
variable "tags" {
  type = map(string)
  description = "Tags to attach to Fargate service and task definition and other resources. Defaults to {}"
  default = {}
}
