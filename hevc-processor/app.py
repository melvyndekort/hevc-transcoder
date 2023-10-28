#!/usr/bin/env python3
"""
Script that calls / starts the underlying modules
"""

import logging

from hevc_processor import processor


def main(target):
    '''Main method which calls the modules'''
    logging.basicConfig(level=logging.INFO)

    processor.main(source, bucket)


if __name__ == '__main__':
    bucket = os.environ['S3_BUCKET_NAME']
    source = os.environ['S3_OBJECT_KEY']

    main(source, bucket)
