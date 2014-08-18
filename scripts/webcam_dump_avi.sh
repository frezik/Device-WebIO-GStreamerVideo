#!/bin/bash
gst-launch-1.0 -e v4l2src device=/dev/video0 ! 'video/x-raw,width=640,height=480,framerate=30/1' ! x264enc ! avimux ! filesink location=~/tmp/webcam.avi
