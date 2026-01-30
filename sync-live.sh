#!/bin/bash

LIVEDIR="/mnt/d/Repos/wam-live"

if [ -d "$LIVEDIR" ]; then
	rsync -anv --delete --exclude="*.swp" --exclude=".git/" web/ "$LIVEDIR"/
	read -p "Proceed? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rsync -a --delete --exclude="*.swp" --exclude=".git/" web/ "$LIVEDIR"/
	fi
fi

