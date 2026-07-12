locals {
  tags = {
    Environment = var.environment
    Project     = "Stack Azure IAC"
    ManagedBy   = "Terraform"
  }
}
