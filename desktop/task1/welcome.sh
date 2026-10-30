#!/bin/bash
nickname="$1"
regex="^[A-Za-z0-9_]{3,16}$"

if [[ "$nickname" =~ $regex ]]; then
	echo "Welcome, ${nickname}!"
	exit 0
else
	echo "Invalid nickname">&2
	exit 1
fi