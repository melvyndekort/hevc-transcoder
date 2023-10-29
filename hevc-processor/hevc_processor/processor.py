"""
Download H.264 source file from S3, transcode to H.265 and upload to S3
"""

import os
import logging
import boto3

from botocore.exceptions import ClientError
from ffmpeg import FFmpeg, Progress

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')


def is_processed(key, bucket):
    '''Check if object exists in S3 with 'DONE/' prefix'''
    try:
        s3.head_object(
            Bucket=bucket,
            Key=key
        )
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == '404':
            return False
        else:
            raise


def download_source(workdir, source, bucket):
    '''Download video file from S3'''
    logger.info(f'Downloading {source} from S3')
    s3.download_file(
        Bucket=bucket,
        Key=source,
        Filename=f'{workdir}/input.mp4'
    )


def upload_target(workdir, target, bucket):
    '''Upload video file to S3'''
    logger.info(f'Uploading {target} to S3')
    s3.upload_file(
        Filename=f'{workdir}/output.mp4',
        Bucket=bucket,
        Key=target
    )


def transcode_file(workdir):
    '''Transcode H.264 file to H.265 format'''
    logger.info('Transcoding video to H.265 format')
    ffmpeg = (
        FFmpeg()
        .option('y')
        .input(f'{workdir}/input.mp4')
        .output(
            f'{workdir}/output.mp4',
            {
                'codec:v': 'libx265',
                'codec:a': 'copy'
            },
            preset='fast',
            crf=26,
        )
    )

    @ffmpeg.on('start')
    def on_start(arguments: list[str]):
        logger.info(f'arguments: {arguments}')

    @ffmpeg.on('stderr')
    def on_stderr(line):
        logger.info(f'stderr: {line}')

    @ffmpeg.on('progress')
    def on_progress(progress: Progress):
        logger.info(progress)

    @ffmpeg.on('completed')
    def on_completed():
        logger.info('completed')

    @ffmpeg.on('terminated')
    def on_terminated():
        logger.info('terminated')

    ffmpeg.execute()


def delete_source(source, bucket):
    '''Delete the original H.264 file from S3'''
    logger.info(f'Deleting {source} from S3')
    s3.delete_object(
        Bucket=bucket,
        Key=source
    )


def main(workdir, source, bucket):
    '''Main processing coordinator'''
    logger.info(f'Start processing {source}')

    target = 'DONE/' + source.removeprefix('TODO/').removesuffix('.mp4') + '-hevc.mp4'

    if is_processed(target, bucket):
        delete_source(source, bucket)
    else:
        download_source(workdir, source, bucket)
        transcode_file(workdir)
        upload_target(workdir, target, bucket)
        delete_source(source, bucket)

    logger.info(f'Finished processing {source}')
