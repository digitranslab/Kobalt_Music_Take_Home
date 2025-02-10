# EMR Monitoring and Notification System

## Context

In cloud environments, temporary resources are often created for ad-hoc tasks. These resources, if not managed properly, can lead to unnecessary costs. The goal is to implement a notification mechanism that checks for temporary resources (with a specific prefix) left running in the cloud account. This system should:

- Use Infrastructure as Code (IaC) to create checks in the cloud account.
- Run checks daily at 6 PM.
- Focus on a specific resource type, such as AWS EMR.
- Report resources with names starting with "temp-ad-hoc-".
- Send notifications to a configurable email or Slack channel.

![High Level Design](docs/assets/design.png?raw=true "High Level Design")

## Solution

Our solution leverages AWS services and automation tools to efficiently monitor and notify about temporary EMR clusters:

- **AWS Lambda Functions**: Two functions are implemented:
  - `check_emr.py`: Checks for EMR clusters with the specified prefix and sends notifications via SNS.
  - `monitor_service.py`: Creates a CloudWatch dashboard to visualize EMR metrics.
  
- **AWS CloudWatch**: Schedules the Lambda functions to run daily at 6 PM.

- **AWS SNS**: Sends notifications to a specified email address.

- **Terraform**: Manages the deployment of AWS resources, ensuring consistent and repeatable infrastructure setup.

- **CircleCI**: Automates testing, linting, building, and deploying the application.

## Deployment Process

1. **Set Up AWS Credentials**: Ensure your AWS credentials are configured in your environment or CircleCI project settings.

2. **Clone the Repository**: Clone the project repository to your local machine.

3. **Build the Lambda Packages**: Run the `build.sh` script to package the Lambda functions.

   ```bash
   bash scripts/build.sh
   ```

4. **Deploy with Terraform**: Run the `deploy.sh` script to deploy the infrastructure.

   ```bash
   bash scripts/deploy.sh
   ```

5. **Configure CircleCI**: Set up a CircleCI project and add the repository. Ensure the following environment variables are set in CircleCI:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

6. **Run the Pipeline**: The CircleCI pipeline will automatically run tests, lint the code, build artifacts, and deploy the application.

7. **Confirm SNS Subscription**: Check your email and confirm the SNS subscription to start receiving notifications.

This setup ensures efficient monitoring and notification of temporary EMR clusters, helping manage cloud resources effectively.