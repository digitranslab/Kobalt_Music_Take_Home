#!/bin/bash

# Navigate to the backend directory for the checker Lambda function
cd backend/checker

# Zip the Lambda function for checking EMR clusters
zip check_emr.zip check_emr.py

# Navigate to the monitor directory for the dashboard Lambda function
cd ../monitor

# Zip the Lambda function for creating the CloudWatch dashboard
zip monitor_service.zip monitor_service.py

# Navigate to the frontservice directory for the FastAPI Lambda function
cd ../frontservice

# Zip the FastAPI Lambda function
zip app.zip app.py

# Build the frontend application
cd ../../frontend
npm install
npm run build

# Build Docker image for frontend
docker build -t your-dockerhub-username/frontend:latest .
docker push your-dockerhub-username/frontend:latest 