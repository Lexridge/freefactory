#!/bin/sh
# the next line restarts using tclsh\
exec tclsh "$0" "$@"
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
# Script Name:FreeFactoryConversion.tcl
#
#  This script converts the file passed in the SoureFileName variable
#  to a output file in a output directory with the audio and video
#  options specified in the factory. This script calls ffmpeg or
#  ffmbc to do the conversion.
#############################################################################
proc ::main {argc argv} {
# Get notify variables passed from inotify passed from FreeFactoryNotify.sh
	set PassedVariables $argv
# Parse out fields. Done in a manner that perserves directories or file names with spaces.
	set LastSlash [string last "/" $PassedVariables]
# Parse out Directory path, the first variable
	set SourcePath [string trim [string range $PassedVariables 0 $LastSlash]]
# Parse the file name
	set SourceFileName [string trim [string range $PassedVariables [expr $LastSlash + 1] end]]
########################################################################################
#
# Start execute only if source file exists
	if {[file exists "$SourcePath$SourceFileName"]} {
# Strip file extention from file name
		set ExtensionDelimiter [string last "." $SourceFileName]
		set SourceFileNameRoot [string range $SourceFileName 0 [expr $ExtensionDelimiter - 1]]
		set FactoryCounter 0
########################################################################################
#
# Start Loading Factories into array
#
# Load factories into array
		foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
			incr FactoryCounter
			set FileHandle [open $item r]
########################################################################################
#
# Start file open and while loop of reading each line

			while {![eof $FileHandle]} {
				gets $FileHandle FactoryVar
				set EqualDelimiter [string first "=" $FactoryVar]
				if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
					set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
					set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
					switch $FactoryField {
						"FACTORYDESCRIPTION" {set FactoryArray($FactoryCounter,FactoryDescription) $FactoryValue}
						"NOTIFYDIRECTORY" {set FactoryArray($FactoryCounter,NotifyDirectory) $FactoryValue}
						"OUTPUTDIRECTORY" {set FactoryArray($FactoryCounter,OutputDirectory) $FactoryValue}
						"OUTPUTFILESUFFIX" {set FactoryArray($FactoryCounter,OutputFileSuffix) $FactoryValue}
						"CONVERSIONPROGRAM" {set FactoryArray($FactoryCounter,ConversionProgram) $FactoryValue}
						"FTPPROGRAM" {set FactoryArray($FactoryCounter,FTPProgram) $FactoryValue}
						"FTPURL" {set FactoryArray($FactoryCounter,FTPURL) $FactoryValue}
						"FTPUSERNAME" {set FactoryArray($FactoryCounter,FTPUserName) $FactoryValue}
						"FTPPASSWORD" {set FactoryArray($FactoryCounter,FTPPassword) $FactoryValue}
						"FTPREMOTEPATH" {set FactoryArray($FactoryCounter,FTPRemotePath) $FactoryValue}
						"FTPTRANSFERTYPE" {set FactoryArray($FactoryCounter,FTPTransferType) $FactoryValue}
						"VIDEOCODECS" {set FactoryArray($FactoryCounter,VideoCodecs) $FactoryValue}
						"VIDEOWRAPPER" {set FactoryArray($FactoryCounter,VideoWrapper) $FactoryValue}
						"VIDEOFRAMERATE" {set FactoryArray($FactoryCounter,VideoFrameRate) $FactoryValue}
						"VIDEOSIZE" {set FactoryArray($FactoryCounter,VideoSize) $FactoryValue}
						"VIDEOTARGET" {set FactoryArray($FactoryCounter,VideoTarget) $FactoryValue}
						"VIDEOTAGS" {set FactoryArray($FactoryCounter,VideoTags) $FactoryValue}
						"THREADS" {set FactoryArray($FactoryCounter,Threads) $FactoryValue}
						"ASPECT" {set FactoryArray($FactoryCounter,Aspect) $FactoryValue}
						"VIDEOBITRATE" {set FactoryArray($FactoryCounter,VideoBitRate) $FactoryValue}
						"VIDEOPRESET" {set FactoryArray($FactoryCounter,VideoPreset) $FactoryValue}
						"VIDEOSTREAMID" {set FactoryArray($FactoryCounter,VideoStreamID) $FactoryValue}
						"GROUPPICSIZE" {set FactoryArray($FactoryCounter,GroupPicSize) $FactoryValue}
						"BFRAMES" {set FactoryArray($FactoryCounter,BFrames) $FactoryValue}
						"FRAMESTRATEGY" {set FactoryArray($FactoryCounter,FrameStrategy) $FactoryValue}
						"FORCEFORMAT" {set FactoryArray($FactoryCounter,ForceFormat) $FactoryValue}
						"STARTTIMEOFFSET" {set FactoryArray($FactoryCounter,StartTimeOffset) $FactoryValue}
						"AUDIOCODECS" {set FactoryArray($FactoryCounter,AudioCodecs) $FactoryValue}
						"AUDIOBITRATE" {set FactoryArray($FactoryCounter,AudioBitRate) $FactoryValue}
						"AUDIOSAMPLERATE" {set FactoryArray($FactoryCounter,AudioSampleRate) $FactoryValue}
						"AUDIOFILEEXTENSION" {set FactoryArray($FactoryCounter,AudioFileExtension) $FactoryValue}
						"AUDIOTAG" {set FactoryArray($FactoryCounter,AudioTag) $FactoryValue}
						"AUDIOCHANNELS" {set FactoryArray($FactoryCounter,AudioChannels) $FactoryValue}
						"AUDIOSTREAMID" {set FactoryArray($FactoryCounter,AudioStreamID) $FactoryValue}
						"DELETECONVERSIONLOGS" {set FactoryArray($FactoryCounter,DeleteConversionLogs) $FactoryValue}
					}
				}
			}
			close $FileHandle
#
# End file open and while loop of reading each line
########################################################################################

		}
#
# End Loading Factories into array
########################################################################################

# Now scroll through the factories to see if the notify directory passed matches
# the directory stored in the factory.
		set FFMx_AVOptions ""
		set TotalFactories $FactoryCounter
########################################################################################
#
# Start for loop to search array

		for {set FactoryCounter 1} {$FactoryCounter <= $TotalFactories} {incr FactoryCounter} {

########################################################################################
#
# Start notify directory match made

# If match occures then assemble the AV options from the factory.
			if {$SourcePath == $FactoryArray($FactoryCounter,NotifyDirectory)} {
########################################################################################
# Set log file for this script
				set ConversionLogCMD "/opt/FreeFactory/Logs/FreeFactoryConversion-$SourceFileNameRoot.log"
########################################################################################
# Not used not but in the future when log file names with spaces are use with a
#  \ not replaced with the _ character.

# This is what is being used as a work around.  The spaces are being replaced
# with the _ character.
				set ParseString $ConversionLogCMD
				set BuildString ""
				set SpacePos [string first " " $ParseString]
				while {$SpacePos > -1} {
					append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
					append BuildString "_"
					set ParseString [string range $ParseString [expr $SpacePos +1] end]
					set SpacePos [string first " " $ParseString]
					if {$SpacePos < 0} {
						append BuildString $ParseString
						set ConversionLogCMD $BuildString
					}
				}
########################################################################################
#  Report error to the screen and exit when conversion program is not set.
				if {$FactoryArray($FactoryCounter,ConversionProgram) == "" || ($FactoryArray($FactoryCounter,ConversionProgram) !="ffmpeg" && $FactoryArray($FactoryCounter,ConversionProgram) !="ffmbc")} {
					puts "*****************************************************************************************"
					puts "****************************** ERROR Report From ****************************************"
					puts "*************************** FreeFactoryConversion.tcl ***********************************"
					puts "============ ERROR - No Conversion was started on $SourceFileName"
					puts "============ Ending FreeFactoryConversion.tcl early because FFMx program is"
					puts "============ not set correctly in factory $FactoryArray($FactoryCounter,FactoryDescription).  This variable"
					puts "============ must be set to either ffmpeg or ffmbc.  Run FreeFactory.tcl"
					puts "============ and save this factory with the Conversion Program variable"
					puts "============ set."
					puts "*****************************************************************************************"
					puts "*****************************************************************************************"
					exec echo "*****************************************************************************************" >> $ConversionLogCMD
					exec echo "****************************** ERROR Report From ****************************************" >> $ConversionLogCMD
					exec echo "*************************** FreeFactoryConversion.tcl ***********************************" >> $ConversionLogCMD
					exec echo "============ ERROR - No Conversion was started on $SourceFileName" >> $ConversionLogCMD
					exec echo "============ Ending FreeFactoryConversion.tcl early because FFMx program is" >> $ConversionLogCMD
					exec echo "============ not set correctly in factory $FactoryArray($FactoryCounter,FactoryDescription).  This variable" >> $ConversionLogCMD
					exec echo "============ must be set to either ffmpeg or ffmbc.  Run FreeFactory.tcl" >> $ConversionLogCMD
					exec echo "============ and save this factory with the Conversion Program variable" >> $ConversionLogCMD
					exec echo "============ set." >> $ConversionLogCMD
					exec echo "*****************************************************************************************" >> $ConversionLogCMD
					exec echo "*****************************************************************************************" >> $ConversionLogCMD
					exit
				}
########################################################################################
########################################################################################
########################################################################################
#
# Start Assemble A/V options
#
# FFMx means either ffmpeg or ffmbc
#
# This code section assembles the A/V options for FFMx in two ways.
# One way is appending to the FFMx_AVOptions string variable.  The
# other way is to create a variable for each parameter and it's value.
#
########################################################################################
#
# This code here initializies when trying to use one large multi line exec command instead
# of all the condition statements.  This has not been successful yet.
#

#				for {set ParamCount 1} {$ParmCount <=40} {incr ParmCount} {
#					set ParamString$ParamCount ""
#					set ParamStringValue$ParamCount ""
#				}
########################################################################################
# Initialize the number of parameter options to zero.  Will be incremented to
# the next number before use in variable creation.
				set ParamCount 0
# If variable is not null then add to options. Extra checking is done by triming the string during
# condition checking to compare against single or  multiple spaces only instead of a null variable
				if {[string trim $FactoryArray($FactoryCounter,VideoCodecs)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-vcodec"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoCodecs)
					append FFMx_AVOptions "-vcodec "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoCodecs) "
				}
				if {[string trim $FactoryArray($FactoryCounter,OutputFileSuffix)] != ""} {
					append SourceFileNameRoot $FactoryArray($FactoryCounter,OutputFileSuffix)
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoWrapper)] != ""} {
					append SourceFileNameRoot $FactoryArray($FactoryCounter,VideoWrapper)
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoFrameRate)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-v:r"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoFrameRate)
					append FFMx_AVOptions "-v:r "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoFrameRate) "
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoSize)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-s"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoSize)
					append FFMx_AVOptions "-s "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoSize) "
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoTarget)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-target"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoTarget)
					append FFMx_AVOptions "-target "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoTarget) "
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoTags)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-vtag"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoTags)
					append FFMx_AVOptions "-vtag "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoTags) "
				}
				if {[string trim $FactoryArray($FactoryCounter,Threads)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-vtag"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoTags)
					append FFMx_AVOptions "-threads "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,Threads) "
				}
				if {[string trim $FactoryArray($FactoryCounter,Aspect)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-aspect"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,Aspect)
					append FFMx_AVOptions "-aspect "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,Aspect) "
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoBitRate)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-b:v"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoBitRate)
					append FFMx_AVOptions "-b:v "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoBitRate) "
				}
				if {[string trim $FactoryArray($FactoryCounter,VideoPreset)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-vpre"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoPreset)
					append FFMx_AVOptions "-vpre "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoPreset) "

				}
				if {[string trim $FactoryArray($FactoryCounter,VideoStreamID)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-map"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,VideoStreamID)
					append FFMx_AVOptions "-map "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,VideoStreamID) "
				}
				if {[string trim $FactoryArray($FactoryCounter,GroupPicSize)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-g"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,GroupPicSize)
					append FFMx_AVOptions "-g "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,GroupPicSize) "
				}
				if {[string trim $FactoryArray($FactoryCounter,BFrames)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-bf"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,BFrames)
					append FFMx_AVOptions "-bf "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,BFrames) "
				}
				if {[string trim $FactoryArray($FactoryCounter,FrameStrategy)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-b_strategy"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,FrameStrategy)
					append FFMx_AVOptions "-b_strategy "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,FrameStrategy) "
				}
				if {[string trim $FactoryArray($FactoryCounter,ForceFormat)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-f"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,ForceFormat)
					append FFMx_AVOptions "-f "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,ForceFormat) "
				}
				if {[string trim $FactoryArray($FactoryCounter,StartTimeOffset)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-ss"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,StartTimeOffset)
					append FFMx_AVOptions "-ss "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,StartTimeOffset) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioCodecs)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-acodec"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioCodecs)
					append FFMx_AVOptions "-acodec "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioCodecs) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioBitRate)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-b:a"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioBitRate)
					append FFMx_AVOptions "-b:a "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioBitRate) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioSampleRate)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-ar"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioSampleRate)
					append FFMx_AVOptions "-ar "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioSampleRate) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioFileExtension)] != ""} {
					append SourceFileNameRoot $FactoryArray($FactoryCounter,AudioFileExtension)
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioTag)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-atag"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioTag)
					append FFMx_AVOptions "-atag "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioTag) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioChannels)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-ac"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioChannels)
					append FFMx_AVOptions "-ac "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioChannels) "
				}
				if {[string trim $FactoryArray($FactoryCounter,AudioStreamID)] != ""} {
					incr ParamCount
					set ParamString$ParamCount "-map"
					set ParamStringValue$ParamCount $FactoryArray($FactoryCounter,AudioStreamID)
					append FFMx_AVOptions "-map "
					append FFMx_AVOptions "$FactoryArray($FactoryCounter,AudioStreamID) "
				}
#
# End Assemble A/V options
#
########################################################################################
########################################################################################
########################################################################################
########################################################################################
########################################################################################
########################################################################################
# This code here is a safety check to make sure all directory paths end in a /.
#
# If notify directory path does not end in a slash then append it.
				if {[expr [string last "/" $FactoryArray($FactoryCounter,NotifyDirectory)] + 1] < [string length $FactoryArray($FactoryCounter,NotifyDirectory)]} {
					append FactoryArray($FactoryCounter,NotifyDirectory) "/"
				}
# If output path directory path does not end in a slash then append it.
				if {[expr [string last "/" $FactoryArray($FactoryCounter,OutputDirectory)] + 1] < [string length $FactoryArray($FactoryCounter,OutputDirectory)]} {
				append FactoryArray($FactoryCounter,OutputDirectory) "/"
				}
########################################################################################
# Set log file
				set ConversionLog "/opt/FreeFactory/Logs/FreeFactoryConversion-$SourceFileNameRoot.log"

########################################################################################
# Not used not but in the future when log file names with spaces are use with a
#  \ not replaced with the _ character.

# This is what is being used as a work around.  The spaces are being replaced
# with the _ character.
				set ConversionLogCMD $ConversionLog
				set ParseString $ConversionLog
				set BuildString ""
				set SpacePos [string first " " $ParseString]
				while {$SpacePos > -1} {
					append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
					append BuildString "_"
					set ParseString [string range $ParseString [expr $SpacePos +1] end]
					set SpacePos [string first " " $ParseString]
					if {$SpacePos < 0} {
						append BuildString $ParseString
						set ConversionLogCMD $BuildString
#						set ConversionLog $ConversionLogCMD
					}
				}
########################################################################################
#
# This code inserts a escape character before any spaces in the ConversionLogCMD
# variable.  This variable is used in the echo commands to the log file.
#				set ConversionLogCMD $ConversionLog
#				set ParseString $ConversionLog
#				set BuildString ""
#				set SpacePos [string first " " $ParseString]
#				while {$SpacePos > -1} {
#					append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
#					append BuildString "\\ "
#					set ParseString [string range $ParseString [expr $SpacePos +1] end]
#					set SpacePos [string first " " $ParseString]
#					if {$SpacePos < 0} {
#						append BuildString $ParseString
#						set ConversionLogCMD $BuildString
#					}
#				}
########################################################################################
########################################################################################
########################################################################################
# This sets the Start Date/Time Stamp for the log file
				set SystemTime ""
# Get month
				append SystemTime [clock format [clock seconds] -format %m]
				append SystemTime "-"
# Get day
				append SystemTime [clock format [clock seconds] -format %d]
				append SystemTime "-"
# Get year
				append SystemTime [clock format [clock seconds] -format %y]  "  "
# Get hour
				append SystemTime [clock format [clock seconds] -format %I]
				append SystemTime ":"
# Get minutes
				append SystemTime [clock format [clock seconds] -format %M]
				append SystemTime ":"
# Get seconds
				append SystemTime [clock format [clock seconds] -format %S] " "
# Append AM PM
				append SystemTime [clock format [clock seconds] -format %p]
########################################################################################
########################################################################################
########################################################################################
# Write factory description, notification directory, file to be processed and
# the processed file name to standard out ie screen
				puts "*****************************************************************************************"
				puts "********************************* Report From *******************************************"
				puts "*************************** FreeFactoryConversion.tcl ***********************************"
				puts "============ $FactoryArray($FactoryCounter,FactoryDescription) Initialized"
				puts "============ Converting: $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName"
				puts "============ To: $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
				puts "============ Start time:$SystemTime $FactoryArray($FactoryCounter,FactoryDescription)"

# Write Date/Time Stamp, factory description, notify directory, source file and output file
# to log file.
				exec echo "*****************************************************************************************" >> $ConversionLogCMD
				exec echo "********************************* Report From *******************************************" >> $ConversionLogCMD
				exec echo "*************************** FreeFactoryConversion.tcl ***********************************" >> $ConversionLogCMD
				exec echo "============ $FactoryArray($FactoryCounter,FactoryDescription) Initialized" >> $ConversionLogCMD
				exec echo "============ Converting: $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName" >> $ConversionLogCMD
				exec echo "============ To: $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot" >> $ConversionLogCMD
				exec echo "============ Start time:$SystemTime $FactoryArray($FactoryCounter,FactoryDescription)" >> $ConversionLogCMD
########################################################################################
########################################################################################
########################################################################################
# Start execution section
#
# This section executes the chosen FFMx program to do the conversion.
#
# FFMx means either ffmpeg or ffmbc
#
# The peferred code would execute in only one line.  In order to do
# this and pass all of the audio and video options in one string
# variable entire command line must be in quotes with bash -c inserted
# between the exec and the entire command string. The draw back in doing
# it in one line is it will fail when the direcotry paths or file names
# contain spaces.
#
# Running the exec command without the bash -c inserted and the entire
# command line in quotes allow for precessing of directories and file
# names in quotes.  However that will cause the single line command to
# fail in using a single variable to pass the audio and video options
# to the FFMx command.  This requires much more code since each
# factory can and most likely will contain different options from
# each other. A condition statement must be setup for each number of
# options.  If a total of 40 possible options are available to be passed
# by this program then 40 condition statements must be set.
#
# Currently that is what is done here.  Trading code size for the
# ability to process directories and files with spaces.
#
#
#
############################
############################
# This code inserts an escape character
# before a space in a directory or file
# name variable that has spaces. This did not
# help in the conversion of directories or
# file names with spaces in the single line
# method

#set ParseString $SourceFileName
#set BuildString ""
#set SpacePos [string first " " $ParseString]
#while {$SpacePos > -1} {
#	append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
#	append BuildString "\\ "
#	set ParseString [string range $ParseString [expr $SpacePos +1] end]
#	set SpacePos [string first " " $ParseString]
#	if {$SpacePos < 0} {
#		append BuildString $ParseString
#		set SourceFileName $BuildString
#	}
#}
#set ParseString $SourceFileNameRoot
#set BuildString ""
#set SpacePos [string first " " $ParseString]
#while {$SpacePos > -1} {
#	append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
#	append BuildString "\\ "
#	set ParseString [string range $ParseString [expr $SpacePos +1] end]
#	set SpacePos [string first " " $ParseString]
#	if {$SpacePos < 0} {
#		append BuildString $ParseString
#		set SourceFileNameRoot $BuildString
#	}
#}
				set FFMxLog "/opt/FreeFactory/Logs/FreeFactoryFFMxLog-$SourceFileName.log"
# Write FFMx command to log
				exec echo  "########################################################################################################" >> $ConversionLogCMD
				exec echo  "FFMx Command String:" >> $ConversionLogCMD
				exec echo  "$FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName $FFMx_AVOptions $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog" >> $ConversionLogCMD
				exec echo  "########################################################################################################" >> $ConversionLogCMD
				exec echo  "########################################################################################################" >> $FFMxLog
				exec echo  "FFMx Command String:" >> $FFMxLog
				exec echo  "$FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName $FFMx_AVOptions $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog" >> $FFMxLog
				exec echo  "########################################################################################################" >> $FFMxLog

########################################################################################
# Execute the FFMx conversion program.
#

# This is the single line method
#				exec bash -c "$FactoryArray($FactoryCounter,ConversionProgram) -y -i \"$FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName\" \"$FFMx_AVOptions $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot\" 2>> $FFMxLog"

# This is execution based on the number of A/V options.

				if {$ParamCount == 1} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 2} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 3} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 4} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 5} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 6} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 7} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 8} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 9} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 10} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 11} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 12} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 13} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 14} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 15} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 16} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 17} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 18} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 19} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 20} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 21} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 22} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 23} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 24} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 25} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 26} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 27} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 28} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 29} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 30} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 31} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 32} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 33} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 34} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 35} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 36} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$ParamString36 $ParamStringValue36 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 37} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$ParamString36 $ParamStringValue36 \
					$ParamString37 $ParamStringValue37 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 38} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$ParamString36 $ParamStringValue36 \
					$ParamString37 $ParamStringValue37 \
					$ParamString38 $ParamStringValue38 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 39} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$ParamString36 $ParamStringValue36 \
					$ParamString37 $ParamStringValue37 \
					$ParamString38 $ParamStringValue38 \
					$ParamString39 $ParamStringValue39 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}
				if {$ParamCount == 40} {
					exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
					$ParamString1 $ParamStringValue1 \
					$ParamString2 $ParamStringValue2 \
					$ParamString3 $ParamStringValue3 \
					$ParamString4 $ParamStringValue4 \
					$ParamString5 $ParamStringValue5 \
					$ParamString6 $ParamStringValue6 \
					$ParamString7 $ParamStringValue7 \
					$ParamString8 $ParamStringValue8 \
					$ParamString9 $ParamStringValue9 \
					$ParamString10 $ParamStringValue10 \
					$ParamString11 $ParamStringValue11 \
					$ParamString12 $ParamStringValue12 \
					$ParamString13 $ParamStringValue13 \
					$ParamString14 $ParamStringValue14 \
					$ParamString15 $ParamStringValue15 \
					$ParamString16 $ParamStringValue16 \
					$ParamString17 $ParamStringValue17 \
					$ParamString18 $ParamStringValue18 \
					$ParamString19 $ParamStringValue19 \
					$ParamString20 $ParamStringValue20 \
					$ParamString21 $ParamStringValue21 \
					$ParamString22 $ParamStringValue22 \
					$ParamString23 $ParamStringValue23 \
					$ParamString24 $ParamStringValue24 \
					$ParamString25 $ParamStringValue25 \
					$ParamString26 $ParamStringValue26 \
					$ParamString27 $ParamStringValue27 \
					$ParamString28 $ParamStringValue28 \
					$ParamString29 $ParamStringValue29 \
					$ParamString30 $ParamStringValue30 \
					$ParamString31 $ParamStringValue31 \
					$ParamString32 $ParamStringValue32 \
					$ParamString33 $ParamStringValue33 \
					$ParamString34 $ParamStringValue34 \
					$ParamString35 $ParamStringValue35 \
					$ParamString36 $ParamStringValue36 \
					$ParamString37 $ParamStringValue37 \
					$ParamString38 $ParamStringValue38 \
					$ParamString39 $ParamStringValue39 \
					$ParamString40 $ParamStringValue40 \
					$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
				}

###########################################################################
# This was tried instead all the contition statements
# to have one exec command with all 40 options provided
# by this program.  All Params and Values were initialized
# to either "" or " ".  in either case this failed on
# execution
#				exec $FactoryArray($FactoryCounter,ConversionProgram) -y -i $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName \
#				$ParamString1 $ParamStringValue1 \
#				$ParamString2 $ParamStringValue2 \
#				$ParamString3 $ParamStringValue3 \
#				$ParamString4 $ParamStringValue4 \
#				$ParamString5 $ParamStringValue5 \
#				$ParamString6 $ParamStringValue6 \
#				$ParamString7 $ParamStringValue7 \
#				$ParamString8 $ParamStringValue8 \
#				$ParamString9 $ParamStringValue9 \
#				$ParamString10 $ParamStringValue10 \
#				$ParamString11 $ParamStringValue11 \
#				$ParamString12 $ParamStringValue12 \
#				$ParamString13 $ParamStringValue13 \
#				$ParamString14 $ParamStringValue14 \
#				$ParamString15 $ParamStringValue15 \
#				$ParamString16 $ParamStringValue16 \
#				$ParamString17 $ParamStringValue17 \
#				$ParamString18 $ParamStringValue18 \
#				$ParamString19 $ParamStringValue19 \
#				$ParamString20 $ParamStringValue20 \
#				$ParamString21 $ParamStringValue21 \
#				$ParamString22 $ParamStringValue22 \
#				$ParamString23 $ParamStringValue23 \
#				$ParamString24 $ParamStringValue24 \
#				$ParamString25 $ParamStringValue25 \
#				$ParamString26 $ParamStringValue26 \
#				$ParamString27 $ParamStringValue27 \
#				$ParamString28 $ParamStringValue28 \
#				$ParamString29 $ParamStringValue29 \
#				$ParamString30 $ParamStringValue30 \
#				$ParamString31 $ParamStringValue31 \
#				$ParamString32 $ParamStringValue32 \
#				$ParamString33 $ParamStringValue33 \
#				$ParamString34 $ParamStringValue34 \
#				$ParamString35 $ParamStringValue35 \
#				$ParamString36 $ParamStringValue36 \
#				$ParamString37 $ParamStringValue37 \
#				$ParamString38 $ParamStringValue38 \
#				$ParamString39 $ParamStringValue39 \
#				$ParamString40 $ParamStringValue40 \
#				$FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot 2>> $FFMxLog
#
#
# End execution section
########################################################################################
########################################################################################
########################################################################################



########################################################################################
# This sets the End Date/Time Stamp for the log file
				set SystemTime ""
# Get month
				append SystemTime [clock format [clock seconds] -format %m]
				append SystemTime "-"
# Get day
				append SystemTime [clock format [clock seconds] -format %d]
				append SystemTime "-"
# Get year
				append SystemTime [clock format [clock seconds] -format %y]  "  "
# Get hour
				append SystemTime [clock format [clock seconds] -format %I]
				append SystemTime ":"
# Get minutes
				append SystemTime [clock format [clock seconds] -format %M]
				append SystemTime ":"
# Get seconds
				append SystemTime [clock format [clock seconds] -format %S] " "
# Append AM PM
				append SystemTime [clock format [clock seconds] -format %p]
########################################################################################
########################################################################################
########################################################################################
# Write Date/Time Stamp, factory description, notify directory, source file and output file
# to screen and log file.

# Write success and the converted file name and output path to standard out ie screen
				puts "============ Conversion successful of: $SourceFileNameRoot"
				puts "============ To the directory: $FactoryArray($FactoryCounter,OutputDirectory)"
				puts "============ From the source: $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName"
				puts "============ End time on conversion:$SystemTime $FactoryArray($FactoryCounter,FactoryDescription)"
# Write success and the converted file name and output path to conversion log file
				exec echo "============ Conversion successful of: $SourceFileNameRoot" >> $ConversionLogCMD
				exec echo "============ To the directory: $FactoryArray($FactoryCounter,OutputDirectory)" >> $ConversionLogCMD
				exec echo "============ From the source: $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName" >> $ConversionLogCMD
				exec echo "============ End time on conversion:$SystemTime $FactoryArray($FactoryCounter,FactoryDescription)" >> $ConversionLogCMD
########################################################################################
########################################################################################
########################################################################################
########################################################################################
########################################################################################
########################################################################################
#
#
# This section if for FTP. An attempt is being made to find one
# FTP program that will work in all three FTP protocols currently
# used at WDTV.  Jim is doing a search for this.
#
# Set to FTPScript to null. Will not try to delete below if set
# to null.
				set FTPScript ""
# Only execute this code for FTP if the URL and the FTP program name variables are not blank.
				if {[string trim $FactoryArray($FactoryCounter,FTPProgram)] != "" && [string trim $FactoryArray($FactoryCounter,FTPURL)] != ""} {
				puts "============ Starting FTP"
############################
# Set FTP script path
					set FTPScript "/opt/FreeFactory/bin/FTPScript-$SourceFileNameRoot.sh"
#					append FTPScript ".sh"
					set FTPLog "/opt/FreeFactory/Logs/FreeFactoryFTP-$SourceFileNameRoot.log"
########################################################################################
# This code inserts a escape character before any spaces in the ErrorLogCMD
# variable.  This variable is used in the echo commands to the log file.

					set FTPLogCMD $FTPLog
					set ParseString $FTPLog
					set BuildString ""
					set SpacePos [string first " " $ParseString]
					while {$SpacePos > -1} {
						append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
						append BuildString "_"
						set ParseString [string range $ParseString [expr $SpacePos +1] end]
						set SpacePos [string first " " $ParseString]
						if {$SpacePos < 0} {
							append BuildString $ParseString
							set FTPLogCMD $BuildString
							set FTPLog $FTPLogCMD
						}
					}
########################################################################################
########################################################################################
# Not used not but in the future when log file names with spaces are use with a
#  \ not replaced with the _ character.
#
# This code inserts a escape character before any spaces in the FTPLogCMD
# variable.  This variable is used in the echo commands to the log file.
#					set FTPLogCMD $FTPLog
#					set ParseString $FTPLog
#					set BuildString ""
#					set SpacePos [string first " " $ParseString]
#					while {$SpacePos > -1} {
#						append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
#						append BuildString "\\ "
#						set ParseString [string range $ParseString [expr $SpacePos +1] end]
#						set SpacePos [string first " " $ParseString]
#						if {$SpacePos < 0} {
#							append BuildString $ParseString
#							set FTPLogCMD $BuildString
#						}
#					}
########################################################################################
############################
# This part only writes the variables out to the log file.
# and could be removed in the future
					exec echo "" >> $FTPLogCMD
					set tmpstring "This is from FreeFactoryConversion.tcl before exec - $SourceFileNameRoot"
					exec bash -c "echo $tmpstring $SourceFileNameRoot" >> $FTPLogCMD
					set tmpstring "OutputDirectory="
					exec bash -c "echo $tmpstring  $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot" >> $FTPLogCMD
					set tmpstring "User Name="
					exec bash -c "echo $tmpstring $FactoryArray($FactoryCounter,FTPUserName)" >> $FTPLogCMD
					set tmpstring "Password="
					exec bash -c "echo $tmpstring $FactoryArray($FactoryCounter,FTPPassword)" >> $FTPLogCMD
					set tmpstring "URL="
					exec bash -c "echo $tmpstring $FactoryArray($FactoryCounter,FTPURL)" >> $FTPLogCMD
					set tmpstring "User Description="
					exec bash -c "echo $tmpstring $FactoryArray($FactoryCounter,FactoryDescription)" >> $FTPLogCMD
					set tmpstring "User Remote Path="
					exec bash -c "echo $tmpstring $FactoryArray($FactoryCounter,FTPRemotePath)" >> $FTPLogCMD
					exec echo ""   >> $FTPLogCMD
					puts "============ Writing to FTP script $FTPScript"
					exec echo "============ Writing to FTP script $FTPScript" >> $ConversionLogCMD
					exec echo "============ Writing to FTP script $FTPScript" >> $FTPLogCMD

# Open path to it bash FTP script
					set FTPBashHandle [open $FTPScript w]
# Write header
					puts $FTPBashHandle "#!/bin/bash"
					puts $FTPBashHandle "# Temporary FTP Program"
					puts $FTPBashHandle "#"
# Write to depending on which FTP program is chosen
					if {[string trim $FactoryArray($FactoryCounter,FTPProgram)] == "ftp"} {
						puts $FTPBashHandle "ftp -n $FactoryArray($FactoryCounter,FTPURL) <<END_SCRIPT"
						puts $FTPBashHandle "quote USER $FactoryArray($FactoryCounter,FTPUserName)"
						puts $FTPBashHandle "quote PASS $FactoryArray($FactoryCounter,FTPPassword)"
						if {$FactoryArray($FactoryCounter,FTPTransferType) == "bin"} {
							puts $FTPBashHandle "binary"
						}
						if {$FactoryArray($FactoryCounter,FTPTransferType) == "asc"} {
							puts $FTPBashHandle "ascii"
						}
						if {[string trim $FactoryArray($FactoryCounter,FTPRemotePath)] !=""} {
							puts $FTPBashHandle "cd $FactoryArray($FactoryCounter,FTPRemotePath)"
						}
						puts $FTPBashHandle "put $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
						puts $FTPBashHandle "quit"
						puts $FTPBashHandle "END_SCRIPT"
					}
					if {[string trim $FactoryArray($FactoryCounter,FTPProgram)] == "lftp"} {
						puts $FTPBashHandle "lftp -u $FactoryArray($FactoryCounter,FTPUserName),$FactoryArray($FactoryCounter,FTPPassword) $FactoryArray($FactoryCounter,FTPURL) <<EOF"
						if {[string trim $FactoryArray($FactoryCounter,FTPRemotePath)] !=""} {
							puts $FTPBashHandle "cd $FactoryArray($FactoryCounter,FTPRemotePath)"
						}
						puts $FTPBashHandle "if_error 'FTPing to Host Failed'"
						puts $FTPBashHandle "mput $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
						puts $FTPBashHandle "quit 0"
						puts $FTPBashHandle "EOF"
						puts $FTPBashHandle "rm -f $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
					}
					if {[string trim $FactoryArray($FactoryCounter,FTPProgram)] == "ncftp" && [string trim $FactoryArray($FactoryCounter,FTPURL)] != ""} {
						puts $FTPBashHandle "ncftp -u $FactoryArray($FactoryCounter,FTPUserName) -p $FactoryArray($FactoryCounter,FTPPassword) $FactoryArray($FactoryCounter,FTPURL) <<EOF"
						if {$FactoryArray($FactoryCounter,FTPTransferType) == "bin"} {
							puts $FTPBashHandle "binary"
						}
						if {$FactoryArray($FactoryCounter,FTPTransferType) == "asc"} {
							puts $FTPBashHandle "ascii"
						}
#						if {$FactoryArray($FactoryCounter,FTPTransferType) == "bin"} {
#							puts $FTPBashHandle "bin"
#						}
						if {[string trim $FactoryArray($FactoryCounter,FTPRemotePath)] !=""} {
							puts $FTPBashHandle "cd $FactoryArray($FactoryCounter,FTPRemotePath)"
						}
						puts $FTPBashHandle "rm $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
						puts $FTPBashHandle "put $FactoryArray($FactoryCounter,OutputDirectory)$SourceFileNameRoot"
# Manual for ncftp uses close instead of bye.
						puts $FTPBashHandle "bye"
						puts $FTPBashHandle "EOF"
					}
					puts "============ Closing FTP script $FTPScript"
					exec echo "============ Closing FTP script $FTPScript" >> $ConversionLogCMD
					exec echo "============ Closing FTP script $FTPScript" >> $FTPLogCMD
# Done writing close file handle
					close $FTPBashHandle
					puts "============ Setting permissions to execute on FTP script $FTPScript"
					exec echo "============ Setting permissions to execute on FTP script $FTPScript" >> $ConversionLogCMD
					exec echo "============ Setting permissions to execute on FTP script $FTPScript" >> $FTPLogCMD
# Set the permissions so it can be executed
					exec chmod 00777 $FTPScript
					puts "============ Executing FTP script $FTPScript"
					exec echo "============ Executing FTP script $FTPScript" >> $ConversionLogCMD
					exec echo "============ Executing FTP script $FTPScript" >> $FTPLogCMD
					exec echo "*****************************************************************************************" >> $FTPLogCMD
					exec echo "*****************************************************************************************" >> $FTPLogCMD
# Execute the FTP script
					exec $FTPScript 2>> $FTPLogCMD
				}
#
# End FTP Section
########################################################################################
########################################################################################
########################################################################################
#
# Start clean up section
#
				puts "============ Removing source file $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName"
				exec echo "============ Removing source file $FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName" >> $ConversionLogCMD
				exec echo "*****************************************************************************************" >> $ConversionLogCMD
				exec echo "*****************************************************************************************" >> $ConversionLogCMD

# Remove the source file when done.
				file delete -force "$FactoryArray($FactoryCounter,NotifyDirectory)$SourceFileName"
# Remove hidden, ".", dot files associated with the source file when done. Apple Computer written files.
				if {[file exists "$FactoryArray($FactoryCounter,NotifyDirectory).$SourceFileName"]} {
					puts "============ Dot files exist deleting $FactoryArray($FactoryCounter,NotifyDirectory).$SourceFileName"
					exec echo "============ Dot files exist deleting $FactoryArray($FactoryCounter,NotifyDirectory).$SourceFileName" >> $ConversionLogCMD
					file delete -force "$FactoryArray($FactoryCounter,NotifyDirectory).$SourceFileName"
				}

# If deletion is yes then delete log, ftp and FreeFactoryNotify.sh error logs if they exist.
				if {$FactoryArray($FactoryCounter,DeleteConversionLogs) == "Yes"} {
					puts "============ Remove Logs Is set to Yes"
# Remove the log file when done.
					if {[file exists "$FFMxLog"]} {
						puts "============ Removing $FFMxLog"
						file delete -force "$FFMxLog"
					}
					if {[file exists "$ConversionLogCMD"]} {
						puts "============ Removing $ConversionLogCMD"
						file delete -force "$ConversionLogCMD"
					}
# Remove the FTP file when done.
					if {[file exists "$FTPLog"]} {
						puts "============ Removing $FTPLog"
						file delete -force "$FTPLog"
					}

# Remove the FreeFactoryNotify.sh error file when done.
#					set FreeFactoryNotifyErrorLog "/opt/FreeFactory/Logs/FreeFactoryNotifyError-$SourceFileName.log"

########################################################################################
# This code inserts a escape character before any spaces in the ErrorLogCMD
# variable.  This variable is used in the echo commands to the log file.

#					set FreeFactoryNotifyErrorLogCMD $FreeFactoryNotifyErrorLog
#					set ParseString $FreeFactoryNotifyErrorLog
#					set BuildString ""
#					set SpacePos [string first " " $ParseString]
#					while {$SpacePos > -1} {
#						append BuildString [string range $ParseString 0 [expr $SpacePos -1]]
#						append BuildString "_"
#						set ParseString [string range $ParseString [expr $SpacePos +1] end]
#						set SpacePos [string first " " $ParseString]
#						if {$SpacePos < 0} {
#							append BuildString $ParseString
#							set FreeFactoryNotifyErrorLogCMD $BuildString
#							set FreeFactoryNotifyErrorLog $FreeFactoryNotifyErrorLogCMD
#						}
#					}

########################################################################################
########################################################################################
#					if {[file exists $FreeFactoryNotifyErrorLog]} {
#						puts "============ Removing $FreeFactoryNotifyErrorLog"
#						file delete -force $FreeFactoryNotifyErrorLog
#					}
#					if {[file exists "/opt/FreeFactory/Logs/FreeFactoryNotifyError.log"]} {
#						puts "============ Removing /opt/FreeFactory/Logs/FreeFactoryNotifyError.log"
#						file delete -force "/opt/FreeFactory/Logs/FreeFactoryNotifyError.log"
#					}
#				}


# Other Housekeeping
# If there was a FTP script created delete it.
				if {$FTPScript != ""} {
					if {[file exists $FTPScript]} {
						file delete -force $FTPScript
					}
				}
				puts "*****************************************************************************************"
				puts "*****************************************************************************************"
#
# End clean up section
#
########################################################################################
########################################################################################
########################################################################################
			}
#
# End notify directory match made
########################################################################################
		}
#
# End for loop to search array
########################################################################################
	}
#
# End execute only if source file exists
########################################################################################
}
#
# End proc
########################################################################################

# Run procedure main above and pass the variables received from FreeFastoryNotify.sh
main $argc $argv

exit
