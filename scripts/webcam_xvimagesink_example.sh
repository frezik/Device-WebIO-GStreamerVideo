#!/bin/bash
gst-launch-1.0 v4l2src device=/dev/video0 ! queue ! 'video/x-raw,width=640,height=480' ! xvimagesink sync=false
