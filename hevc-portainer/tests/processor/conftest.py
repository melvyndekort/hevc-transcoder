import os
import pytest

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
