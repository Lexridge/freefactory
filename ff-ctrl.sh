#!/bin/sh
#  FreeFactory (c) 2013 by Jim Hines 
#  Requirements: inotify-tools (namely inotifywait) and FFMPEG and FFmbc
#
#  ff-crl.sh
#  This script is the master control script. It calls sub-scripts to convert various video files.
#
#  usage:inotifywait -rme close_write /video/dropbox | /opt/FreeFactory/bin/ff-ffctrl.sh &
#
# INSTRUCTIONS:
# When creating a new FreeFactory, use an existing one for a template. You also need to add a specific watched 
# directory for the new factory script module.
#
# 1. Create a "watched" directory for the new factory module. ie /video/VideotoMP4.
# 2. Create your new module script. ie ff-ModuleName.sh and save it in $ffmodulesdir. Make it executiable (chmod 775). 
# 3. Edit ff-ffctrl.sh to add your new factory.
#	3a. copy an existing if statement for a template
#	3b. Edit the line commented with *EDIT THIS PATH FOR NEW FACTORY PATH* to include the new watched directory.
#	3c. Edit the line commented with *EDIT THIS PATH FOR NEW FACTORY SCRIPT* to include the new script path.
#
LOG=/var/log/ff-VideoConversion.log
ffmodulesdir="/opt/FreeFactory/ffmodules"

##################
function if_error
##################
{
	if [[ $? -ne 0 ]]; then 			# check return code passed to function
		print "$1 TIME:$TIME" | tee -a $LOG 	# if rc > 0 then print error msg and quit
		exit $?
	fi
}


for (( ; ; ))
do
	read SOURCEPATH NOTIFY FILENAME
	echo "============Checking $SOURCEPATH$FILENAME ================"
	
#	CHECK FOR DOT FILES AND DELETE THEM IF PRESENT
# 	if [ "${FILENAME:0:1}" = "." ]; then
# 		# if a dot file gets deleted before an Apple MAC is finished writing, it will cause a write error on the Mac. Default is 6 seconds
# 		# You may need to increase this if your network speed is slow.
 		sleep 30
# 		echo "------------ $SOURCEPATH$FILENAME Contains a DOT. It will be deleted --------------"
# 		rm -f "${SOURCEPATH}${FILENAME}"
# 		SOURCEPATH=""
# 		FILENAME=""
# 		echo "The SOURCEPATH =" $SOURCEPATH
# 		echo "The FILENAME =" $FILENAME
# 		$(exit 0)
# 	fi

# ===CHECK FOR SPECIFIED DIRECTORIES - ONLY ADD NEW FACTORY SCRIPTS BELOW THIS LINE ======

# =====	CLIENTMP4 =====================================
	if [ "${SOURCEPATH}" = "/video/dropbox/ClientMP4/" ]; then		   #EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-ClientConversion.sh $SOURCEPATH $FILENAME &  ##EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	CLIENTMP4HQ =====================================
	if [ "${SOURCEPATH}" = "/video/dropbox/ClientMP4HQ/" ]; then		   #EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-ClientConversionHQ.sh $SOURCEPATH $FILENAME &  ##EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	CITYNET FLASH SERVER ===========================
	if [ "${SOURCEPATH}" = "/video/dropbox/Citynet/" ]; then		#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-CitynetFlashServer.sh $SOURCEPATH $FILENAME & #EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	FINAL CUT PRO IMPORT CONVERT HD TO MOV ===========================
	if [ "${SOURCEPATH}" = "/video/dropbox/FCPConvert/" ]; then		#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-FCPConvert.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	FINAL CUT PRO IMPORT CONVERT TO SD MOV ===========================
	if [ "${SOURCEPATH}" = "/video/dropbox/FCPConvertSD/" ]; then		#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-FCPConvertSD.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	FINAL CUT PRO IMPORT CONVERT TO SD MP4 ===========================
	if [ "${SOURCEPATH}" = "/video/dropbox/FCPConvertMP4/" ]; then		#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-FCPConvertMP4.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	MythTV Conversion to MP4 with AC3 Audio =========================
	if [ "${SOURCEPATH}" = "/video/dropbox/MythTV/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-MythTVConversion.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	Audio file to Microsoft .WAV format =========================
	if [ "${SOURCEPATH}" = "/video/dropbox/Audio2Wav/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-Audio2WavConversion.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	Adtec Playback Conversion for CW =========================
	if [ "${SOURCEPATH}" = "/video/dropbox/CWAdtec/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-CW-Adtec.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	BlackStorm Server Conversion for News =========================
	if [ "${SOURCEPATH}" = "/video/dropbox/BlackStormNews/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-BlackStormNews.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	FastChannel File Conversion HD to Stereo Audio =========================
	if [ "${SOURCEPATH}" = "/video/dropbox/FastChannel/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-FastChannel2FCP.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	WBOY File Conversion HD ==============================================
	if [ "${SOURCEPATH}" = "/video/dropbox/To_WBOY/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-to-wboy.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# =====	COMCAST File Conversion HD ==============================================
	if [ "${SOURCEPATH}" = "/video/dropbox/To_Comcast/" ]; then			#EDIT THIS PATH FOR NEW FACTORY PATH
		echo "------------ The Source Path = $SOURCEPATH --------------"
		if [ "$FILENAME" != "" ]; then
			echo "Reading from" $SOURCEPATH$FILENAME
			$ffmodulesdir/ff-to-comcast.sh $SOURCEPATH $FILENAME &	#EDIT THIS PATH FOR NEW FACTORY SCRIPT
			SOURCEPATH=
			FILENAME=
		fi
	fi
# ===== CBS_NewsPath_HD ==============================================
        if [ "${SOURCEPATH}" = "/video/dropbox/CBS_NewsPath_HD/" ]; then                     #EDIT THIS PATH FOR NEW FACTORY PATH
                echo "------------ The Source Path = $SOURCEPATH --------------"
                if [ "$FILENAME" != "" ]; then
                        echo "Reading from" $SOURCEPATH$FILENAME
                        $ffmodulesdir/ff-CBS_NewsPath_HD.sh $SOURCEPATH $FILENAME &     #EDIT THIS PATH FOR NEW FACTORY SCRIPT
                        SOURCEPATH=
                        FILENAME=
                fi
        fi
# ===== HD to MPEG2 HD ==============================================
        if [ "${SOURCEPATH}" = "/video/dropbox/HD-to-MPEG2-HD/" ]; then                     #EDIT THIS PATH FOR NEW FACTORY PATH
                echo "------------ The Source Path = $SOURCEPATH --------------"
                if [ "$FILENAME" != "" ]; then
                        echo "Reading from" $SOURCEPATH$FILENAME
                        $ffmodulesdir/ff-HD-to-MPEG2-HD.sh $SOURCEPATH $FILENAME &     #EDIT THIS PATH FOR NEW FACTORY SCRIPT
                        SOURCEPATH=
                        FILENAME=
                fi
        fi
# ===== END ==========

# ===== To Suddenlink mp4  ==============================================
        if [ "${SOURCEPATH}" = "/video/dropbox/To_Suddenlink/" ]; then              #EDIT THIS PATH FOR NEW FACTORY PATH
                echo "------------ The Source Path = $SOURCEPATH --------------"
                if [ "$FILENAME" != "" ]; then
                        echo "Reading from" $SOURCEPATH$FILENAME
                        $ffmodulesdir/ff-to-suddenlink.sh $SOURCEPATH $FILENAME &     #EDIT THIS PATH FOR NEW FACTORY SCRIPT
                        SOURCEPATH=
                        FILENAME=
                fi
        fi
# ===== END ==========
# ===== To WCHS DNxHD  ==============================================
        if [ "${SOURCEPATH}" = "/video/dropbox/To_WCHS/" ]; then              #EDIT THIS PATH FOR NEW FACTORY PATH
                echo "------------ The Source Path = $SOURCEPATH --------------"
                if [ "$FILENAME" != "" ]; then
                        echo "Reading from" $SOURCEPATH$FILENAME
                        $ffmodulesdir/ff-WCHS.sh $SOURCEPATH $FILENAME &     #EDIT THIS PATH FOR NEW FACTORY SCRIPT
                        SOURCEPATH=
                        FILENAME=
                fi
        fi
# ===== END ==========
# ===== To CBS NewsPath MPEG2  ==============================================
        if [ "${SOURCEPATH}" = "/video/dropbox/NewsPath_Submit/" ]; then              #EDIT THIS PATH FOR NEW FACTORY PATH
                echo "------------ The Source Path = $SOURCEPATH --------------"
                if [ "$FILENAME" != "" ]; then
                        echo "Reading from" $SOURCEPATH$FILENAME
                        $ffmodulesdir/ff-NewsPath_Submit.sh $SOURCEPATH $FILENAME &     #EDIT THIS PATH FOR NEW FACTORY SCRIPT
                        SOURCEPATH=
                        FILENAME=
                fi
        fi
# ===== END ==========

done
