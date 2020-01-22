# Terraform AWS Autoscaling
Terraform module to create a simple autoscaling group with alarms that trigger policies

## Usage
```hcl
module "autoscaling" {
  source = "github.com/byu-oit/terraform-aws-app-autoscaling?ref=v1.0.1"
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
        upper_bound = null
        scaling_adjustment = 1
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
```

## Inputs
| Name | Description | Default |
| --- | --- | --- |
| app_name | Application name to be used for naming resources | |
| resource_id | The resource type and unique identifier string for the resource associated with the scaling policy. See the [AWS Documentation](https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters) | |
| scalable_dimension | The scalable dimension of the scalable target. See the [AWS Documentation](https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters) | |
| service_namespace | The AWS service namespace of the scalable target. See the [AWS Documentation](https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters) | | 
| min_capacity | The minimum capacity of the scalable target | | 
| max_capacity | The max capacity of the scalable target | |
| step_up | Step scaling policy configuration for scaling out. See [below](#step_upstep_down) | |
| step_down | Step scaling policy configuration for scaling back. See [below](#step_upstep_down) | |

#### step_up/step_down
Because how tightly integrated the autoscaling policies are with the cloudwatch alarms we are passing in a complex object to define the step_up and step_down policies. 
Most of these attributes are copied from the terraform aws [appautoscaling_target](https://www.terraform.io/docs/providers/aws/r/appautoscaling_target.html),
 [appautoscaling_policy](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html), and 
 [cloudwatch_metric_alarm](https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html) provided resources.

* `adjustment_type` - (Required) Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity`, and `PercentChangeInCapacity`
* `cooldown` - (Required) The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start
* `metric_aggregation_type` - (Optional) The aggregation type for the policy's metrics. Valid values are `Minimum`, `Maximum`, and `Average`. Defaults to `Average`
* `step_adjustments` - (Required) List of `step_adjustment` objects. See [below](#step_adjustment)
* `alarm` - (Required) Configuration to create an AWS CloudWatch Metric Alarm. See [below](#alarm)

##### `step_adjustment`
* `lower_bound` - (Optional) Lower bound for the difference between the alarm threshold and the CloudWatch metric. `null` will be treated as negative infinity.
* `upper_bound` - (Optional) Upper bound for the difference between the alarm threshold and the CloudWatch metric. `null` will be treated as positive infinity.
* `scaling_adjustment`- (Required) The number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down.

Example step_up adjustments with a CloudWatch Alarm set to alarm at `CPUUtilization > 75`: 

| lower_bound | upper_bound | scaling_adjustment | description |
| --- | --- | --- | --- |
| 0 | 10 | 1 | Will add 1 instance when `75 <= CPUUtilization < 85` |
| 10 | 20 | 2 | Will add 2 instances when `85 <= CPUUtilization < 95` |
| 20 | null | 3 | Will add 3 instances when `95 <= CPUUtilization` |

Example step_down adjustments with a CloudWatch Alarm set to alarm at `CPUUtilization < 25`: 

| lower_bound | upper_bound | scaling_adjustment | description |
| --- | --- | --- | --- |
| -10 | 0 | -1 | Will remove 1 instance when `15 <= CPUUtilization < 25` |
| -20 | -10 | -2 | Will remove 2 instances when `5 <= CPUUtilization < 15` |
| null | -20 | -3 | Will remove 3 instances when `CPUUtilization < 5` |

##### `alarm`
* `namespace` - (Required) The namespace for the alarm's associated metric. See [CloudWatch Metrics docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
* `dimensions` - (Required) The dimensions for the alarm's associated metric. See the specific documentation of the metric you need in [CloudWatch Metrics docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
* `statistic` - (Optional) The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`
* `metric_name` - (Required) The name for the alarm's associated metric. See the specific documentation of the metric you need in [CloudWatch Metrics docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
* `comparison_operator` - (Required) The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: `GreaterThanOrEqualToThreshold`, `GreaterThanThreshold`, `LessThanThreshold`, `LessThanOrEqualToThreshold`.
* `threshold` - (Required) The value against which the specified statistic is compared
* `period` - (Optional) The period in seconds over which the specified `statistic` is applied. Defaults to `300`
* `evaluation_periods` - (Optional) The number of periods over which data is compared to the specified threshold. Defaults to `5`

## Outputs
| Name | Description |
| --- | --- |
| autoscaling_target | The AutoScaling Target [object](https://www.terraform.io/docs/providers/aws/r/appautoscaling_target.html) |
| autoscaling_policy_up | The AutoScaling Policy [object](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html) associated with scaling out |
| alarm_up | The CloudWatch Metric Alarm [object](https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html) associated with scaling out |
| autoscaling_policy_down | The AutoScaling Policy [object](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html) associated with scaling back |
| alarm_down | The CloudWatch Metric Alarm [object](https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html) associated with scaling back |
