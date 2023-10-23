#!/bin/sh

WORK=25
PAUSE=5
INTERACTIVE=true
MUTE=false

show_help() {
	cat <<-END
		usage: potato [-s] [-m] [-w m] [-b m] [-h]
		    -s: simple output. Intended for use in scripts
		        When enabled, potato outputs one line for each minute, and doesn't print the bell character
		        (ascii 007)

		    -m: mute -- don't play sounds when work/break is over
		    -w m: let work periods last m minutes (default is 25)
		    -b m: let break periods last m minutes (default is 5)
		    -h: print this message
	END
}

play_notification() {
	aplay -q /usr/lib/potato/notification.wav&
}

while getopts :sw:b:m opt; do
	case "$opt" in
	s)
		INTERACTIVE=false
	;;
	m)
		MUTE=true
	;;
	w)
		WORK=$OPTARG
	;;
	b)
		PAUSE=$OPTARG
	;;
	h|\?)
		show_help
		exit 1
	;;
	esac
done

time_left="%im left of %s "

if $INTERACTIVE; then
	time_left="\r$time_left"
else
	time_left="$time_left\n"
fi

while true
do
	i=$WORK
	while [ $i -gt 0 ]
	do
		printf "$time_left" $i "work"
		sleep 1m
		true $(( i=i-1 ))
	done

	! $MUTE && play_notification
	if $INTERACTIVE; then
		read -d '' -t 0.001
		printf "\aWork over\n"
		read
	fi
	
	i=$PAUSE
	while [ $i -gt 0 ]
	do
		printf "$time_left" $i "pause"
		sleep 1m
		true $(( i=i-1 ))
	done

	! $MUTE && play_notification
	if $INTERACTIVE; then
		read -d '' -t 0.001
		printf "\aPause over\n"
		read
	fi
done
