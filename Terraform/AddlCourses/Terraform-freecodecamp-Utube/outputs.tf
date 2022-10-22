# Outputs

output "dev_public_ip" {
    value = aws_instance.uu-dev-instance.public_ip  
}