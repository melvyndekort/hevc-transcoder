import os
import boto3
import pytest

from moto import mock_s3
from botocore.exceptions import ClientError

@pytest.fixture
def s3(aws_credentials):
    with mock_s3():
        yield boto3.client('s3')

def create_test_bucket(s3, bucket):
    s3.create_bucket(
        Bucket=bucket,
        CreateBucketConfiguration={'LocationConstraint': os.environ['AWS_DEFAULT_REGION']}
    )

def create_object(s3, key, bucket):
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=''
    )

def test_flow_processed(monkeypatch, aws_credentials, s3, bucket):
    from hevc_processor import processor

    called = 0
    def mock_delete_source(source, bucket):
        nonlocal called
        called += 1

    monkeypatch.setattr(processor, 'delete_source', mock_delete_source)

    create_test_bucket(s3, bucket)
    create_object(s3, 'DONE/video-hevc.mp4', bucket)

    processor.main('', 'TODO/video.mp4', bucket)

    assert called == 1

@mock_s3
def test_flow_success(monkeypatch, aws_credentials, s3, bucket, tmpdir):
    from hevc_processor import processor

    def mock_transcode_file(workdir):
        os.rename(f'{tmpdir}/input.mp4', f'{tmpdir}/output.mp4')
        pass

    monkeypatch.setattr(processor, 'transcode_file', mock_transcode_file)

    create_test_bucket(s3, bucket)
    create_object(s3, 'TODO/video.mp4', bucket)

    processor.main(str(tmpdir), 'TODO/video.mp4', bucket)

    assert s3.head_object(
        Bucket=bucket,
        Key='DONE/video-hevc.mp4'
    )

    with pytest.raises(ClientError) as e:
        s3.head_object(
            Bucket=bucket,
            Key='TODO/video.mp4'
        )
    assert e.value.response['Error']['Code'] == '404'
