import sys
from mock import MagicMock
from os import path

import pytest
import boto3
from moto import mock_emr, mock_sns, mock_cloudwatch


def pytest_configure(config):
    sys.path.append(path.join("backend", "lambdas", "check_service"))
    sys.path.append(path.join("backend", "lambdas", "front_service"))
    sys.path.append(path.join("backend", "lambdas", "monitor_service"))


@pytest.fixture(scope='function')
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    boto3.setup_default_session()
    yield
    boto3.DEFAULT_SESSION = None

@pytest.fixture(scope='function')
def emr_client(aws_credentials):
    with mock_emr():
        yield boto3.client('emr', region_name='eu-west-1')

@pytest.fixture(scope='function')
def sns_client(aws_credentials):
    with mock_sns():
        yield boto3.client('sns', region_name='eu-west-1')

@pytest.fixture(scope='function')
def cloudwatch_client(aws_credentials):
    with mock_cloudwatch():
        yield boto3.client('cloudwatch', region_name='eu-west-1')