#!/bin/bash

echo "attach workspace $1" > /tmp/custard.fifo
notify-send "Attached workspace $1"
