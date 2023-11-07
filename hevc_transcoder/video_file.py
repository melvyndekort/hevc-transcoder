"""
Class file that does the actual work for processor.py
"""

import os
import boto3
import logging

from pathlib import Path
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
bucket = os.environ['BUCKET']


class VideoFile:
    uploaded = False

    def __init__(self, basedir, source_relpath):
        '''Initializer'''
        target_relpath = source_relpath.removesuffix('.mp4') + '-hevc.mp4'

        self.source = basedir + '/' + source_relpath
        self.target = basedir + '/' + target_relpath
        self.key = {
            'todo': 'TODO/' + source_relpath,
            'done': 'DONE/' + target_relpath
        }

    def __str__(self):
        '''String representation of object'''
        return self.source

    def upload_for_processing(self):
        '''Upload the video file to S3 for processing'''
        logger.info(f'Uploading local file {self.source} to S3')
        s3.upload_file(
            Filename=self.source,
            Bucket=bucket,
            Key=self.key['todo']
        )
        self.uploaded = True

    def download_processed(self):
        '''Download processed video file from S3'''
        logger.info(f'Downloading remote file {self.key["done"]} from S3')
        s3.download_file(
            Bucket=bucket,
            Key=self.key['done'],
            Filename=self.target
        )
        logger.info(f'Deleting local file {self.source} from filesystem')
        file = Path(self.source)
        file.unlink()

    def object_exists(self, key):
        '''Check if object exists in S3'''
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

    def is_processing(self):
        ''' Check if file is still being processed'''
        return self.object_exists(self.key['todo'])

    def is_done(self):
        '''Check if file has finished processing'''
        return self.object_exists(self.key['done'])
