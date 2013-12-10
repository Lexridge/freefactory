#!/bin/sh
#  FreeFactory (c) 2012-2013 by Jim Hines
#  FreeFactory is GPL
#  Requirements: inotify-tools (namely inotifywait), FFmpeg v0.10+ and FFmbc.
#  FFmpeg Copyright (c) 2000-2013 the FFmpeg developers
#  FFmbc Copyright (c) 2008-2013 Baptiste Coudurier and the FFmpeg developers
#
#  FreeFactory Generic Script for your modifications
#  This script takes [insert] and converts it to a [insert]
#  This script is called from ff-ctrl. It will not work on its own.
#  usage: inotifywait -rme close_write /video/dropbox | /opt/FreeFactory/bin/ff-ctrl.sh

modulename	="GenericFFModule"
logpath		="/var/log/ff-VideoConversion.log"
SOURCEPATH	="$1"				# This is retrieved from ff-ctrl.sh
FILENAME	="$2"				# This is retrieved from ff-ctrl.sh
outputpath	="/video"			# Directory where the final file ends up
# Get rid of file .SUFFIX
LENGTH		=${#FILENAME}
outputfile	="/video/${FILENAME:0:$LENGTH-4}.mov"

#FFMPEG vars
ffprog		="/PATH-TO-FFmbc or FFmpeg"	# Which ff program to use
vidopts		=""				# Video options for ffprog
audopts		=""				# Audio options for ffprog
filtopts  =""       # Video or Audio Filter options
#vidres   =""       # For Future Use
#vidcodec =""       # For Future Use
#vidid    =""       # For Future Use

echo "===============$modulename Initialized - Converting $SOURCEPATH$FILENAME to MOV================"
echo "$(date +%Y-%m-%d--%H:%M:%S) $modulename,"$SOURCEPATH$FILENAME >>/var/log/wdtv-VideoConversion.log
#echo "====================FILENAME = $FILENAME ============================================"

$ffprog -y -i $SOURCEPATH$FILENAME $filtopts $vidopts $outputfile 2>>$logpath

# Remove Source File
echo "============Removing file: $SOURCEPATH$FILENAME =========================="
rm -f $SOURCEPATH$FILENAME			# Removes the original file
cp $outputfile $outputpath			# Copies newly created file to path
rm $outputfile					# Deletes newly created file after copied to dest path
