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

def get_processing_keys():
    ecs = boto3.client('ecs')
    tasks = ecs.list_tasks()

    results = ecs.describe_tasks(
        tasks=tasks['taskArns']
    )

    processing_list = []
    for task in results['tasks']:
        for override in task['overrides']['containerOverrides']:
            for environment in override['environment']:
                if environment['name'] == 'S3_OBJECT_KEY':
                    processing_list.append(environment['value'])

    return processing_list

def build_entries(keys, bucket=_default_bucket):
    entries = []
    for key in keys:
        entries.append({
            'Time': int(time.time()),
            'Source': 'mdekort.hevc',
            'DetailType': 'Manual Trigger',
            'Resources': [],
            'Detail': json.dumps({
                'bucket': {
                    'name': bucket
                },
                'object': {
                    'key': key
                }
            })
        })

    return entries

def publish_events(bucket=_default_bucket):
    keys = get_keys(bucket)
    processing = get_processing_keys()
    todo_keys = [x for x in keys if (x not in processing)]

    entries = build_entries(todo_keys, bucket)

    if len(entries) > 0:
        for i in range(0, len(entries), 10):
          batch = entries[i:i+10]

          result = events.put_events(
              Entries=batch
          )

          if result['FailedEntryCount'] > 0:
              for entry in result['Entries']:
                  print(entry['ErrorMessage'])
          else:
              print(f'Successfully published {len(batch)} events')


publish_events(_default_bucket)
