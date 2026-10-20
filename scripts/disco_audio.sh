#!/bin/bash
# Loop the disco song out of the HDMI port the screen is plugged into.
# The caller must return immediately, so playback is detached.
PIDFILE=/tmp/disco-audio.pid
SONG=/home/topi/printer_data/sounds/Caramella_Girls.mp3
DEVICE='plughw:CARD=vc4hdmi0,DEV=0'

stop() {
	if [[ -f "$PIDFILE" ]]; then
		pid=$(cat "$PIDFILE" 2>/dev/null || true)
		if [[ -n "$pid" ]]; then
			kill "$pid" 2>/dev/null || true
			for _ in 1 2 3 4 5; do
				kill -0 "$pid" 2>/dev/null || break
				sleep 0.1
			done
			kill -9 "$pid" 2>/dev/null || true
		fi
		rm -f "$PIDFILE"
	fi
}

start() {
	stop
	if [[ ! -f "$SONG" ]]; then
		echo "disco song missing: $SONG" >&2
		exit 1
	fi
	nohup ffmpeg -hide_banner -loglevel error -stream_loop -1 \
		-i "$SONG" -f alsa "$DEVICE" >/tmp/disco-audio.log 2>&1 &
	echo $! >"$PIDFILE"
	disown || true
}

case "${1:-}" in
	start) start ;;
	stop) stop ;;
	*)
		echo "usage: disco_audio.sh start|stop" >&2
		exit 1
		;;
esac
