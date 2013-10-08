#!/bin/bash

HOST=127.0.0.1
PORT=6000
COMMSEC_SERVER=commsec-gcs
DIR=../../../cabal-dev/bin

EXEC_MAVPROXY="python mavlink/mavproxy.py --master=tcp:$HOST:$PORT --baud=57600"

echo starting commsec server: $COMMSEC_SERVER $1
$DIR/$COMMSEC_SERVER $1 &

if which gnome-terminal >/dev/null; then
  echo starting mavproxy in a new terminal: $EXEC_MAVPROXY;
  gnome-terminal -x $EXEC_MAVPROXY;
else
  if [ -z $TERM_APP ]; then
		echo Cannot find a terminal program. Try setting TERM_APP environment variable;
		echo User can start mavproxy with: $EXEC_MAVPROXY;
  else
  	echo starting mavproxy in a new terminal: $EXEC_MAVPROXY;
  	$TERM_APP -x $EXEC_MAVPROXY;
  fi
fi

function kill() {
    read -p "$*"
}

# Wait for input.
kill "Press [Enter] to kill commsec server..."

# Kill the script.
killall $COMMSEC_SERVER
