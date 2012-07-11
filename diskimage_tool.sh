#!/bin/bash

function usage
{
	echo "usage: [options] [files]"
	echo "options:"
	echo "     [split]: split a disk image to "$PART_IMG_PRE"1.img ... "$PART_IMG_PRE"n.img"
	echo "              #$PROG split diskimage.img"
	echo "     [update]: update partition image to disk image"
	echo "              #$PROG update diskimage.img part1.img part2.img"
}

#set -x
PART_IMG_PRE=part
PROG=$0
ARGC=$#
OP=$1
IMG_NAME=$2
PART_COUNTER=1

if [ $ARGC -lt 1 ] || [ $OP != split -a $OP != update ]; then
	usage
	exit 
fi

case $OP in
	split )
		if [ $ARGC -ne 2 ]; then
			usage
			exit
		fi

		while IFS=" " read num start end size type filesystem flags
		do
			start=${start%s}
			size=${size%s}
	
			dd bs=512 if=$IMG_NAME \
			skip=$start of="$PART_IMG_PRE""$PART_COUNTER".img count=$size
	
			PART_COUNTER=$(( PART_COUNTER + 1 ))
		done < <(parted -s $IMG_NAME  unit s print | grep primary)
		;;
	update )
		argc_part_start=3
		while IFS=" " read num start end size type filesystem flags
		do
			eval part_img_name=\$$argc_part_start
			echo $part_img_name
			start=${start%s}
	
			dd conv=notrunc bs=512 if=$part_img_name of=$IMG_NAME seek=$start

			PART_COUNTER=$(( PART_COUNTER + 1 ))
			argc_part_start=$(( argc_part_start + 1 ))
		done < <(parted -s $IMG_NAME  unit s print | grep primary)
		;;
esac

