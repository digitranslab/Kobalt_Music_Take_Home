import pytest

from backend.lambdas.check_service.handler import lambda_handler


def test_lambda_handler(emr_client, sns_client, cloudwatch_client):
    # Create a mock SNS topic
    topic_arn = sns_client.create_topic(Name='emr_notifications')['TopicArn']

    # Create a mock EMR cluster
    emr_client.run_job_flow(
        Name='temp-ad-hoc-test-cluster',
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

    # Check if the SNS message was published
    response = sns_client.list_topics()
    assert any(topic['TopicArn'] == topic_arn for topic in response['Topics'])

    # Check if the CloudWatch dashboard was updated
    response = cloudwatch_client.list_dashboards()
    assert any(dashboard['DashboardName'] == 'EMR-Metrics-Dashboard' for dashboard in response['DashboardEntries'])
