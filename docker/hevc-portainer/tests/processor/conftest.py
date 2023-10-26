import os
import pytest
import boto3
import tempfile

from moto import mock_s3

@pytest.fixture
def aws_credentials():
    os.environ["AWS_DEFAULT_REGION"] = "eu-west-1"
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"

@pytest.fixture
def bucket():
    bucket = 'non-existing'
    os.environ['BUCKET'] = bucket
    return bucket

@pytest.fixture
def s3(bucket, aws_credentials):
    with mock_s3():
        s3 = boto3.client('s3')
        s3.create_bucket(
            Bucket=bucket,
            CreateBucketConfiguration={'LocationConstraint': os.environ['AWS_DEFAULT_REGION']}
        )
        yield s3

@pytest.fixture
def basedir():
    with tempfile.TemporaryDirectory() as basedir:
        yield basedir
