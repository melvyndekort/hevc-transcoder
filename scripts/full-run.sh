#!/bin/sh

VIDEO=/tmp/video-$$.mp4
curl -sLo $VIDEO https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_2mb.mp4
aws s3 cp $VIDEO s3://mdekort.hevc/TODO/temp.mp4
rm -f $VIDEO
