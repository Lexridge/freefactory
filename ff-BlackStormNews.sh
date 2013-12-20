#!/bin/bash
#  FreeFactory by Jim Hines 
#
#  FF Final Cut Pro Conversion (import) by Jim Hines
#!/bin/bash
#  FreeFactory (c) 2012-2013 by Jim Hines 
#  Requirements: inotify-tools (namely inotifywait), FFmpeg v0.10+ and FFmbc.
#  FFmpeg Copyright (c) 2000-2013 the FFmpeg developers
#  FFmbc Copyright (c) 2008-2013 Baptiste Coudurier and the FFmpeg developers
#
#  FreeFactory Ross Blackstorm Server Conversion by Jim Hines
#  This script takes an a/v file and converts it to a DVCPRO-HD file for Blackstorm server playout.
#  This script is called from ff-ctrl. It will not work on its own.
#  usage: inotifywait -rme close_write /video/dropbox | /opt/FreeFactory/bin/ff-ctrl.sh

modulename="Ross BlackStorm News Server Conversion script"
SOURCEPATH="$1"
FILENAME="$2"
# Get rid of file .SUFFIX
LENGTH=${#FILENAME}
outputpath="/video/"
#outputfile="/video/${FILENAME:0:$LENGTH-4}.mov"
outputfile="${FILENAME:0:$LENGTH-4}.mov"
deletedotfiles=0

#FFMPEG vars
ffprog="ffmbc"
vidopts="-target dvcprohd"
#audopts="-acodec pcm_s16le -b:a 256k -ar 48000 -ac 2"

echo "===============$modulename Initialized - Converting $SOURCEPATH$FILENAME to MOV================"
echo "$(date +%Y-%m-%d--%H:%M:%S) $modulename,"$SOURCEPATH$FILENAME >>/var/log/wdtv-VideoConversion.log
#echo "====================FILENAME = $FILENAME ============================================"

$ffprog -y -i $SOURCEPATH$FILENAME $vidopts $outputpath$outputfile 2>>/var/log/wdtv-VideoConversion.log

# Remove Source File
echo "============Removing file: $SOURCEPATH$FILENAME =========================="
rm -f $SOURCEPATH$FILENAME

# Copy new file to destinstation
#cp $outputfile /mnt/BlackStormMedia
# FTP new file to destination
echo "FTPing $outputfile to BlackStorm News"
cd $outputpath
wdtv-FTP-blackstorm1.sh $outputfile

# Remove newly created file
#rm -f $outputfile
# Check to see if allowed to delete our dot files
#if [ ${deletedotfiles} = 1 ]; then
#	echo "Deleting dot files"
#	rm -f $SOURCEPATH/.*
#fi
exit

