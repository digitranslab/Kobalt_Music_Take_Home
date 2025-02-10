import boto3
from aws_lambda_powertools import Logger, Metrics
from aws_lambda_powertools.metrics import MetricUnit
from botocore.exceptions import BotoCoreError, ClientError

# Initialize logger and metrics
logger = Logger()
metrics = Metrics()

@logger.inject_lambda_context
@metrics.log_metrics
def lambda_handler(event, context):
    """
    Lambda function to create or update a CloudWatch dashboard with metrics for EMR clusters.
    It fetches the list of EMR clusters and creates a widget for each cluster on the dashboard.

    Parameters:
    event (dict): AWS Lambda uses this parameter to pass in event data to the handler.
    context (object): AWS Lambda uses this parameter to provide runtime information to your handler.

    Returns:
    None
    """
    try:
        # Initialize CloudWatch and EMR clients
        cloudwatch = boto3.client('cloudwatch')
        emr_client = boto3.client('emr')

        # Fetch EMR cluster metrics
        clusters = emr_client.list_clusters(ClusterStates=['RUNNING', 'WAITING', 'TERMINATED'])
        widgets = []

        for cluster in clusters['Clusters']:
            # Extract cluster details
            cluster_id = cluster['Id']
            cluster_name = cluster['Name']
            cluster_state = cluster['Status']['State']
            failure_reason = cluster['Status'].get('StateChangeReason', {}).get('Message', 'N/A')

            # Create a widget for each cluster
            widgets.append({
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/EMR", "IsIdle", "JobFlowId", cluster_id],
                        [".", "RunningMapTasks", ".", "."],
                        [".", "RunningReduceTasks", ".", "."]
                    ],
                    "title": f"EMR Cluster: {cluster_name} - {cluster_state}",
                    "view": "timeSeries",
                    "stacked": False,
                    "region": "eu-west-1"
                }
            })

        # Define the dashboard body with all widgets
        dashboard_body = {
            "widgets": widgets
        }

        # Create or update the CloudWatch dashboard
        cloudwatch.put_dashboard(
            DashboardName='EMR-Metrics-Dashboard',
            DashboardBody=str(dashboard_body)
        )
        logger.info("Dashboard created successfully.")
        metrics.add_metric(name="DashboardsCreated", unit=MetricUnit.Count, value=1)
    except (BotoCoreError, ClientError) as error:
        # Log and record any errors encountered
        logger.error(f"Error interacting with AWS services: {error}")
        metrics.add_metric(name="Errors", unit=MetricUnit.Count, value=1) 