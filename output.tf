output "autoscaling_target" {
  value = aws_appautoscaling_target.main
}
output "autoscaling_policy_up" {
  value = aws_appautoscaling_policy.up
}
output "alarm_up" {
  value = aws_cloudwatch_metric_alarm.up
}
output "autoscaling_policy_down" {
  value = aws_appautoscaling_policy.down
}
output "alarm_down" {
  value = aws_cloudwatch_metric_alarm.down
}
