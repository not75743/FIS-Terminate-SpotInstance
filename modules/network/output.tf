output "VPCID" {
  value = aws_vpc.vpc.id
}

output "public1ID" {
  value = aws_subnet.public1.id
}

output "public2ID" {
  value = aws_subnet.public2.id
}