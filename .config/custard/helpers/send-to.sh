#!/bin/bash

echo "send to workspace $1" > /tmp/custard.fifo
notify-send "Window sent to workspace $1"
