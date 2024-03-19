output "vpc-id" {
  value = data.aws_vpc.default.id
}

output "subnet-ids" {
  value = [for subnet in data.aws_subnet.default : subnet.id]
}

