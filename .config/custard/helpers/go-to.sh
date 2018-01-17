#!/bin/bash

echo "go to workspace $1" > /tmp/custard.fifo
notify-send "Focused on workspace $1"

