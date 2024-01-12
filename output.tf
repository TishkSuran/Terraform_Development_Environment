output "used_availability_zone" {
  value = data.aws_availability_zones.good_zones.names[0]
}