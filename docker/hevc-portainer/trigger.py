#!/usr/bin/env python3

import json
import boto3
import time

_default_bucket = 'mdekort.hevc'

s3 = boto3.client('s3')
events = boto3.client('events')

def get_keys(bucket=_default_bucket):
  object_list = s3.list_objects_v2(
    Bucket=bucket,
    Prefix='TODO/'
  )

  keys = []
  if object_list['KeyCount'] > 0:
    for entry in object_list['Contents']:
      if entry['Key'].endswith('.mp4'):
        keys.append(entry['Key'])
  return keys

def build_entries(keys, bucket=_default_bucket):
  events = []
  for key in keys:
    event.append({
      'Time': int(time.time()),
      'Source': 'mdekort.hevc',
      'DetailType': 'Manual Trigger',
      'Detail': {
        'bucket': bucket,
        'key': key
      }
    })

  return events

def publish_events(bucket=_default_bucket):
  keys = get_keys(bucket)
  entries = build_entries(keys, bucket)

  if len(entries) > 0:
    result = events.put_events(
      Entries=entries
    )

    if result['FailedEntryCount'] > 0:
      for entry in result['Entries']:
        print(entry['ErrorMessage'])

publish_events(_default_bucket)
