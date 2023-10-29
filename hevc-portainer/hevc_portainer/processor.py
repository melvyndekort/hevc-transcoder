"""
Finds H.264 encoded videos on disk and coordinates their re-encode to H.265
"""

import time
import logging

from pathlib import Path
from hevc_portainer.video_file import VideoFile

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

SLEEP = 60


def delete_original(filename):
    '''Delete original file from filesystem'''
    original_name = filename.replace('-hevc.mp4', '.mp4')
    original = Path(original_name)
    if original.is_file():
        logger.info(f'Deleting local file {original_name} from filesystem')
        original.unlink()


def add_file(videos, basedir, filename):
    '''Add video file to list to get processed'''
    converted = filename.replace('.mp4', '-hevc.mp4')
    if not Path(converted).is_file():
        relpath = filename.removeprefix(basedir + '/')
        video_file = VideoFile(basedir, relpath)
        videos.append(video_file)


def list_videos(basedir):
    '''Prepare a list of videos that need to get processed'''
    videos = []

    for file in Path(basedir).rglob("*.mp4"):
        filename = str(file)
        if filename.endswith('-hevc.mp4'):
            delete_original(filename)
        else:
            add_file(videos, basedir, filename)

    return videos


def process_videos(videos):
    '''Loop through videos and process them'''
    for video in videos[:]:
        if video.is_done():
            video.download_processed()
            videos.remove(video)
        elif not video.uploaded:
            video.upload_for_processing()
        else:
            logger.info(f'File {video} is (still) processing')



def main(basedir):
    '''Main loop that keeps running until all videos are processed'''
    logger.info('Start processing')

    videos = list_videos(basedir)

    while len(videos) > 0:
        process_videos(videos)

        if len(videos) > 0:
            time.sleep(SLEEP)

    logger.info('Finished processing')
