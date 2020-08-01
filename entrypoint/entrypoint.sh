#!/bin/bash

function usage() { 
	echo 'Usage :';
	echo '	docker run virtual-broadcaster -o streamlink [-v video_size] [-f framerate] [-c command]';
	exit 1;
}

while getopts “:v:f:o:c:bc” opt; do
  case $opt in
    v) VIDEO_DIMENSIONS=${OPTARG} ;;
    f) FRAMERATE=${OPTARG} ;;
    o) OUTPUT=${OPTARG} ;;
    c) COMMAND=${OPTARG} ;;
  esac
done

if [ -z "$OUTPUT" ]; then usage; fi

#Default values
if [ -z "$VIDEO_DIMENSIONS" ]; then VIDEO_DIMENSIONS='720x480x24'; fi
if [ -z "$FRAMERATE" ]; then FRAMERATE='30'; fi

VIDEO_SIZE=`expr match "$VIDEO_DIMENSIONS" '\([0-9]*x[0-9]*\)'`;

#Start virtual screen
Xvfb $DISPLAY -screen 0  $VIDEO_DIMENSIONS&

#Audio
pulseaudio --start --disallow-exit -vvv --log-target=newfile:/pulseaudio.log --daemonize

ffmpeg="ffmpeg -f pulse -i default -f x11grab -framerate 30 -video_size ${VIDEO_SIZE} -draw_mouse 0 -i :0 -c:v libx264 -preset veryfast -maxrate 1984k -bufsize 3968k -vf format=yuv420p -g 60 -c:a aac -b:a 128k -ar 44100 -f flv ${OUTPUT}"

if [ -z "$COMMAND" ]
then
#If no command passed, we start ffmpeg without '&' to keep the container up
	$ffmpeg
else
#Else we start ffmpeg in detached mode then we run the command, the container will stop once the command is completed
	echo 'COMMAND' $COMMAND;
	$ffmpeg&
	$COMMAND;
fi

echo 'video dimensions : ' $VIDEO_DIMENSIONS;
echo 'framerate : ' $FRAMERATE;
echo 'output : ' $OUTPUT;
