#!/usr/bin/env python3

from pathlib import Path

def test_creation(bucket):
    from processor.video_file import VideoFile

    obj = VideoFile('basedir', 'filename')
    assert str(obj) == 'basedir/filename'
    assert obj.key['todo'] == 'TODO/filename'
    assert obj.key['done'] == 'DONE/filename'

def test_upload(aws_credentials, s3, basedir, bucket):
    filename = 'file.mp4'
    with open(f'{basedir}/{filename}', 'w'):
        pass

    from processor.video_file import VideoFile
    obj = VideoFile(basedir, filename)
    assert not obj.uploaded

    obj.upload_for_processing()

    assert obj.uploaded
    assert s3.head_object(Bucket=bucket, Key=f'TODO/{filename}')

def test_download_processed(aws_credentials, s3, basedir, bucket):
    source = 'file.mp4'
    target = 'file-hevc.mp4'

    with open(f'{basedir}/{source}', 'w'):
        pass

    s3.put_object(
        Bucket=bucket,
        Key=f'DONE/{target}',
        Body=''
    )

    from processor.video_file import VideoFile
    obj = VideoFile(basedir, source)
    obj.download_processed()

    assert not Path(f'{basedir}/{source}').is_file()
    assert Path(f'{basedir}/{target}').is_file()

def test_is_processing(aws_credentials, s3, basedir, bucket):
    source = 'file.mp4'

    from processor.video_file import VideoFile
    obj = VideoFile(basedir, source)

    assert not obj.is_processing()

    s3.put_object(
        Bucket=bucket,
        Key=f'TODO/{source}',
        Body=''
    )

    assert obj.is_processing()

def test_is_done(aws_credentials, s3, basedir, bucket):
    source = 'file.mp4'
    target = 'file-hevc.mp4'

    from processor.video_file import VideoFile
    obj = VideoFile(basedir, source)

    assert not obj.is_done()

    s3.put_object(
        Bucket=bucket,
        Key=f'DONE/{target}',
        Body=''
    )

    assert obj.is_done()
