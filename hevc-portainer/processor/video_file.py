#!/usr/bin/env python3

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

    def __init__(self, basedir, relpath):
        self.source = basedir + '/' + relpath
        self.target = basedir + '/' + relpath.replace('.mp4', '-hevc.mp4')
        self.key = {
            'todo': 'TODO/' + relpath,
            'done': 'DONE/' + relpath.replace('.mp4', '-hevc.mp4')
        }

    def __str__(self):
        return self.source

    def upload_for_processing(self):
        s3.upload_file(
            Filename=self.source,
            Bucket=bucket,
            Key=self.key['todo']
        )
        self.uploaded = True

    def download_processed(self):
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
        return self.object_exists(self.key['todo'])

    def is_done(self):
        return self.object_exists(self.key['done'])
