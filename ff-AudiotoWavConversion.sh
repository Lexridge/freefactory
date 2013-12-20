#!/bin/bash
#  FreeFactory (c) 2012-2013 by Jim Hines 
#  Requirements: inotify-tools (namely inotifywait), FFmpeg v0.10+ and FFmbc.
#  FFmpeg Copyright (c) 2000-2013 the FFmpeg developers
#  FFmbc Copyright (c) 2008-2013 Baptiste Coudurier and the FFmpeg developers
#
#  FreeFactory Audio or Video to WAVE Conversion by Jim Hines
#  This script takes any audio or a/v file, of any resolution, and converts it to a stereo wav file.
#  This script is called from ff-ctrl. It will not work on its own.
#  usage: inotifywait -rme close_write /video/dropbox | /opt/FreeFactory/bin/ff-ctrl.sh

modulename="Audio file to .WAV Conversion Script"
SOURCEPATH="$1"
FILENAME="$2"
# Get rid of file .SUFFIX
LENGTH=${#FILENAME}
outputfile="/video/${FILENAME:0:$LENGTH-4}.wav"

#FFMPEG vars
vidopts=""
audopts="-acodec pcm_s16le"


# ****NOTHING BELOW THIS POINT SHOULD BE CHANGED****

echo "*** $modulename Initialized - Converting $SOURCEPATH$FILENAME to $outputfile ***"
echo "$(date +%Y-%m-%d--%H:%M:%S) $modulename, INPUT: $SOURCEPATH$FILENAME, OUTPUT: $outputfile" >>/var/log/wdtv-VideoConversion.log

ffmpeg -y -i $SOURCEPATH$FILENAME $vidopts $audopts $outputfile 2>>/var/log/wdtv-VideoConversion.log

# Remove Source File
echo "============Removing file: $SOURCEPATH$FILENAME =========================="
cp $outputfile /mnt/AVArchives/TEMP
rm -f $SOURCEPATH$FILENAME 	#remove source file
rm -f $outputfile		#remove destination file
