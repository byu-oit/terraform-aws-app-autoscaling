variable "app_name" {
  type = string
}
variable "resource_id" {
  type = string
}
variable "scalable_dimension" {
  type = string
}
variable "service_namespace" {
  type = string
}
variable "min_capacity" {
  type = number
}
variable "max_capacity" {
  type = number
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
}
