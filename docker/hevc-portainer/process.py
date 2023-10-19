#!/usr/bin/env python3

import boto3
import glob
import time

from pathlib import Path
from botocore.exceptions import ClientError

s3 = boto3.client('s3')

_bucket = 'mdekort.hevc'

def list_local_todo():
  todo_list = []

  for file in glob.glob('/data/**/*.mp4', recursive=True):
    if file.endswith('-hevc.mp4'):
      # delete original file when it has already been converted
      original = Path(file.replace('-hevc.mp4', '.mp4'))
      if original.is_file():
        print(f'Removing local {original.name.removeprefix("/data/")}')
        original.unlink()
    else:
      # add file to todo list
      converted = Path(file.replace('.mp4', '-hevc.mp4'))
      if not converted.is_file():
        relative = file.removeprefix('/data/')
        todo_list.append(relative)

  return todo_list

def object_exists(prefix, filename, bucket=_bucket):
  try:
    s3.head_object(
      Bucket=bucket,
      Key=prefix + filename
    )
    return True
  except ClientError as e:
    if e.response['Error']['Code'] == '404':
      return False
    else:
      raise

def is_being_processed(file, bucket=_bucket):
  return object_exists('TODO/', file, bucket) or object_exists('DONE/', file, bucket)

def process_files(files, bucket=_bucket):
  for file in files:
    if not is_being_processed(file):
      print(f'Uploading local {file} to S3')
      s3.upload_file(
        Filename=f'/data/{file}',
        Bucket=bucket,
        Key='TODO/' + file
      )

def list_done(bucket=_bucket):
  result = s3.list_objects_v2(
    Bucket=bucket,
    Prefix='DONE/'
  )

  keys = []
  if result['KeyCount'] > 0:
    for entry in result['Contents']:
      keys.append(entry['Key'].removeprefix('DONE/'))

  return keys

def download_file(file, bucket=_bucket):
  print(f'Downloading remote {file} from S3')
  s3.download_file(
    Bucket=bucket,
    Key=f'DONE/{file}',
    Filename=f'/data/{file}'
  )
  print(f'Removing remote {file} from S3')
  s3.delete_object(
    Bucket=bucket,
    Key=f'DONE/{file}'
  )

def download_processed(bucket=_bucket):
  for file in list_done(bucket):
    download_file(file, bucket)

    # cleanup original file after processed file was downloaded
    original = Path('/data/' + file.replace('-hevc.mp4', '.mp4'))
    if original.is_file():
      print(f'Removing local {original.name.removeprefix("/data/")}')
      original.unlink()

def is_finished(bucket=_bucket):
  list_done = s3.list_objects_v2(
    Bucket=bucket,
    Prefix='DONE/'
  )

  list_todo = s3.list_objects_v2(
    Bucket=bucket,
    Prefix='TODO/'
  )

  if list_done['KeyCount'] > 0 or list_todo['KeyCount'] > 0:
    return False
  else:
    return True

print('Processing started')

process_files(list_local_todo())

while not is_finished():
  time.sleep(30)
  download_processed()

print('Processing finished')
