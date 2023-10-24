#!/usr/bin/env python3

import os
import tempfile
import pathlib

def test_delete_done_files(bucket, basedir):
  with open(basedir + '/done.mp4', 'w') as fp:
    pass
  with open(basedir + '/done-hevc.mp4', 'w') as fp:
    pass
  with open(basedir + '/todo.mp4', 'w') as fp:
    pass
  os.mkdir(basedir + '/subdir')
  with open(basedir + '/subdir/done.mp4', 'w') as fp:
    pass
  with open(basedir + '/subdir/done-hevc.mp4', 'w') as fp:
    pass
  with open(basedir + '/subdir/todo.mp4', 'w') as fp:
    pass

  from processor import processor

  video_list = processor.list_videos(basedir)
  video_list = [str(x) for x in video_list]
  assert len(video_list) == 2
  assert basedir + '/todo.mp4' in video_list
  assert basedir + '/subdir/todo.mp4' in video_list

  path = pathlib.Path(basedir)
  file_list = list(path.rglob("*.mp4"))
  file_list = [str(x) for x in file_list]
  assert len(file_list) == 4
  assert basedir + '/done-hevc.mp4' in file_list
  assert basedir + '/todo.mp4' in file_list
  assert basedir + '/subdir/done-hevc.mp4' in file_list
  assert basedir + '/subdir/todo.mp4' in file_list
