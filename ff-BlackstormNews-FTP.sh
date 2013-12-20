#!/bin/bash

filename="$1"
echo "Uploading" $1 "to Blackstorm Video Server"

host=192.168.0.1        #This is the FTP servers host or IP address.
user=blackstorm         #This is the default FTP user that has access to the server.
pass=blackstorm         #This is the default password for the FTP user.

# Call 1. Uses the ftp command with the -inv switches.  -i turns off interactive prompting. -n Restrains FTP from attempting the auto-login feature. -v enables verbose and progress. 
echo "FILNAME="$filename

ftp -n 192.168.0.1 <<END_SCRIPT

quote USER $user
quote PASS $pass
cd media
put "$filename"
quit
END_SCRIPT

