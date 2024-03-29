#!/usr/bin/env python3

import os
import boto3
import pytest

from pathlib import Path
from moto import mock_aws

@pytest.fixture
def s3(aws_credentials):
    with mock_aws():
        yield boto3.client('s3')

def create_test_bucket(s3, bucket):
    s3.create_bucket(
        Bucket=bucket,
        CreateBucketConfiguration={'LocationConstraint': os.environ['AWS_DEFAULT_REGION']}
    )

def test_creation():
    from hevc_transcoder.video_file import VideoFile
    obj = VideoFile('/base', 'file.mp4')

    assert str(obj) == '/base/file.mp4'
    assert obj.key['todo'] == 'TODO/file.mp4'
    assert obj.key['done'] == 'DONE/file-hevc.mp4'

@mock_aws
def test_upload(aws_credentials, tmpdir, bucket, s3):
    basedir = str(tmpdir)
    filename = 'file.mp4'
    with open(f'{basedir}/{filename}', 'w'):
        pass

    create_test_bucket(s3, bucket)

    from hevc_transcoder.video_file import VideoFile
    obj = VideoFile(basedir, filename)
    assert not obj.uploaded

    obj.upload_for_processing()

    assert obj.uploaded
    assert s3.head_object(Bucket=bucket, Key=f'TODO/{filename}')

@mock_aws
def test_download_processed(aws_credentials, s3, tmpdir, bucket):
    basedir = str(tmpdir)
    source = 'file.mp4'
    target = 'file-hevc.mp4'

    with open(f'{basedir}/{source}', 'w'):
        pass

    create_test_bucket(s3, bucket)

    s3.put_object(
        Bucket=bucket,
        Key=f'DONE/{target}',
        Body=''
    )

    from hevc_transcoder.video_file import VideoFile
    obj = VideoFile(basedir, source)
    obj.download_processed()

    assert not Path(f'{basedir}/{source}').is_file()
    assert Path(f'{basedir}/{target}').is_file()

@mock_aws
def test_is_processing(aws_credentials, s3, tmpdir, bucket):
    basedir = str(tmpdir)
    source = 'file.mp4'

    create_test_bucket(s3, bucket)

    from hevc_transcoder.video_file import VideoFile
    obj = VideoFile(basedir, source)

    assert not obj.is_processing()

    s3.put_object(
        Bucket=bucket,
        Key=f'TODO/{source}',
        Body=''
    )

    assert obj.is_processing()

@mock_aws
def test_is_done(aws_credentials, s3, tmpdir, bucket):
    basedir = str(tmpdir)
    source = 'file.mp4'
    target = 'file-hevc.mp4'

    create_test_bucket(s3, bucket)

    from hevc_transcoder.video_file import VideoFile
    obj = VideoFile(basedir, source)

    assert not obj.is_done()

    s3.put_object(
        Bucket=bucket,
        Key=f'DONE/{target}',
        Body=''
    )

    assert obj.is_done()
