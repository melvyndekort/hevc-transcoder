#!/usr/bin/env python3

import os
import time
import logging

from pathlib import Path

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

SLEEP = 60

from processor.video_file import VideoFile

def list_videos(basedir):
  videos = []

  for file in Path(basedir).rglob("*.mp4"):
    filename = str(file)
    if filename.endswith('-hevc.mp4'):
      # delete original file when it has already been converted
      original_name = filename.replace('-hevc.mp4', '.mp4')
      original = Path(original_name)
      if original.is_file():
        logger.info(f'Deleting local file {original_name} from filesystem')
        original.unlink()
    else:
      converted = filename.replace('.mp4', '-hevc.mp4')
      if not Path(converted).is_file():
        relpath = filename.removeprefix(basedir + '/')
        video_file = VideoFile(basedir, relpath)
        videos.append(video_file)

  return videos

def main(basedir):
  logger.info('Start processing')

  videos = list_videos(basedir)

  while len(videos) > 0:
    for video in videos[:]:
      if not video.uploaded:
        video.upload_for_processing()
      elif video.is_done():
        video.download_processed()
        videos.remove(video)
    time.sleep(SLEEP)

  logger.info('Finished processing')
