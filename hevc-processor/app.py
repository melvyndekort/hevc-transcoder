#!/usr/bin/env python3
"""
Script that calls / starts the underlying modules
"""

import os
import logging

from hevc_processor import processor


def main(source, bucket):
    '''Main method which calls the modules'''
    logging.basicConfig(level=logging.INFO)

    processor.main('/tmp', source, bucket)


if __name__ == '__main__':
    BUCKET = os.environ['S3_BUCKET_NAME']
    SOURCE = os.environ['S3_OBJECT_KEY']

    main(SOURCE, BUCKET)
