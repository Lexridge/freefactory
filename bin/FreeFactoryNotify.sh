#!/bin/bash
#############################################################################
#               This code is licensed under the GPLv3
#    The following terms apply to all files associated with the software
#    unless explicitly disclaimed in individual files or parts of files.
#
#                           Free Factory
#
#                          Copyright 2013
#                               by
#                     Jim Hines and Karl Swisher
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Script Name: FreeFactoryNotify.sh
#
#  This is script accepts the three variables piped by intofywait
#  and then passes two of them, the directory path and the file
#  name file name to the tcl conversion script.
#############################################################################
LOG=/var/log/FreeFactory/FreeFactoryNotifyError.log
####################################################################################
# This is what we want in the end so a \ will be added to spaces will be within
# a file name.  This does not work right now.
#replace spaces with slashe space
# LOG=`echo $LOG | sed  s/\ /\\ /g`
# This is what is being used as a work around.  The spaces are being replaced
# with the _ character.
# LOG=`echo $LOG | sed  s/\ /_/g`
####################################################################################
####################################################################################
#
# Start Read FreeFactory.config
#
# This code here opens up /opt/FreeFactory/FreeFactory.config to find the Apple delay
# variable and set the bash variable APPLEDELAY to that value.

    APPLEDELAY=0
    CONFIGLINES=`cat /opt/FreeFactory/FreeFactory.config`
    for line in $CONFIGLINES ; do

#  Find "APPLEDELAY=" in the config file
        if [ "${line:0:11}" = "APPLEDELAY=" ]; then
# $line string is actually "APPLEDELAY=30"
# Want to parse out the number 30 and set
# the bash APPLEDELAY variable to that number.

# Set variable to value
        APPLEDELAY="${line:11:3}"
         fi
    done
#
# End Read FreeFactory.config
#
####################################################################################
# Clear variables to null value
SOURCEPATH=
NOTIFY_EVENT=
FILENAME=
LASTSOURCEPATH=
LASTFILENAME=
FILESIZE=0
LASTFILESIZE=0
####################################################################################
# Set up continous loop.
for (( ; ; ))
do
####################################################################################
# Read variables piped in from inotifywait
    read SOURCEPATH NOTIFY_EVENT FILENAME
# Get file size to compare when the file is completely written.
    FILESIZE=$(stat -c%s "$SOURCEPATH$FILENAME")
# This loop repeats the above procedure until the file
# size does not change.
    while [ $FILESIZE -ne $LASTFILESIZE ]
    do
        LASTFILESIZE=$FILESIZE
        FILESIZE=$(stat -c%s "$SOURCEPATH$FILENAME")
        sleep 5
    done
####################################################################################
# Write variables to the stdout which is screen
    echo ""
    echo "*****************************************************************************************"
    echo "********************************* Report From *******************************************"
    echo "***************************** FreeFactoryNotify.sh **************************************"
    echo "============ Received the following variables from inotifywait"
    echo "============ Directory path and filename $SOURCEPATH$FILENAME"
    echo "============ Inotify Event   $NOTIFY_EVENT"
####################################################################################
#
# Start Apple work around.
#
# This code here looks for the "." file created when a Apple computer writes
# to a directory.  If the file name passed from inotifywait starts with a dot
# then an Apple file has started writing.  Apple will close and reopen the
# data file it is writing to every 512 bytes and thus trigering inotifywait
# with false positives. This code does two things when encountering a file
# from an Apple.  One do not allow the script to call the tcl conversion
# program on a file prefixed with a dot.  Two put this script to sleep for a
# user determined time to allow for the Apple to finished the write.  Writing
# must be completed and the file closed before the conversion can be done.
#
# Additional Apple Notes:
# If a dot file gets deleted before an Apple MAC is finished writing, it will
# cause a write error on the Mac. Default delay value is set to 0.  Set value
# according to your network speed. A good value to start with is 30.

# variable and set the bash variable APPLEDELAY to that value.





# Checking for dot files
 if [ "${FILENAME:0:1}" != "." ]; then
        /opt/FreeFactory/bin/FreeFactoryConversion.tcl $SOURCEPATH $FILENAME 2>> $LOG &
        echo "============ Running Free Fractory conversion script."
        echo "============ Converting $SOURCEPATH$FILENAME"
        echo "*****************************************************************************************"
        echo "*****************************************************************************************"
 fi 
#
# End Apple work around.
#
####################################################################################
# Clear variables to null value
    SOURCEPATH=
    NOTIFY_EVENT=
    FILENAME=
# ===== END ==========
# End continous loop
done
# Exit script.
exit
