# Deployment Process

To deploy the application on a new AWS account, follow these steps:

1. **Set Up AWS Credentials**: Ensure your AWS credentials are configured in your environment or CircleCI project settings.

2. **Clone the Repository**: Clone the project repository to your local machine.

3. **Build the Lambda Packages**: Run the `build.sh` script to package the Lambda functions.

4. **Deploy with Terraform**: Run the `deploy.sh` script to deploy the infrastructure.

5. **Configure CircleCI**: Set up a CircleCI project and add the repository. Ensure the necessary environment variables are set.

6. **Run the Pipeline**: The CircleCI pipeline will automatically run tests, lint the code, build artifacts, and deploy the application.

7. **Confirm SNS Subscription**: Check your email and confirm the SNS subscription to start receiving notifications. 