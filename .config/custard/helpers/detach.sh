#!/bin/bash

echo "detach workspace $1" > /tmp/custard.fifo
notify-send "Detached workspace $1"
