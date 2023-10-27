#!/usr/bin/env python3

import os
import pathlib

def test_delete_done_files(aws_credentials, bucket, tmpdir):
    with open(tmpdir + '/done.mp4', 'w'):
        pass
    with open(tmpdir + '/done-hevc.mp4', 'w'):
        pass
    with open(tmpdir + '/todo.mp4', 'w'):
        pass
    os.mkdir(tmpdir + '/subdir')
    with open(tmpdir + '/subdir/done.mp4', 'w'):
        pass
    with open(tmpdir + '/subdir/done-hevc.mp4', 'w'):
        pass
    with open(tmpdir + '/subdir/todo.mp4', 'w'):
        pass

    from processor import processor

    video_list = processor.list_videos(str(tmpdir))
    video_list = [str(x) for x in video_list]
    assert len(video_list) == 2
    assert tmpdir + '/todo.mp4' in video_list
    assert tmpdir + '/subdir/todo.mp4' in video_list

    path = pathlib.Path(tmpdir)
    file_list = list(path.rglob("*.mp4"))
    file_list = [str(x) for x in file_list]
    assert len(file_list) == 4
    assert tmpdir + '/done-hevc.mp4' in file_list
    assert tmpdir + '/todo.mp4' in file_list
    assert tmpdir + '/subdir/done-hevc.mp4' in file_list
    assert tmpdir + '/subdir/todo.mp4' in file_list

def test_main(monkeypatch):
    from processor import processor

    class MockVideoFile():
        uploaded = False
        upload_counter = 0
        done_counter = 0
        download_counter = 0

        def upload_for_processing(self):
            self.upload_counter += 1
            self.uploaded = True

        def is_done(self):
            if self.done_counter == 0:
                self.done_counter += 1
                return False
            else:
                self.done_counter += 1
                return True

        def download_processed(self):
            self.download_counter += 1

    mock_video = MockVideoFile()

    def mock_list_videos(tmpdir):
        return [mock_video]

    monkeypatch.setattr(processor, "list_videos", mock_list_videos)
    monkeypatch.setattr(processor, "SLEEP", 0.001)

    processor.main(None)

    assert mock_video.upload_counter == 1
    assert mock_video.done_counter == 2
    assert mock_video.download_counter == 1
