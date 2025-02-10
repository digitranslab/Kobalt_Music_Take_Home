import pytest

from backend.lambdas.monitor_service.handler import lambda_handler


def test_lambda_handler(emr_client, cloudwatch_client):
    # Create a mock EMR cluster
    emr_client.run_job_flow(
        Name='test-cluster',
        Instances={
            'InstanceCount': 1,
            'MasterInstanceType': 'm1.small',
            'SlaveInstanceType': 'm1.small',
            'Placement': {'AvailabilityZone': 'us-west-2a'},
        },
        JobFlowRole='EMR_EC2_DefaultRole',
        ServiceRole='EMR_DefaultRole',
    )

    # Invoke the Lambda function
    lambda_handler({}, {})

    # Check if the CloudWatch dashboard was created
    response = cloudwatch_client.list_dashboards()
    assert any(dashboard['DashboardName'] == 'EMR-Metrics-Dashboard' for dashboard in response['DashboardEntries'])
