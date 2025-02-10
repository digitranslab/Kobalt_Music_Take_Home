import boto3
import os
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
    Lambda function to check for running EMR clusters with names starting with 'temp-ad-hoc-'.
    If such clusters are found, it sends a notification via SNS and updates a CloudWatch dashboard
    with the cluster states.

    Parameters:
    event (dict): AWS Lambda uses this parameter to pass in event data to the handler.
    context (object): AWS Lambda uses this parameter to provide runtime information to your handler.

    Returns:
    None
    """
    try:
        # Initialize EMR, SNS, and CloudWatch clients with the specified region
        emr_client = boto3.client('emr', region_name=os.environ['REGION'])
        sns_client = boto3.client('sns', region_name=os.environ['REGION'])
        cloudwatch = boto3.client('cloudwatch', region_name=os.environ.get('REGION'))
        
        # Retrieve the AWS account number from environment variables
        project_number = os.environ.get('AWS_ACCOUNT_NUMBER')
        
        # Construct the TopicArn using the environment variable
        topic_arn = f'arn:aws:sns:{os.environ.get("REGION")}:{project_number}:emr_notifications'
        
        # List all running or waiting EMR clusters
        clusters = emr_client.list_clusters(ClusterStates=['RUNNING', 'WAITING'])
        
        # Filter clusters with names starting with "temp-ad-hoc-"
        temp_clusters = [
            cluster for cluster in clusters['Clusters']
            if cluster['Name'].startswith('temp-ad-hoc-')
        ]
        
        if temp_clusters:
            # Send notification if temporary clusters are found
            message = f"Temporary clusters still running: {[c['Name'] for c in temp_clusters]}"
            sns_client.publish(
                TopicArn=os.environ['SNS_TOPIC_ARN'],
                Message=message,
                Subject='Temporary EMR Clusters Check'
            )
            logger.info(f"Notification sent for clusters: {temp_clusters}")
            metrics.add_metric(name="TempClustersFound", unit=MetricUnit.Count, value=len(temp_clusters))
            
            # Update CloudWatch dashboard with cluster states
            widgets = []
            for cluster in clusters['Clusters']:
                cluster_id = cluster['Id']
                cluster_name = cluster['Name']
                cluster_state = cluster['Status']['State']
                
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
                        "region": os.environ.get('REGION')
                    }
                })
            
            dashboard_body = {
                "widgets": widgets
            }
            
            cloudwatch.put_dashboard(
                DashboardName='EMR-Metrics-Dashboard',
                DashboardBody=str(dashboard_body)
            )
            logger.info("Dashboard updated successfully.")
        else:
            logger.info("No temporary clusters found.")
    except (BotoCoreError, ClientError) as error:
        # Log and record any errors encountered
        logger.error(f"Error interacting with AWS services: {error}")
        metrics.add_metric(name="Errors", unit=MetricUnit.Count, value=1) 