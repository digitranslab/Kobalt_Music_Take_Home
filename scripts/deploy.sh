#!/bin/bash

# Navigate to the infra directory where Terraform configuration is located
cd infra

# Initialize Terraform to set up the backend and prepare the working directory
terraform init

# Apply the Terraform configuration to deploy resources, using auto-approve to skip interactive approval
terraform apply -auto-approve -var="region=eu-west-1" -var="aws_account_number=123456789012"