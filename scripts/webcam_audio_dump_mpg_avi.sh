#!/bin/bash
gst-launch-1.0 -e v4l2src device=/dev/video0 ! 'video/x-raw,width=640,height=480,framerate=30/1' ! x264enc ! avimux name=mux ! filesink location=~/tmp/webcam.avi alsasrc device=hw:1,0 ! audioconvert ! 'audio/x-raw,rate=44100,channels=2' ! lamemp3enc ! mux.
