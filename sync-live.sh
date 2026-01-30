#!/bin/bash

LIVEDIR="/mnt/d/Repos/slyllama.github.io/hoseshop"

if [ -d "$LIVEDIR" ]; then
	rsync -anv --delete --exclude="*.swp" web/ "$LIVEDIR"/
	read -p "Proceed? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rsync -a --delete --exclude="*.swp" web/ "$LIVEDIR"/
	fi
fi

