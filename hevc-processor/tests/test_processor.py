import os
import boto3
import pytest

from moto import mock_s3

from hevc_processor import processor

@pytest.fixture
def s3(aws_credentials):
    with mock_s3():
        yield boto3.client('s3')

def create_test_bucket(s3, bucket):
    s3.create_bucket(
        Bucket=bucket,
        CreateBucketConfiguration={'LocationConstraint': os.environ['AWS_DEFAULT_REGION']}
    )

    s3.put_object(
        Bucket=bucket,
        Key='TODO/video.mp4',
        Body=''
    )

def test_flow_processed(monkeypatch):
    count_is_processed = 0
    count_delete = 0

    def mock_is_processed(key, bucket):
        nonlocal count_is_processed
        count_is_processed += 1
        return True

    def mock_delete_source(key, bucket):
        nonlocal count_delete
        count_delete += 1
        assert key == 'key'
        assert bucket == 'bucket'

    monkeypatch.setattr(processor, 'is_processed', mock_is_processed)
    monkeypatch.setattr(processor, 'delete_source', mock_delete_source)

    processor.main('.', 'key', 'bucket')

    assert count_is_processed == 1
    assert count_delete == 1

@mock_s3
def test_flow_success(monkeypatch, aws_credentials, s3, bucket, tmpdir):
    count_is_processed = 0
    count_delete = 0

    def mock_transcode_file(workdir):
        os.rename(f'{tmpdir}/input.mp4', f'{tmpdir}/output.mp4')
        pass

    monkeypatch.setattr(processor, 'transcode_file', mock_transcode_file)

    create_test_bucket(s3, bucket)

    processor.main(str(tmpdir), 'TODO/video.mp4', bucket)

    assert s3.head_object(
        Bucket=bucket,
        Key='DONE/video.mp4'
    )
