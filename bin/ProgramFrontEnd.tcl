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
#
# Program:ProgramFrontEnd.tcl
#
# This is the front end gui for FreeFactory.  This runs everything else.
# It is for the main window with the menu bar at the top
#############################################################################
proc vTclWindow.programFrontEnd {base} {
##########################
# Free Factory variables
	global FreeFactoryDataDirectoryPath FreeFactoryDataFileName SaveFilePath DeleteConversionLogs


##########################
# System Control variables
	global PPref screenx screeny passconfig SystemTime FreeFactoryInstalledVERSION FreeFactoryInstallType WindowSizeX WindowSizeY FontSizeLabel FontSizeText
	global SelectAllText ConfirmFileSaves ConfirmFileDeletions SettingsCancelConfirm
	global ScaleWidth ProgressPercentComplete ProgressActionTitle ProgressDetailCount TotalRecords ProcessedRecords

##########################
# Video and Audio variables
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry ConversionProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID 
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

##########################
# File Dialog variables
	global FileSelectTypeList buttonImagePathFileDialog WindowName ToolTip fullDirPath returnFilePath returnFileName returnFullPath fileDialogOk

##########################
# Company Variables
	global TheCompanyName

##########################
# Apple Delay Variables
	global AppleDelay

##########################
# Program Front End Variables

	global ProgressBarProgressMain ScaleWidthMain ProgressPercentCompleteMain
	global ProgressDetailCountMain

##########################################################################################################################

	set StartPos [string trim [expr [string first "-size " $PPref(fonts,label)] + 6]]
	set EndPos   [expr [string trim [string first " " $PPref(fonts,label) [expr $StartPos +1]]] -1]
	set FontSizeLabel [string range $PPref(fonts,label) $StartPos $EndPos]

#	set StartPos [string trim [expr [string first "-size " $PPref(fonts,text)] + 6]]
#	set EndPos   [expr [string trim [string first " " $PPref(fonts,text) [expr $StartPos +1]]] -1]
#	set FontSizeText [string range $PPref(fonts,label) $StartPos $EndPos]

#  WindowSizeX WindowSizeY

#	set StartPos [string first "-size " $PPref(fonts,label)]
#	set EndPos   [string first " " $PPref(fonts,label) [exec $StartPos +8] ]
#	set FontSizeLabel [string index $PPref(fonts,label) $StartPos $EndPos ]

##########################################################################################################################
# This positions the window on the screen.  It uses the screen size information to determine
# placement.
	set xCord [expr int(($screenx-850)/2)]
	set yCord [expr int(($screeny-500)/2)]
##########################################################################################################################
##########################################################################################################################
    if {$base == ""} {set base .programFrontEnd}
    if {[winfo exists $base]} {wm deiconify $base; return}
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background #86888a -highlightbackground #e6e6e6 \
        -highlightcolor #000000 -menu "$top.m01"
    wm focusmodel $top passive
    wm geometry $top 850x500+$xCord+$yCord; update
    wm maxsize $top 850 500
    wm minsize $top 850 500
    wm overrideredirect $top 0
    wm resizable $top 0 0
    wm deiconify $top
    wm title $top "New Toplevel 1"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

#    bind $top <ButtonRelease-3> {tk_messageBox -message %W}

    bind $top <Escape> {exit}
    bind $top <Control-n> {ButtonNew invoke}
    bind $top <Control-N> {ButtonNew invoke}
    bind $top <Control-s> {ButtonSave invoke}
    bind $top <Control-S> {ButtonSave invoke}
    bind $top <Control-d> {ButtonDelete invoke}
    bind $top <Control-D> {ButtonDelete invoke}
    bind $top <Control-h> {ButtonHelp invoke}
    bind $top <Control-H> {ButtonHelp invoke}

	menu $top.m01 -borderwidth 1 -relief raised -cursor {}
	vTcl:DefineAlias "$top.m01" "MenuMasterProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1

	set site_3_0 $top.m01

	$site_3_0 add cascade -menu "$site_3_0.men01" -label File
	vTcl:DefineAlias "$site_3_0.men01" "Menu1ProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1

	menu $site_3_0.men01 -tearoff 0
	$site_3_0.men01 add command -command {
		InitVariables
		focus .programFrontEnd.middleFrame.factorySelection.childsite.selectedFactoryEntry.lwchildsite.entry
	} -label "New"

	$site_3_0.men01 add command -command {
		if {[if exists "/opt/FreeFactory/Factories/$SelectedFactory"]} {
			if {$PPref(ConfirmFileSaves) == "Yes"} {
				set GenericConfirm 2
				Window show .genericConfirm
				widgetUpdate
				set GenericConfirmName "Save $SelectedFactory factory file ?"
				wm title .genericConfirm "Save Factory Confirmation"
				tkwait window .genericConfirm
				if {$GenericConfirm == 1} {SaveFactoryFile}
			} else {
				SaveFactoryFile
			}
		} else {
			SaveFactoryFile
		}
	} -label "Save"

	$site_3_0.men01 add command -command {DeleteFactoryFile} -label "Delete"
	$site_3_0.men01 add command -command {exit} -label "Exit"

	$site_3_0 add cascade -menu "$site_3_0.men07" -label "Settings"
	vTcl:DefineAlias "$site_3_0.men07" "Menu7ProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1

	menu $site_3_0.men07 -tearoff 0
	$site_3_0.men07 add command -command {
		set SettingsCancelConfirm ""
		source "/opt/FreeFactory/bin/Settings.tcl"
		Window show .settings
		initEditSettings
		widgetUpdate
		tkwait window .settings
		if {$SettingsCancelConfirm!="Cancel"} {widgetUpdate}
	} -label "Edit Settings"

	$site_3_0.men07 add command -command {
		if {$PPref(ConfirmFileSaves) == "Yes"} {
			set GenericConfirm 2
			Window show .genericConfirm
			Window show .genericConfirm
			widgetUpdate
			set GenericConfirmName "Save Settings ?"
			wm title .genericConfirm "Save Settings Confirmation"
			tkwait window .genericConfirm
			if {$GenericConfirm == 1} {writeSettingsFile}
		} else {
			writeSettingsFile
		}
	} -label "Save Settings"

	$site_3_0 add cascade -menu "$site_3_0.men09" -label "Help"
	vTcl:DefineAlias "$site_3_0.men09" "Menu9ProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1

	menu $site_3_0.men09 -tearoff 0
	$site_3_0.men09 add command -command {exec $PPref(PDFReaderPath) "/opt/FreeFactory/Docs/Documentation.pdf" &} -label "Help"
	$site_3_0.men09 add command -command {
		source "/opt/FreeFactory/bin/License.tcl"
		Window show .showLicense
		Window show .showLicense
		source "/opt/FreeFactory/bin/LicenseText.tcl"
		widgetUpdate
		.showLicense.showLicenseText delete 0.0 end
		.showLicense.showLicenseText insert end $licenseText
		focus .showLicense.closeButton
	} -label "License"

	$site_3_0.men09 add command -command {
		source "/opt/FreeFactory/bin/About.tcl"
		Window show .showAbout
		Window show .showAbout
		initAbout
		focus .showAbout.closeButton
	} -label "About"

	frame $top.frameButtonTop -height 32 -highlightcolor black -relief raised -width 800  -border 1
	vTcl:DefineAlias "$top.frameButtonTop" "FrameTopMaster" vTcl:WidgetProc "Toplevel1" 1

	set site_3_0 $top.frameButtonTop


	frame $site_3_0.frameButtonGroup1 -height 30 -highlightcolor black -relief flat -width 430  -border 0
	vTcl:DefineAlias "$site_3_0.frameButtonGroup1" "FrameButtonGroup1" vTcl:WidgetProc "Toplevel1" 1

	set site_4_0 $site_3_0.frameButtonGroup1

	button $site_4_0.newButton -command {
		InitVariables
		focus .programFrontEnd.middleFrame.factorySelection.childsite.selectedFactoryEntry.lwchildsite.entry
	} -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics new32x32.gif]] -text ""
	vTcl:DefineAlias "$site_4_0.newButton" "ButtonNew" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.newButton -in $site_4_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_0.newButton "New Factory"

	button $site_4_0.saveButton -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics gtk-save32x32.gif]] \
	-command {
		if {[file exists "/opt/FreeFactory/Factories/$SelectedFactory"]} {
			if {$PPref(ConfirmFileSaves) == "Yes"} {
				set GenericConfirm 2
				Window show .genericConfirm
				widgetUpdate
				set GenericConfirmName "Save $SelectedFactory Factory ?"
				wm title .genericConfirm "Save Factory Confirmation"
				tkwait window .genericConfirm
				if {$GenericConfirm == 1} {SaveFactoryFile}
			} else {
				SaveFactoryFile
			}
		} else {
			SaveFactoryFile
		}
	} -text ""
	vTcl:DefineAlias "$site_4_0.saveButton" "ButtonSave" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.saveButton -in $site_4_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_0.saveButton "Save Factory"

	button $site_4_0.deleteButton -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics remove32x32.gif]] \
	-command {DeleteFactoryFile} -text ""
	vTcl:DefineAlias "$site_4_0.deleteButton" "ButtonDelete" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.deleteButton -in $site_4_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_0.deleteButton "Delete Factory"

	button $site_4_0.exitButton -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics exit32x32.gif]] \
	-command {
		exit
	} -text ""
	vTcl:DefineAlias "$site_4_0.exitButton" "ButtonExitProgram" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.exitButton -in $site_4_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_0.exitButton "Exit Program"

	pack $site_3_0.frameButtonGroup1 -in $site_3_0 -anchor nw -expand 1 -fill x -side left

	frame $site_3_0.frameButtonGroup5 -height 25 -highlightcolor black -relief flat -width 430  -border 0
	vTcl:DefineAlias "$site_3_0.frameButtonGroup5" "FrameButtonGroup5" vTcl:WidgetProc "Toplevel1" 1

	set site_4_4 $site_3_0.frameButtonGroup5

	button $site_4_4.editSettingsButton -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics ksysguard32x32.gif]] \
	-command {
		set SettingsCancelConfirm ""
		source "/opt/FreeFactory/bin/Settings.tcl"
		Window show .settings
		initEditSettings
		widgetUpdate
		tkwait window .settings
		if {$SettingsCancelConfirm!="Cancel"} {widgetUpdate}
	} -text ""
	vTcl:DefineAlias "$site_4_4.editSettingsButton" "ButtonEditSettings" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_4.editSettingsButton -in $site_4_4 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_4.editSettingsButton "Edit Settings"

	button $site_4_4.saveSettingsButton -borderwidth 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics gtk-save32x32.gif]] \
	-command {
		if {$PPref(ConfirmFileSaves) == "Yes"} {
			set GenericConfirm 2
			Window show .genericConfirm
			widgetUpdate
			set GenericConfirmName "Save Settings ?"
			wm title .genericConfirm "Save Settings Confirmation"
			tkwait window .genericConfirm
			if {$GenericConfirm == 1} {writeSettingsFile}
		} else {
			writeSettingsFile
		}
	} -text ""
	vTcl:DefineAlias "$site_4_4.saveSettingsButton" "ButtonSaveSettings" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_4.saveSettingsButton -in $site_4_4 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_4.saveSettingsButton "Save Settings"

	pack $site_3_0.frameButtonGroup5 -in $site_3_0 -anchor ne -expand 0 -fill x -side left

	frame $site_3_0.frameButtonGroup7 -height 25 -highlightcolor black -relief flat -width 430  -border 0
	vTcl:DefineAlias "$site_3_0.frameButtonGroup7" "FrameButtonGroup7" vTcl:WidgetProc "Toplevel1" 1

	set site_4_6 $site_3_0.frameButtonGroup7

	button $site_4_6.helpButton -borderwidth 0 -highlightthickness 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics help_index32x32.gif]] \
	-command {exec $PPref(PDFReaderPath) "/opt/FreeFactory/Docs/Documentation.pdf" &} -text ""
	vTcl:DefineAlias "$site_4_6.helpButton" "ButtonHelp" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_6.helpButton -in $site_4_6 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_6.helpButton "Help"

	button $site_4_6.licenseButton -borderwidth 0 -highlightthickness 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics License32x32.gif]] \
	-command {
		source "/opt/FreeFactory/bin/License.tcl"
		Window show .showLicense
		Window show .showLicense
		source "/opt/FreeFactory/bin/LicenseText.tcl"
		 widgetUpdate
		.showLicense.showLicenseText delete 0.0 end
		.showLicense.showLicenseText insert end $licenseText
		focus .showLicense.closeButton
	} -text ""
	vTcl:DefineAlias "$site_4_6.licenseButton" "ButtonLicense" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_6.licenseButton -in $site_4_6 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_6.licenseButton "License"

	button $site_4_6.aboutButton -borderwidth 0 -highlightthickness 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics document32x32.gif]] \
	-command {
		source "/opt/FreeFactory/bin/About.tcl"
		Window show .showAbout
		Window show .showAbout
		widgetUpdate
		initAbout
		focus .showAbout.closeButton
	} -text ""
	vTcl:DefineAlias "$site_4_6.aboutButton" "ButtonAbout" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_6.aboutButton -in $site_4_6 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_6.aboutButton "About"

	pack $site_3_0.frameButtonGroup7 -in $site_3_0 -anchor ne -expand 0 -fill x -side left
	pack $top.frameButtonTop -in $top -anchor nw -expand 0 -fill x -side top

# End Menus And Buttons
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################

	set site_1_0 $top

	frame $site_1_0.middleFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_1_0.middleFrame" "FrameMiddle" vTcl:WidgetProc "Toplevel1" 1

	set site_2_0 $site_1_0.middleFrame

	::iwidgets::labeledframe $site_2_0.factorySelection -labelpos nw -labeltext "Factory Selection"
	vTcl:DefineAlias "$site_2_0.factorySelection" "LabeledFrameFactorySelection" vTcl:WidgetProc "Toplevel1" 1

	set site_3_0 [$site_2_0.factorySelection childsite]

	frame $site_3_0.factorySelectionListBoxLedgendFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_3_0.factorySelectionListBoxLedgendFrame" "FrameListBoxLedgendFactorySelection" vTcl:WidgetProc "Toplevel1" 1

	set site_3_1 $site_3_0.factorySelectionListBoxLedgendFrame

	label $site_3_1.readOnlyFactorysLabel -text "Read Only" -background $PPref(color,window,back) -foreground #ff0000
	vTcl:DefineAlias "$site_3_1.readOnlyFactorysLabel" "LabelReadOnlyFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_1.readOnlyFactorysLabel -in $site_3_1 -anchor w -expand 0 -fill none -side left

	label $site_3_1.readWriteFactorysLabel -text "Read Write" -background $PPref(color,window,back) -foreground #0000ff
	vTcl:DefineAlias "$site_3_1.readWriteFactorysLabel" "LabelReadWriteFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_1.readWriteFactorysLabel -in $site_3_1 -anchor e -expand 0 -fill none -side right

	pack $site_3_0.factorySelectionListBoxLedgendFrame -in $site_3_0 -anchor n -expand 0 -fill x -side top

	set site_4_0 [$site_2_0.factorySelection childsite]

	::iwidgets::scrolledlistbox $site_4_0.factoryFilesDirectoryListBox -activebackground #f9f9f9 -activerelief raised -background #e6e6e6 \
	-borderwidth 2 -disabledforeground #a3a3a3 -foreground #000000 -height 100 -highlightcolor black -highlightthickness 1 \
	-hscrollmode dynamic -selectmode single -jump 0 -labelpos n -labeltext "" -relief sunken \
	-sbwidth 10 -selectbackground #c4c4c4 -selectborderwidth 1 -selectforeground black -state normal \
	-textbackground #d9d9d9 -troughcolor #c4c4c4 -vscrollmode dynamic -dblclickcommand {} -selectioncommand {
# Set the SelectedFactory variable to the factory in the list box.
		InitVariables
		set SelectedFactory [ScrolledListBoxFactoryFilesFactorySelection get [ScrolledListBoxFactoryFilesFactorySelection curselection ]]
		set FileHandle [open "/opt/FreeFactory/Factories/$SelectedFactory" r]
		while {![eof $FileHandle]} {
			gets $FileHandle FactoryVar
			set EqualDelimiter [string first "=" $FactoryVar]
			if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
				set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
				set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
				switch $FactoryField {
					"FACTORYDESCRIPTION" {set FactoryDescription $FactoryValue}
					"NOTIFYDIRECTORY" {set NotifyDirectoryEntry $FactoryValue}
					"OUTPUTDIRECTORY" {set OutputDirectoryEntry $FactoryValue}
					"OUTPUTFILESUFFIX" {set OutputFileSuffixEntry $FactoryValue}
					"CONVERSIONPROGRAM" {set ConversionProgram $FactoryValue}
					"FTPPROGRAM" {set FTPProgram $FactoryValue}
					"FTPURL" {set FTPURLEntry $FactoryValue}
					"FTPUSERNAME" {set FTPUserNameEntry $FactoryValue}
					"FTPPASSWORD" {set FTPPasswordEntry $FactoryValue}
					"FTPREMOTEPATH" {set FTPRemotePathEntry $FactoryValue}
					"FTPTRANSFERTYPE" {set FTPTransferType $FactoryValue}
					"VIDEOCODECS" {set VideoCodecs $FactoryValue}
					"VIDEOWRAPPER" {set VideoWrapper $FactoryValue}
					"VIDEOFRAMERATE" {set VideoFrameRate $FactoryValue}
					"VIDEOSIZE" {set VideoSize $FactoryValue}
					"VIDEOTARGET" {set VideoTarget $FactoryValue}
					"VIDEOTAGS" {set VideoTags $FactoryValue}
					"THREADS" {set Threads $FactoryValue}
					"ASPECT" {set Aspect $FactoryValue}
					"VIDEOBITRATE" {set VideoBitRate $FactoryValue}
					"VIDEOPRESET" {set VideoPreset $FactoryValue}
					"VIDEOSTREAMID" {set VideoStreamID $FactoryValue}
					"GROUPPICSIZE" {set GroupPicSizeEntry $FactoryValue}
					"BFRAMES" {set BFramesEntry $FactoryValue}
					"FRAMESTRATEGY" {set FrameStrategyEntry $FactoryValue}
					"FORCEFORMAT" {set ForceFormat $FactoryValue}
					"STARTTIMEOFFSET" {set StartTimeOffsetEntry $FactoryValue}
					"AUDIOCODECS" {set AudioCodecs $FactoryValue}
					"AUDIOBITRATE" {set AudioBitRate $FactoryValue}
					"AUDIOSAMPLERATE" {set AudioSampleRate $FactoryValue}
					"AUDIOFILEEXTENSION" {set AudioFileExtension $FactoryValue}
					"AUDIOTAG" {set AudioTag $FactoryValue}
					"AUDIOCHANNELS" {set AudioChannels $FactoryValue}
					"AUDIOSTREAMID" {set AudioStreamID $FactoryValue}
					"DELETECONVERSIONLOGS" {set DeleteConversionLogs $FactoryValue}
				}
			}
		}
		close $FileHandle
	} -width 254
	vTcl:DefineAlias "$site_4_0.factoryFilesDirectoryListBox" "ScrolledListBoxFactoryFilesFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.factoryFilesDirectoryListBox -in $site_4_0 -anchor n -expand 1 -fill both -side top

	::iwidgets::entryfield $site_4_0.selectedFactoryEntry -labelpos n -labeltext "Factory File Name" -textvariable SelectedFactory
	vTcl:DefineAlias "$site_4_0.selectedFactoryEntry" "SelectFactoryFileNameSelectionEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidgetEntry "$site_4_0.selectedFactoryEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntrySelectFactoryFileNameSelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.selectedFactoryEntry -in $site_4_0 -anchor w -expand 0 -fill x -side top
        bind $BindWidgetEntry <Key-Return> {focus .programFrontEnd.middleFrame.factoryDescriptionEntry.lwchildsite.entry}
        bind $BindWidgetEntry <Key-KP_Enter> {focus .programFrontEnd.middleFrame.factoryDescriptionEntry.lwchildsite.entry}

	frame $site_4_0.readOnlyFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_4_0.readOnlyFrame" "FrameReadOnlyFactorySelection" vTcl:WidgetProc "Toplevel1" 1

	set site_4_0_1 $site_4_0.readOnlyFrame

	button $site_4_0_1.readOnlyButton \
	-activebackground #f9f9f9 -activeforeground black \
	-command {
		set item "/opt/FreeFactory/Factories/$SelectedFactory"
		if {[file exists "/opt/FreeFactory/Factories/$SelectedFactory"]} {
# If read only set to read write - This function does not work.
# Once a factory is set to read only this code does not change 
# it back to read write.  Not sure why
			if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" \
				|| [file attributes $item -permissions]=="00444"} {
				exec chmod 00664 "/opt/FreeFactory/Factories/$SelectedFactory"
			}
# If read write set to read only
			if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
				|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
				|| [file attributes $item -permissions]=="00660"} {
				exec chmod 00444 "/opt/FreeFactory/Factories/$SelectedFactory"
			}
# Reload list box
			ScrolledListBoxFactoryFilesFactorySelection delete 0 end
			foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
				ScrolledListBoxFactoryFilesFactorySelection insert end [file tail $item]
				if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" \
					|| [file attributes $item -permissions]=="00444"} {
					ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #ff0000
				}
				if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
					|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
					|| [file attributes $item -permissions]=="00660"} {
					ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #0000ff
				}
			}
		}
	} -foreground black -highlightcolor black -text "Read Only"
	vTcl:DefineAlias "$site_4_0_1.readOnlyButton" "ButtonReadOnlyFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0_1.readOnlyButton -in $site_4_0_1 -anchor center -expand 1 -fill none -side left
	balloon $site_4_0_1.readOnlyButton "Set factory\nto read only."

	pack $site_4_0.readOnlyFrame -in $site_4_0 -anchor n -expand 0 -fill both -side top

	pack $site_2_0.factorySelection -in $site_2_0 -anchor w -expand 0 -fill y -side left

	set site_5_0 $site_1_0.middleFrame

	frame $site_5_0.rightFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_0.rightFrame" "FrameRight" vTcl:WidgetProc "Toplevel1" 1

	::iwidgets::entryfield $site_5_0.factoryDescriptionEntry -width 35 -labeltext "Factory Description"  -textvariable FactoryDescription -relief sunken -justify left
	vTcl:DefineAlias "$site_5_0.factoryDescriptionEntry" "FactoryDescriptionEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_0.factoryDescriptionEntry"
	set BindWidgetEntry "$site_5_0.factoryDescriptionEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFactoryDescriptionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.factoryDescriptionEntry -in $site_5_0 -anchor nw -expand 0 -fill x -side top
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFactoryDescriptionChild select range 0 end}
		EntryFactoryDescriptionChild icursor end
	}
	set site_5_1 $site_5_0.rightFrame
        bind $BindWidgetEntry <Key-Return> {focus .programFrontEnd.middleFrame.rightFrame.notifyDirectoryFrame.notifyDirectoryEntry.lwchildsite.entry}
        bind $BindWidgetEntry <Key-KP_Enter> {focus .programFrontEnd.middleFrame.rightFrame.notifyDirectoryFrame.notifyDirectoryEntry.lwchildsite.entry}

	frame $site_5_1.notifyDirectoryFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_1.notifyDirectoryFrame" "FrameNotifyDirectory" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1_0 $site_5_1.notifyDirectoryFrame

	::iwidgets::combobox $site_5_1_0.notifyDirectoryComboBoxFactorySelection -labeltext "Notify Directory" -labelpos w \
        -highlightthickness 0 -command {} -width 12 -listheight 100 -justify left -selectioncommand {
	} -textvariable NotifyDirectoryEntry -justify left
	vTcl:DefineAlias "$site_5_1_0.notifyDirectoryComboBoxFactorySelection" "ComboBoxNotifyDirectoryFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.notifyDirectoryComboBoxFactorySelection -in $site_5_1_0 -anchor w -expand 1 -fill x -side left

#	::iwidgets::entryfield $site_5_1_0.notifyDirectoryEntry -width 35 -labeltext "Notify Directory"  -textvariable NotifyDirectoryEntry -relief sunken -justify left
#	vTcl:DefineAlias "$site_5_1_0.notifyDirectoryEntry" "NotifyDirectoryEntry" vTcl:WidgetProc "Toplevel1" 1
#	set BindWidget "$site_5_1_0.notifyDirectoryEntry"
#	set BindWidgetEntry "$site_5_1_0.notifyDirectoryEntry.lwchildsite.entry"
#	vTcl:DefineAlias "$BindWidgetEntry" "EntryNotifyDirectoryChild" vTcl:WidgetProc "Toplevel1" 1
#	pack $site_5_1_0.notifyDirectoryEntry -in $site_5_1_0 -anchor nw -expand 1 -fill x -side left
#	bind $BindWidgetEntry <FocusIn> {
#		if {$PPref(SelectAllText) == "Yes"} {EntryNotifyDirectoryChild select range 0 end}
#		EntryNotifyDirectoryChild icursor end
#	}
#	bind $BindWidgetEntry <FocusOut> {
#		if {[string range $NotifyDirectoryEntry end end] != "/" && $NotifyDirectoryEntry !=""} {
#			append NotifyDirectoryEntry "/"
#		}
#	}
#        bind $BindWidgetEntry <Key-Return> {}
#        bind $BindWidgetEntry <Key-KP_Enter> {}

	button $site_5_1_0.getNotifyDirectoryButton \
	-activebackground #f9f9f9 -activeforeground black \
	-command {
		source "/opt/FreeFactory/bin/DirectoryDialog.tcl"
		set windowName "Browse Notify Path Directory"
		set toolTip "Select Directory"
		Window show .directoryDialog
		Window show .directoryDialog
		if {$NotifyDirectoryEntry !=""} {
			set fullDirPath [file dirname $NotifyDirectoryEntry]
		} else {
			set fullDirPath "/"
		}
		set buttonImagePathFileDialog [vTcl:image:get_image [file join / opt FreeFactory Pics open.gif]]
		widgetUpdate
		initDirectoryDialog
		tkwait window .directoryDialog
		if {$returnFilePath != ""} {
			set NotifyDirectoryEntry $returnFilePath
			if {[string range $NotifyDirectoryEntry end end] != "/" && $NotifyDirectoryEntry !=""} {
				append NotifyDirectoryEntry "/"
			}
		}	

	} -foreground black -highlightcolor black -image [vTcl:image:get_image [file join / opt FreeFactory Pics open.gif]] -text ""
	vTcl:DefineAlias "$site_5_1_0.getNotifyDirectoryButton" "ButtonGetNotifyDirectorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.getNotifyDirectoryButton -in $site_5_1_0 -anchor ne -expand 0 -fill none -side right
	balloon $site_5_1_0.getNotifyDirectoryButton "Browse"

	pack $site_5_1.notifyDirectoryFrame -in $site_5_1 -anchor w -expand 0 -fill x -side top

	set site_5_2 $site_5_0.rightFrame

	frame $site_5_2.outputDirectoryFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_2.outputDirectoryFrame" "FrameOutputDirectory" vTcl:WidgetProc "Toplevel1" 1

	set site_5_2_0 $site_5_2.outputDirectoryFrame

	::iwidgets::entryfield $site_5_2_0.outputDirectoryEntry -width 35 -labeltext "Output Directory"  -textvariable OutputDirectoryEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_5_2_0.outputDirectoryEntry" "OutputDirectoryEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_2_0.outputDirectoryEntry"
	set BindWidgetEntry "$site_5_2_0.outputDirectoryEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryOutputDirectoryChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.outputDirectoryEntry -in $site_5_2_0 -anchor nw -expand 1 -fill x -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryOutputDirectoryChild select range 0 end}
		EntryOutputDirectoryChild icursor end
	}
	bind $BindWidgetEntry <FocusOut> {
		if {[string range $OutputDirectoryEntry end end] != "/" && $OutputDirectoryEntry !=""} {
			append OutputDirectoryEntry "/"
		}
	}
        bind $BindWidgetEntry <Key-Return> {}
        bind $BindWidgetEntry <Key-KP_Enter> {}

	button $site_5_2_0.getOutputDirectoryButton \
	-activebackground #f9f9f9 -activeforeground black \
	-command {
		source "/opt/FreeFactory/bin/DirectoryDialog.tcl"
		set windowName "Browse Output Path Directory"
		set toolTip "Select Directory"
		Window show .directoryDialog
		Window show .directoryDialog
		if {$OutputDirectoryEntry !=""} {
			set fullDirPath [file dirname $OutputDirectoryEntry]
		} else {
			set fullDirPath "/"
		}
		set buttonImagePathFileDialog [vTcl:image:get_image [file join / opt FreeFactory Pics open.gif]]
		widgetUpdate
		initDirectoryDialog
		tkwait window .directoryDialog
		if {$returnFilePath != ""} {
			set OutputDirectoryEntry $returnFilePath
			if {[string range $OutputDirectoryEntry end end] != "/" && $OutputDirectoryEntry !=""} {
				append OutputDirectoryEntry "/"
			}
		}	
	} -foreground black -highlightcolor black -image [vTcl:image:get_image [file join / opt FreeFactory Pics open.gif]] -text ""
	vTcl:DefineAlias "$site_5_2_0.getOutputDirectoryButton" "ButtonGetOutputDirectory" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.getOutputDirectoryButton -in $site_5_2_0 -anchor ne -expand 0 -fill none -side right
	balloon $site_5_2_0.getOutputDirectoryButton "Browse"

	pack $site_5_2.outputDirectoryFrame -in $site_5_1 -anchor w -expand 0 -fill x -side top


	frame $site_5_1.outputFileSuffixFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_1.outputFileSuffixFrame" "FrameOutputFileSuffix" vTcl:WidgetProc "Toplevel1" 1

	set site_5_3_0 $site_5_1.outputFileSuffixFrame

	::iwidgets::entryfield $site_5_3_0.outputFileSuffixEntry -width 15 -labeltext "Output File Suffix"  -textvariable OutputFileSuffixEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_5_3_0.outputFileSuffixEntry" "OutputFileSuffixEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_3_0.outputFileSuffixEntry"
	set BindWidgetEntry "$site_5_3_0.outputFileSuffixEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryOutputFileSuffixChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.outputFileSuffixEntry -in $site_5_3_0 -anchor nw -expand 0 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryOutputFileSuffixChild select range 0 end}
		EntryOutputFileSuffixChild icursor end
	}

	::iwidgets::combobox $site_5_3_0.conversionProgramComboBoxFactorySelection -labeltext "Conversion Program" -labelpos w \
        -highlightthickness 0 -command {} -width 13 -listheight 50 -selectioncommand {
	} -textvariable ConversionProgram -justify left
	vTcl:DefineAlias "$site_5_3_0.conversionProgramComboBoxFactorySelection" "ComboBoxConversionProgramFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.conversionProgramComboBoxFactorySelection -in $site_5_3_0 -anchor w -expand 1 -fill none -side left

	pack $site_5_1.outputFileSuffixFrame -in $site_5_1 -anchor w -expand 0 -fill x -side top

	::iwidgets::labeledframe $site_5_1.ftpOptions -labelpos nw -labeltext "FTP Options"
	vTcl:DefineAlias "$site_5_1.ftpOptions" "LabeledFrameFTPOptions" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_0 [$site_5_1.ftpOptions childsite]


	frame $site_6_0_0.ftpProgramFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_0.ftpProgramFrame" "FrameFTPProgram" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_1 $site_6_0_0.ftpProgramFrame

	::iwidgets::entryfield $site_6_0_1.ftpURLEntry -width 12 -labeltext "URL"  -textvariable FTPURLEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpURLEntry" "FTPURLEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpURLEntry"
	set BindWidgetEntry "$site_6_0_1.ftpURLEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPURLChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpURLEntry -in $site_6_0_1 -anchor nw -expand 0 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPURLChild select range 0 end}
		EntryFTPURLChild icursor end
	}

	::iwidgets::entryfield $site_6_0_1.ftpUserNameEntry -width 12 -labeltext "User Name"  -textvariable FTPUserNameEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpUserNameEntry" "FTPUserNameEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpUserNameEntry"
	set BindWidgetEntry "$site_6_0_1.ftpUserNameEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPUserNameChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpUserNameEntry -in $site_6_0_1 -anchor nw -expand 0 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPUserNameChild select range 0 end}
		EntryFTPUserNameChild icursor end
	}

	::iwidgets::entryfield $site_6_0_1.ftpPasswordEntry -width 12 -labeltext "Password"  -textvariable FTPPasswordEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpPasswordEntry" "FTPPasswordEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpPasswordEntry"
	set BindWidgetEntry "$site_6_0_1.ftpPasswordEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPPasswordChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpPasswordEntry -in $site_6_0_1 -anchor nw -expand 0 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPPasswordChild select range 0 end}
		EntryFTPPasswordChild icursor end
	}

	::iwidgets::combobox $site_6_0_1.ftpProgramComboBoxFactorySelection -labeltext "FTP Program" -labelpos w \
        -highlightthickness 0 -command {} -width 13 -listheight 100 -selectioncommand {
	} -textvariable FTPProgram -justify  left
	vTcl:DefineAlias "$site_6_0_1.ftpProgramComboBoxFactorySelection" "ComboBoxFTPProgramFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpProgramComboBoxFactorySelection -in $site_6_0_1 -anchor w -expand 1 -fill none -side left

	pack $site_6_0_0.ftpProgramFrame -in $site_6_0_0 -anchor w -expand 0 -fill x -side top

	frame $site_6_0_0.ftpRemotePathFrame -height 2 -highlightcolor black -relief flat -width 12  -border 2
	vTcl:DefineAlias "$site_6_0_0.ftpRemotePathFrame" "FrameFTPRemotePath" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_1 $site_6_0_0.ftpRemotePathFrame

	::iwidgets::entryfield $site_6_0_1.ftpRemotePathEntry -width 30 -labeltext "FTP Remote Path"  -textvariable FTPRemotePathEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpRemotePathEntry" "FTPRemotePathEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpRemotePathEntry"
	set BindWidgetEntry "$site_6_0_1.ftpRemotePathEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPRemotePathChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpRemotePathEntry -in $site_6_0_1 -anchor nw -expand 1 -fill x -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPRemotePathChild select range 0 end}
		EntryFTPRemotePathChild icursor end
	}

	label $site_6_0_1.ftpTransferTypeLabel -text "Transfer Type:" -background #ececec
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypeLabel" "LabelFTPTransferType" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypeLabel -in $site_6_0_1 -anchor w -expand 0 -padx 2 -fill none -side left

	radiobutton $site_6_0_1.ftpTransferTypeascRadioButton \
	-command {} -text ASC -value "asc" -variable FTPTransferType
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypeascRadioButton" "RadioButtonFTPTransferTypeASC" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypeascRadioButton -in $site_6_0_1 -anchor nw -expand 0 -fill none -side left

	radiobutton $site_6_0_1.ftpTransferTypebinRadioButton \
	-command {} -text BIN -value "bin" -variable FTPTransferType
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypebinRadioButton" "RadioButtonFTPTransferTypeBIN" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypebinRadioButton -in $site_6_0_1 -anchor nw -expand 0 -fill none -side left

	pack $site_6_0_0.ftpRemotePathFrame -in $site_6_0_0 -anchor nw -expand 0 -fill none -side top

	pack $site_5_1.ftpOptions -in $site_5_1 -anchor w -expand 1 -fill x -side top

	::iwidgets::labeledframe $site_5_1.videoOptions -labelpos nw -labeltext "Video Options"
	vTcl:DefineAlias "$site_5_1.videoOptions" "LabeledFrameVideoOptions" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0 [$site_5_1.videoOptions childsite]

	set site_6_0_1  $site_6_0

	frame $site_6_0_1.vCodecsWrapperFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_1.vCodecsWrapperFrame" "FrameVideoCodecsWrapper" vTcl:WidgetProc "Toplevel1" 1
	
	set site_6_0_2  $site_6_0_1.vCodecsWrapperFrame

	::iwidgets::combobox $site_6_0_2.videoCodecsComboBoxFactorySelection -labeltext "Codecs" -labelpos w \
        -highlightthickness 0 -command {} -width 13 -listheight 100 -selectioncommand {
	} -textvariable VideoCodecs -justify left
	vTcl:DefineAlias "$site_6_0_2.videoCodecsComboBoxFactorySelection" "ComboBoxVideoCodecsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.videoCodecsComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_2.videoWrapperComboBoxFactorySelection -labeltext "Wrapper" -labelpos w \
        -highlightthickness 0 -command {} -width 7 -listheight 100 -selectioncommand {
	} -textvariable VideoWrapper -justify left
	vTcl:DefineAlias "$site_6_0_2.videoWrapperComboBoxFactorySelection" "ComboBoxVideoWrapperFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.videoWrapperComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_2.frameRateComboBoxFactorySelection -labeltext "Frame Rate" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable VideoFrameRate -justify left
	vTcl:DefineAlias "$site_6_0_2.frameRateComboBoxFactorySelection" "ComboBoxFrameRateFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.frameRateComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	pack $site_6_0_1.vCodecsWrapperFrame -in $site_6_0_1 -anchor w -expand 0 -fill x -side top

	set site_6_0_1  $site_6_0

	frame $site_6_0_1.rateSizeFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_1.rateSizeFrame" "FrameRateSize" vTcl:WidgetProc "Toplevel1" 1
	
	set site_6_0_2  $site_6_0_1.rateSizeFrame

	::iwidgets::combobox $site_6_0_2.sizeComboBoxFactorySelection -labeltext "Size" -labelpos w \
        -highlightthickness 0 -command {} -width 13 -listheight 100 -selectioncommand {
	} -textvariable VideoSize -justify right
	vTcl:DefineAlias "$site_6_0_2.sizeComboBoxFactorySelection" "ComboBoxSizeFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.sizeComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_2.videoBitRateComboBoxFactorySelection -labeltext "Bit Rate" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable VideoBitRate -justify right
	vTcl:DefineAlias "$site_6_0_2.videoBitRateComboBoxFactorySelection" "ComboBoxVideoBitRateFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.videoBitRateComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_2.aspectComboBoxFactorySelection -labeltext "Aspect" -labelpos w \
        -highlightthickness 0 -command {} -width 7 -listheight 100 -selectioncommand {
	} -textvariable Aspect -justify right
	vTcl:DefineAlias "$site_6_0_2.aspectComboBoxFactorySelection" "ComboBoxAspectFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_2.aspectComboBoxFactorySelection -in $site_6_0_2 -anchor w -expand 1 -fill none -side left

	pack $site_6_0_1.rateSizeFrame -in $site_6_0_1 -anchor w -expand 0 -fill x -side top

	frame $site_6_0_1.targetTagsThreadsFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_1.targetTagsThreadsFrame" "FrameTargetTagsThreads" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_3  $site_6_0_1.targetTagsThreadsFrame

	::iwidgets::combobox $site_6_0_3.targetComboBoxFactorySelection -labeltext "Target" -labelpos w \
        -highlightthickness 0 -command {} -width 12 -listheight 100 -selectioncommand {
	} -textvariable VideoTarget -justify  left
	vTcl:DefineAlias "$site_6_0_3.targetComboBoxFactorySelection" "ComboBoxTargetFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.targetComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_3.tagsComboBoxFactorySelection -labeltext "Tags" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable VideoTags -justify  left
	vTcl:DefineAlias "$site_6_0_3.tagsComboBoxFactorySelection" "ComboBoxTagsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.tagsComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_3.threadsComboBoxFactorySelection -labeltext "Threads" -labelpos w \
        -highlightthickness 0 -command {} -width 5 -listheight 100 -selectioncommand {
	} -textvariable Threads -justify right
	vTcl:DefineAlias "$site_6_0_3.threadsComboBoxFactorySelection" "ComboBoxThreadsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.threadsComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	pack $site_6_0_1.targetTagsThreadsFrame -in $site_6_0_1 -anchor w -expand 0 -fill x -side top

	frame $site_6_0_1.streamIDBFramesFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_1.streamIDBFramesFrame" "FrameStreamIDBFrames" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_3  $site_6_0_1.streamIDBFramesFrame

	::iwidgets::entryfield $site_6_0_3.vStreamIDsEntry -width 7 -labelpos w -labeltext "Stream ID" -textvariable VideoStreamID
	vTcl:DefineAlias "$site_6_0_3.vStreamIDsEntry" "EntryVideoStreamIDFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_3.vStreamIDsEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryVideoStreamIDFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.vStreamIDsEntry -in $site_6_0_3 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryVideoStreamIDFactorySelectionChild select range 0 end}
		EntryVideoStreamIDFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	::iwidgets::entryfield $site_6_0_3.bFramesEntry -width 7 -labelpos w -labeltext "B Frames" -textvariable BFramesEntry
	vTcl:DefineAlias "$site_6_0_3.bFramesEntry" "EntryBFramesFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_3.bFramesEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryBFramesFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.bFramesEntry -in $site_6_0_3 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryBFramesFactorySelectionChild select range 0 end}
		EntryBFramesFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	::iwidgets::entryfield $site_6_0_3.frameStrategyEntry -width 7 -labelpos w -labeltext "Frame Strategy" -textvariable FrameStrategyEntry
	vTcl:DefineAlias "$site_6_0_3.frameStrategyEntry" "EntryFrameESrategyFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_3.frameStrategyEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryFrameESrategyFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.frameStrategyEntry -in $site_6_0_3 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFrameESrategyFactorySelectionChild select range 0 end}
		EntryFrameESrategyFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	pack $site_6_0_1.streamIDBFramesFrame -in $site_6_0_1 -anchor w -expand 0 -fill x -side top

	frame $site_6_0_1.groupPicSizeFramesFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_1.groupPicSizeFramesFrame" "FrameGroupPicSize" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_3  $site_6_0_1.groupPicSizeFramesFrame

	::iwidgets::entryfield $site_6_0_3.groupPicSizeEntry -width 7 -labelpos w -labeltext "Group Pic Size" -textvariable GroupPicSizeEntry
	vTcl:DefineAlias "$site_6_0_3.groupPicSizeEntry" "EntryGroupPicSizeFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_3.groupPicSizeEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryGroupPicSizeFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.groupPicSizeEntry -in $site_6_0_3 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryGroupPicSizeFactorySelectionChild select range 0 end}
		EntryGroupPicSizeFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	::iwidgets::entryfield $site_6_0_3.startTimeOffsetEntry -width 7 -labelpos w -labeltext "Start Time Offset" -textvariable StartTimeOffsetEntry
	vTcl:DefineAlias "$site_6_0_3.startTimeOffsetEntry" "EntryStartTimeOffsetFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_3.startTimeOffsetEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryStartTimeOffsetFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.startTimeOffsetEntry -in $site_6_0_3 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryStartTimeOffsetFactorySelectionChild select range 0 end}
		EntryStartTimeOffsetFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	::iwidgets::combobox $site_6_0_3.forceFormatComboBoxFactorySelection -labeltext "Force Format" -labelpos w \
        -highlightthickness 0 -command {} -width 7 -listheight 100 -selectioncommand {
	} -textvariable ForceFormat -justify  left
	vTcl:DefineAlias "$site_6_0_3.forceFormatComboBoxFactorySelection" "ComboBoxForceFormatFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.forceFormatComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	pack $site_6_0_1.groupPicSizeFramesFrame -in $site_6_0_1 -anchor w -expand 0 -fill x -side top

	::iwidgets::combobox $site_6_0.vPresetComboBoxFactorySelection -labeltext "Video Pre" -labelpos w \
        -highlightthickness 0 -command {} -width 3 -listheight 100 -selectioncommand {
	} -textvariable VideoPreset -justify  left
	vTcl:DefineAlias "$site_6_0.vPresetComboBoxFactorySelection" "ComboBoxVideoPresetFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0.vPresetComboBoxFactorySelection -in $site_6_0 -anchor w -expand 0 -fill x -side top

	pack $site_5_1.videoOptions -in $site_5_1 -anchor w -expand 1 -fill x -side top

	set site_5_2 $site_5_0.rightFrame

	::iwidgets::labeledframe $site_5_2.audioOptions -labelpos nw -labeltext "Audio Options"
	vTcl:DefineAlias "$site_5_2.audioOptions" "LabeledFrameAudioOptions" vTcl:WidgetProc "Toplevel1" 1

	set site_6_1 [$site_5_2.audioOptions childsite]


	frame $site_6_1.audioCodecsBitRateSampleRateFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_1.audioCodecsBitRateSampleRateFrame" "FrameAudioCodecsBitRateSampleRate" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_3  $site_6_1.audioCodecsBitRateSampleRateFrame

	::iwidgets::combobox $site_6_0_3.audioCodecsComboBoxFactorySelection -labeltext "Codecs" -labelpos w \
        -highlightthickness 0 -command {} -width 13 -listheight 100 -selectioncommand {
	} -textvariable AudioCodecs -justify left
	vTcl:DefineAlias "$site_6_0_3.audioCodecsComboBoxFactorySelection" "ComboBoxAudioCodecsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioCodecsComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_3.audioBitRateComboBoxFactorySelection -labeltext "Bit Rate" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable AudioBitRate -justify right
	vTcl:DefineAlias "$site_6_0_3.audioBitRateComboBoxFactorySelection" "ComboBoxAudioBitRateFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioBitRateComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_3.audioSampleRateComboBoxFactorySelection -labeltext "Sample Rate" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable AudioSampleRate -justify right
	vTcl:DefineAlias "$site_6_0_3.audioSampleRateComboBoxFactorySelection" "ComboBoxAudioSampleRateFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioSampleRateComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	pack $site_6_1.audioCodecsBitRateSampleRateFrame -in $site_6_1 -anchor w -expand 0 -fill x -side top


	frame $site_6_1.audioFileExtensionTagChannelsFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_1.audioFileExtensionTagChannelsFrame" "FrameAudioFileExtensionTagChannels" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_3  $site_6_1.audioFileExtensionTagChannelsFrame

	::iwidgets::combobox $site_6_0_3.audioFileExtensionComboBoxFactorySelection -labeltext "File Extension" -labelpos w \
        -highlightthickness 0 -command {} -width 7 -listheight 100 -selectioncommand {
	} -textvariable AudioFileExtension -justify  left
	vTcl:DefineAlias "$site_6_0_3.audioFileExtensionComboBoxFactorySelection" "ComboBoxAudioFileExtensionFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioFileExtensionComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	::iwidgets::combobox $site_6_0_3.audioTagComboBoxFactorySelection -labeltext "Tags" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable AudioTag -justify  left
	vTcl:DefineAlias "$site_6_0_3.audioTagComboBoxFactorySelection" "ComboBoxAudioTagFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioTagComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left


	::iwidgets::combobox $site_6_0_3.audioChannelsComboBoxFactorySelection -labeltext "Channels" -labelpos w \
        -highlightthickness 0 -command {} -width 5 -listheight 100 -selectioncommand {
	} -textvariable AudioChannels -justify right
	vTcl:DefineAlias "$site_6_0_3.audioChannelsComboBoxFactorySelection" "ComboBoxAudioChannelsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_3.audioChannelsComboBoxFactorySelection -in $site_6_0_3 -anchor w -expand 1 -fill none -side left

	pack $site_6_1.audioFileExtensionTagChannelsFrame -in $site_6_1 -anchor w -expand 0 -fill x -side top

	::iwidgets::entryfield $site_6_1.audioStreamIDEntry -width 7 -labelpos w -labeltext "Stream ID" -textvariable AudioStreamID
	vTcl:DefineAlias "$site_6_1.audioStreamIDEntry" "EntryAudioStreamIDFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_1.audioStreamIDEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryAudioStreamIDFactorySelectionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_1.audioStreamIDEntry -in $site_6_1 -anchor w -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryAudioStreamIDFactorySelectionChild select range 0 end}
		EntryAudioStreamIDFactorySelectionChild icursor end
	}
        bind $BindWidget <Key-Return> {}
        bind $BindWidget <Key-KP_Enter> {}

	pack $site_5_2.audioOptions -in $site_5_2 -anchor w -expand 1 -fill x -side top

	frame $site_5_2.deleteLogFrame -height 2 -highlightcolor black -relief flat -width 12  -border 2
	vTcl:DefineAlias "$site_5_2.deleteLogFrame" "FrameDeleteLog" vTcl:WidgetProc "Toplevel1" 1

	set site_5_3 $site_5_2.deleteLogFrame

	label $site_5_3.deleteLogLabel -text "Delete Logs" -background #ececec
	vTcl:DefineAlias "$site_5_3.deleteLogLabel" "LabelDeleteLog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3.deleteLogLabel -in $site_5_3 -anchor w -expand 0 -padx 2 -fill none -side left

	radiobutton $site_5_3.deleteConversionLogsYesRadioButton \
	-command {} -text Yes -value "Yes" -variable DeleteConversionLogs
	vTcl:DefineAlias "$site_5_3.deleteConversionLogsYesRadioButton" "RadioButtonDeleteConversionLogsYes" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3.deleteConversionLogsYesRadioButton -in $site_5_3 -anchor nw -expand 0 -fill none -side left

	radiobutton $site_5_3.deleteConversionLogsNoRadioButton \
	-command {} -text No -value "No" -variable DeleteConversionLogs
	vTcl:DefineAlias "$site_5_3.deleteConversionLogsNoRadioButton" "RadioButtonDeleteConversionLogsNo" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3.deleteConversionLogsNoRadioButton -in $site_5_3 -anchor nw -expand 0 -fill none -side left

	pack $site_5_2.deleteLogFrame -in $site_5_2 -anchor nw -expand 0 -fill none -side top

	pack $site_5_0.rightFrame -in $site_1_0.middleFrame -anchor nw -expand 1 -fill both -side right
	pack $site_1_0.middleFrame -in $site_1_0 -anchor nw -expand 1 -fill both -side top


#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################

	frame $top.frameBottom1 -height 2 -highlightcolor black -relief flat -width 12  -border 2
	vTcl:DefineAlias "$top.frameBottom1" "FrameFooterMaster" vTcl:WidgetProc "Toplevel1" 1
	set site_5_0 $top.frameBottom1

	frame $site_5_0.frameTime -height 2 -highlightcolor black -relief flat -width 10  -border 0
	vTcl:DefineAlias "$site_5_0.frameTime" "FrameFooterTime" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1 $site_5_0.frameTime

	entry $site_5_1.systemTimeEntry -borderwidth 1 -foreground #000000 -highlightcolor black \
	-highlightthickness 0 -insertbackground black -selectbackground #c4c4c4 -selectborderwidth 0 -relief sunken \
	-selectforeground black -textvariable SystemTime -width 40 -justify center
	vTcl:DefineAlias "$site_5_1.systemTimeEntry" "EntrySystemTimeProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.systemTimeEntry -in $site_5_1 -anchor nw -expand 1 -fill both -side top

	pack $site_5_0.frameTime -in $top.frameBottom1 -anchor e -expand 1 -fill none -side right

	frame $site_5_0.frameInfo -height 2 -highlightcolor black -relief flat -width 300  -border 0
	vTcl:DefineAlias "$site_5_0.frameTime" "FrameFooterInfo" vTcl:WidgetProc "Toplevel1" 1

	set site_5_2 $site_5_0.frameInfo

	entry $site_5_2.solutionStatusEntry -borderwidth 0 -foreground #000000 -highlightcolor black \
	-highlightthickness 0 -insertbackground black -selectbackground #c4c4c4 -selectborderwidth 0 -relief flat \
	-selectforeground black -textvariable SolutionStatus -width 40 -justify left
	vTcl:DefineAlias "$site_5_2.solutionStatusEntry" "EntrySolutionStatusProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2.solutionStatusEntry -in $site_5_0.frameInfo -anchor center -expand 0 -fill none -side left

	scale $site_5_2.progressBarMain -activebackground #ececec -background #d9d9d9 -bigincrement 0.0 \
	-borderwidth 0 -command {} -foreground Black -from 0.0 -highlightbackground #d9d9d9 -highlightcolor Black -showvalue 0 \
	-highlightthickness 0 -label {} -orient horizontal -relief flat -repeatdelay 300 -repeatinterval 100 -resolution 1.0 -sliderlength 1.0 \
	-sliderrelief flat -tickinterval 0.0 -to 100.0 -troughcolor #c3c3c3 -variable ProgressBarProgressMain -width 15
	vTcl:DefineAlias "$site_5_2.progressBarMain" "ScaleProgressBarProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2.progressBarMain -in $site_5_0.frameInfo -anchor nw -expand 0 -fill none -side left

	entry $site_5_2.progressPercentCompleteMainEntry -borderwidth 0 -foreground #000000 -highlightcolor black \
	-highlightthickness 0 -insertbackground black -selectbackground #c4c4c4 -selectborderwidth 0 -relief flat \
	-selectforeground black -textvariable ProgressPercentCompleteMain -width 7 -justify right
	vTcl:DefineAlias "$site_5_2.progressPercentCompleteMainEntry" "EntryProgressPercentCompleteProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2.progressPercentCompleteMainEntry -in $site_5_0.frameInfo -anchor nw -expand 0 -fill none -side left

	pack $site_5_0.frameInfo -in $top.frameBottom1 -anchor ne -expand 0 -fill x -side left
	pack $top.frameBottom1 -in $top -anchor sw -expand 0 -fill x -side bottom

	vTcl:FireEvent $base <<Ready>>
	InitFreeFactory
}

################################################################################
################################################################################
################################################################################
# Start InitFreeFactory
proc InitFreeFactory {} {
##########################
# Free Factory variables
	global FreeFactoryDataDirectoryPath FreeFactoryDataFileName SaveFilePath DeleteConversionLogs

##########################
# Video and Audio variables
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry ConversionProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID 
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

	InitVariables

	ScrolledListBoxFactoryFilesFactorySelection delete 0 end
	foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
		ScrolledListBoxFactoryFilesFactorySelection insert end [file tail $item]
		if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" \
			|| [file attributes $item -permissions]=="00444"} {
			ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #ff0000
		}
		if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
			|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
			|| [file attributes $item -permissions]=="00660"} {
			ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #0000ff
		}
	}

	ComboBoxNotifyDirectoryFactorySelection clear
	ComboBoxNotifyDirectoryFactorySelection insert list end ""
	if {![file exists "/opt/FreeFactory/FreeFactoryNotifyDirectoryList"] || [file size "/opt/FreeFactory/FreeFactoryNotifyDirectoryList"] == 0} {
		set FileHandle [open "/opt/FreeFactory/FreeFactoryNotifyDirectoryList" w]
		puts $FileHandle "/opt/FreeFactory/NotifyVideo/"
		puts $FileHandle "/opt/FreeFactory/NotifyVideo2/"
		close $FileHandle
	}
	set FileHandle [open "/opt/FreeFactory/FreeFactoryNotifyDirectoryList" r]
	while {![eof $FileHandle]} {
		gets $FileHandle NotifyDirectory
		ComboBoxNotifyDirectoryFactorySelection insert list end $NotifyDirectory
	}
	close $FileHandle

	ComboBoxConversionProgramFactorySelection clear
	ComboBoxConversionProgramFactorySelection insert list end ""
	ComboBoxConversionProgramFactorySelection insert list end "ffmbc"
	ComboBoxConversionProgramFactorySelection insert list end "ffmpeg"
#	ComboBoxConversionProgramFactorySelection insert list end "libav"

	ComboBoxFTPProgramFactorySelection clear
	ComboBoxFTPProgramFactorySelection insert list end ""
	ComboBoxFTPProgramFactorySelection insert list end "ftp"
	ComboBoxFTPProgramFactorySelection insert list end "lftp"
	ComboBoxFTPProgramFactorySelection insert list end "ncftp"

	ComboBoxVideoCodecsFactorySelection clear
	ComboBoxVideoCodecsFactorySelection insert list end ""
	ComboBoxVideoCodecsFactorySelection insert list end "DNxHD"
	ComboBoxVideoCodecsFactorySelection insert list end "dvcpro-hd"
	ComboBoxVideoCodecsFactorySelection insert list end "h264"
	ComboBoxVideoCodecsFactorySelection insert list end "libx264"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg1"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg2"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg2video"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg4"
	ComboBoxVideoCodecsFactorySelection insert list end "mxf"
	ComboBoxVideoCodecsFactorySelection insert list end "xdcam"
	ComboBoxVideoCodecsFactorySelection insert list end "xvid"

	ComboBoxVideoWrapperFactorySelection clear
	ComboBoxVideoWrapperFactorySelection insert list end ""
	ComboBoxVideoWrapperFactorySelection insert list end ".avi"
	ComboBoxVideoWrapperFactorySelection insert list end ".es"
	ComboBoxVideoWrapperFactorySelection insert list end ".flv"
	ComboBoxVideoWrapperFactorySelection insert list end ".m2v"
	ComboBoxVideoWrapperFactorySelection insert list end ".m4v"
	ComboBoxVideoWrapperFactorySelection insert list end ".mkv"
	ComboBoxVideoWrapperFactorySelection insert list end ".mov"
	ComboBoxVideoWrapperFactorySelection insert list end ".mp4"
	ComboBoxVideoWrapperFactorySelection insert list end ".mpg"
	ComboBoxVideoWrapperFactorySelection insert list end ".ogm"
	ComboBoxVideoWrapperFactorySelection insert list end ".ps"
	ComboBoxVideoWrapperFactorySelection insert list end ".ts"
	ComboBoxVideoWrapperFactorySelection insert list end ".vob"

	ComboBoxFrameRateFactorySelection clear
	ComboBoxFrameRateFactorySelection insert list end ""
	ComboBoxFrameRateFactorySelection insert list end "15.000"
	ComboBoxFrameRateFactorySelection insert list end "23.976"
	ComboBoxFrameRateFactorySelection insert list end "24.000"
	ComboBoxFrameRateFactorySelection insert list end "25.000"
	ComboBoxFrameRateFactorySelection insert list end "29.970"
	ComboBoxFrameRateFactorySelection insert list end "30.000"

	ComboBoxSizeFactorySelection clear
	ComboBoxSizeFactorySelection insert list end ""
	ComboBoxSizeFactorySelection insert list end "128x96"
	ComboBoxSizeFactorySelection insert list end "160x120"
	ComboBoxSizeFactorySelection insert list end "176x144"
	ComboBoxSizeFactorySelection insert list end "320x200"
	ComboBoxSizeFactorySelection insert list end "320x240"
	ComboBoxSizeFactorySelection insert list end "352x288"
	ComboBoxSizeFactorySelection insert list end "480x270"
	ComboBoxSizeFactorySelection insert list end "640x350"
	ComboBoxSizeFactorySelection insert list end "640x480"
	ComboBoxSizeFactorySelection insert list end "704x576"
	ComboBoxSizeFactorySelection insert list end "720x480"
	ComboBoxSizeFactorySelection insert list end "800x600"
	ComboBoxSizeFactorySelection insert list end "852x480"
	ComboBoxSizeFactorySelection insert list end "1024x768"
	ComboBoxSizeFactorySelection insert list end "1280x720"
	ComboBoxSizeFactorySelection insert list end "1280x1024"
	ComboBoxSizeFactorySelection insert list end "1366x768"
	ComboBoxSizeFactorySelection insert list end "1600x1024"
	ComboBoxSizeFactorySelection insert list end "1600x1200"
	ComboBoxSizeFactorySelection insert list end "1920x1080"
	ComboBoxSizeFactorySelection insert list end "1920x1200"
	ComboBoxSizeFactorySelection insert list end "2048x1536"
	ComboBoxSizeFactorySelection insert list end "2560x1600"
	ComboBoxSizeFactorySelection insert list end "2560x2048"
	ComboBoxSizeFactorySelection insert list end "3200x2048"
	ComboBoxSizeFactorySelection insert list end "3840x2400"
	ComboBoxSizeFactorySelection insert list end "5120x4096"
	ComboBoxSizeFactorySelection insert list end "6400x4096"
	ComboBoxSizeFactorySelection insert list end "7680x4800"

	ComboBoxTargetFactorySelection clear
	ComboBoxTargetFactorySelection insert list end ""
	ComboBoxTargetFactorySelection insert list end "dvcprohd"
	ComboBoxTargetFactorySelection insert list end "xdcamhd422"

	ComboBoxTagsFactorySelection clear
	ComboBoxTagsFactorySelection insert list end ""
	ComboBoxTagsFactorySelection insert list end "dvc"
	ComboBoxTagsFactorySelection insert list end "mp4v"
	ComboBoxTagsFactorySelection insert list end "xd5b"

	ComboBoxThreadsFactorySelection clear
	ComboBoxThreadsFactorySelection insert list end ""
	ComboBoxThreadsFactorySelection insert list end "8"

	ComboBoxAspectFactorySelection clear
	ComboBoxAspectFactorySelection insert list end ""
	ComboBoxAspectFactorySelection insert list end "4:3+"
	ComboBoxAspectFactorySelection insert list end "5:4+"
	ComboBoxAspectFactorySelection insert list end "16:9+"
	ComboBoxAspectFactorySelection insert list end "1.85:1+"

	ComboBoxVideoBitRateFactorySelection clear
	ComboBoxVideoBitRateFactorySelection insert list end ""
	ComboBoxVideoBitRateFactorySelection insert list end "700k"
	ComboBoxVideoBitRateFactorySelection insert list end "1M"
	ComboBoxVideoBitRateFactorySelection insert list end "1.5M"
	ComboBoxVideoBitRateFactorySelection insert list end "4M"
	ComboBoxVideoBitRateFactorySelection insert list end "5M"
	ComboBoxVideoBitRateFactorySelection insert list end "17M"
	ComboBoxVideoBitRateFactorySelection insert list end "24M"
	ComboBoxVideoBitRateFactorySelection insert list end "25M"
	ComboBoxVideoBitRateFactorySelection insert list end "35M"
	ComboBoxVideoBitRateFactorySelection insert list end "45M"
	ComboBoxVideoBitRateFactorySelection insert list end "60M"

	ComboBoxVideoPresetFactorySelection clear
	ComboBoxVideoPresetFactorySelection insert list end ""
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slowfirstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-medium"

	ComboBoxForceFormatFactorySelection clear
	ComboBoxForceFormatFactorySelection insert list end ""
	ComboBoxForceFormatFactorySelection insert list end "vob"

	ComboBoxAudioCodecsFactorySelection clear
	ComboBoxAudioCodecsFactorySelection insert list end ""
	ComboBoxAudioCodecsFactorySelection insert list end "ac3"
	ComboBoxAudioCodecsFactorySelection insert list end "ac3_fixed"
	ComboBoxAudioCodecsFactorySelection insert list end "acc"
	ComboBoxAudioCodecsFactorySelection insert list end "copy"
	ComboBoxAudioCodecsFactorySelection insert list end "libfaac"
	ComboBoxAudioCodecsFactorySelection insert list end "mp2"
	ComboBoxAudioCodecsFactorySelection insert list end "mp3"
	ComboBoxAudioCodecsFactorySelection insert list end "pcm_s16le"

	ComboBoxAudioBitRateFactorySelection clear
	ComboBoxAudioBitRateFactorySelection insert list end ""
	ComboBoxAudioBitRateFactorySelection insert list end "13k"
	ComboBoxAudioBitRateFactorySelection insert list end "16k"
	ComboBoxAudioBitRateFactorySelection insert list end "32k"
	ComboBoxAudioBitRateFactorySelection insert list end "64k"
	ComboBoxAudioBitRateFactorySelection insert list end "80k"
	ComboBoxAudioBitRateFactorySelection insert list end "96k"
	ComboBoxAudioBitRateFactorySelection insert list end "112k"
	ComboBoxAudioBitRateFactorySelection insert list end "128k"
	ComboBoxAudioBitRateFactorySelection insert list end "160k"
	ComboBoxAudioBitRateFactorySelection insert list end "192k"
	ComboBoxAudioBitRateFactorySelection insert list end "224k"
	ComboBoxAudioBitRateFactorySelection insert list end "256k"
	ComboBoxAudioBitRateFactorySelection insert list end "320k"
	ComboBoxAudioBitRateFactorySelection insert list end "448k"
	ComboBoxAudioBitRateFactorySelection insert list end "1536k"

	ComboBoxAudioSampleRateFactorySelection clear
	ComboBoxAudioSampleRateFactorySelection insert list end ""
	ComboBoxAudioSampleRateFactorySelection insert list end "8k"
	ComboBoxAudioSampleRateFactorySelection insert list end "11.025k"
	ComboBoxAudioSampleRateFactorySelection insert list end "22.05k"
	ComboBoxAudioSampleRateFactorySelection insert list end "32k"
	ComboBoxAudioSampleRateFactorySelection insert list end "44.1k"
	ComboBoxAudioSampleRateFactorySelection insert list end "48k"
	ComboBoxAudioSampleRateFactorySelection insert list end "96k"

	ComboBoxAudioFileExtensionFactorySelection clear
	ComboBoxAudioFileExtensionFactorySelection insert list end ""
	ComboBoxAudioFileExtensionFactorySelection insert list end ".aac"
	ComboBoxAudioFileExtensionFactorySelection insert list end ".mp3"
	ComboBoxAudioFileExtensionFactorySelection insert list end ".m4a"
	ComboBoxAudioFileExtensionFactorySelection insert list end ".ogg"
	ComboBoxAudioFileExtensionFactorySelection insert list end ".wav"

	ComboBoxAudioTagFactorySelection clear
	ComboBoxAudioTagFactorySelection insert list end ""
	ComboBoxAudioTagFactorySelection insert list end "sowt"

	ComboBoxAudioChannelsFactorySelection clear
	ComboBoxAudioChannelsFactorySelection insert list end ""
	ComboBoxAudioChannelsFactorySelection insert list end "1"
	ComboBoxAudioChannelsFactorySelection insert list end "2"
	ComboBoxAudioChannelsFactorySelection insert list end "3"
	ComboBoxAudioChannelsFactorySelection insert list end "6"

#	ComboBoxAudioStreamIDFactorySelection clear
#	ComboBoxAudioStreamIDFactorySelection insert list end ""
#	ComboBoxAudioStreamIDFactorySelection insert list end "0:4"


# Start Time Offset
#vidopts="-ss 1 -vcodec mpeg4 -b:v 35000k -map 0:3" -- FastChannel2FCP
# Force Format
#audopts="-acodec mp2 -ab 160000 -f vob" -- NewsPath_Submit


	ScaleProgressBarProgramFrontEnd configure  -state disabled
}
# End InitFreeFactory
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
proc InitVariables {} {
##########################
# Free Factory variables
	global FreeFactoryDataDirectoryPath FreeFactoryDataFileName SaveFilePath DeleteConversionLogs

##########################
# Video and Audio variables
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry ConversionProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID 
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

		set FactoryDescription ""
		set NotifyDirectoryEntry ""
		set OutputFileSuffixEntry ""
		set OutputDirectoryEntry ""
		set FTPProgram ""
		set FTPURLEntry ""
		set FTPUserNameEntry ""
		set FTPPasswordEntry ""
		set FTPRemotePathEntry ""
		set FTPTransferType "asc"
		set VideoCodecs ""
		set VideoWrapper ""
		set VideoFrameRate ""
		set VideoSize ""
		set VideoTarget ""
		set VideoTags ""
		set Threads ""
		set Aspect ""
		set VideoBitRate ""
		set VideoPreset ""
		set VideoStreamID ""
		set GroupPicSizeEntry ""
		set BFramesEntry ""
		set FrameStrategyEntry ""
		set ForceFormat ""
		set StartTimeOffsetEntry ""
		set AudioCodecs ""
		set AudioBitRate ""
		set AudioSampleRate ""
		set AudioFileExtension ""
		set AudioTag ""
		set AudioChannels ""
		set AudioStreamID ""
		set SelectedFactory ""
		set ConversionProgram ""
		set DeleteConversionLogs "Yes"
}
# End InitVariables
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
proc SaveFactoryFile {} {

##########################
# Video and Audio variables
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry ConversionProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID 
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

##########################
# Free Factory variables
	global FreeFactoryDataDirectoryPath FreeFactoryDataFileName SaveFilePath DeleteConversionLogs

##########################
# System Control variables
	global PPref screenx screeny passconfig SystemTime FreeFactoryInstalledVERSION FreeFactoryInstallType
	global returnFileName returnFileName returnFullPath fileDialogOk dirpath topPass
	global ShowIconBar1 ShowIconBar2 ShowIconBar3
	global ScaleWidth ProgressPercentComplete ProgressActionTitle ProgressDetailCount TotalRecords ProcessedRecords


##########################
# File Dialog variables
	global FileSelectTypeList buttonImagePathFileDialog WindowName ToolTip fullDirPath returnFileName returnFileName returnFullPath fileDialogOk

	set FileHandle [open "/opt/FreeFactory/Factories/$SelectedFactory" w]
	puts $FileHandle "FACTORYDESCRIPTION=[string trim $FactoryDescription]"
	puts $FileHandle "NOTIFYDIRECTORY=[string trim $NotifyDirectoryEntry]"
	puts $FileHandle "OUTPUTDIRECTORY=[string trim $OutputDirectoryEntry]"
	puts $FileHandle "OUTPUTFILESUFFIX=[string trim $OutputFileSuffixEntry]"
	puts $FileHandle "CONVERSIONPROGRAM=[string trim $ConversionProgram]"
	puts $FileHandle "FTPPROGRAM=[string trim $FTPProgram]"
	puts $FileHandle "FTPURL=[string trim $FTPURLEntry]"
	puts $FileHandle "FTPUSERNAME=[string trim $FTPUserNameEntry]"
	puts $FileHandle "FTPPASSWORD=[string trim $FTPPasswordEntry]"
	puts $FileHandle "FTPREMOTEPATH=[string trim $FTPRemotePathEntry]"
	puts $FileHandle "FTPTRANSFERTYPE=[string trim $FTPTransferType]"
	puts $FileHandle "VIDEOCODECS=[string trim $VideoCodecs]"
	puts $FileHandle "VIDEOWRAPPER=[string trim $VideoWrapper]"
	puts $FileHandle "VIDEOFRAMERATE=[string trim $VideoFrameRate]"
	puts $FileHandle "VIDEOSIZE=[string trim $VideoSize]"
	puts $FileHandle "VIDEOTARGET=[string trim $VideoTarget]"
	puts $FileHandle "VIDEOTAGS=[string trim $VideoTags]"
	puts $FileHandle "THREADS=[string trim $Threads]"
	puts $FileHandle "ASPECT=[string trim $Aspect]"
	puts $FileHandle "VIDEOBITRATE=[string trim $VideoBitRate]"
	puts $FileHandle "VIDEOPRESET=[string trim $VideoPreset]"
	puts $FileHandle "VIDEOSTREAMID=[string trim $VideoStreamID]"
	puts $FileHandle "GROUPPICSIZE=[string trim $GroupPicSizeEntry]"
	puts $FileHandle "BFRAMES=[string trim $BFramesEntry]"
	puts $FileHandle "FRAMESTRATEGY=[string trim $FrameStrategyEntry]"
	puts $FileHandle "FORCEFORMAT=[string trim $ForceFormat]"
	puts $FileHandle "STARTTIMEOFFSET=[string trim $StartTimeOffsetEntry]"
	puts $FileHandle "AUDIOCODECS=[string trim $AudioCodecs]"
	puts $FileHandle "AUDIOBITRATE=[string trim $AudioBitRate]"
	puts $FileHandle "AUDIOSAMPLERATE=[string trim $AudioSampleRate]"
	puts $FileHandle "AUDIOFILEEXTENSION=[string trim $AudioFileExtension]"
	puts $FileHandle "AUDIOTAG=[string trim $AudioTag]"
	puts $FileHandle "AUDIOCHANNELS=[string trim $AudioChannels]"
	puts $FileHandle "AUDIOSTREAMID=[string trim $AudioStreamID]"
	puts $FileHandle "DELETECONVERSIONLOGS=[string trim $DeleteConversionLogs]"
	close $FileHandle
	ScrolledListBoxFactoryFilesFactorySelection delete 0 end
	foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
		ScrolledListBoxFactoryFilesFactorySelection insert end [file tail $item]
		if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" || [file attributes $item -permissions]=="00444"} {
			ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #ff0000
		}
		if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
			|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
			|| [file attributes $item -permissions]=="00660"} {
			ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #0000ff
		}
	}
}
# End SaveFactoryFile
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
proc DeleteFactoryFile {} {

##########################
# Video and Audio variables
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry ConversionProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID 
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

##########################
# Free Factory variables
	global FreeFactoryDataDirectoryPath FreeFactoryDataFileName SaveFilePath DeleteConversionLogs

##########################
# System Control variables
	global PPref screenx screeny passconfig SystemTime FreeFactoryInstalledVERSION FreeFactoryInstallType
	global returnFileName returnFileName returnFullPath fileDialogOk dirpath topPass
	global ShowIconBar1 ShowIconBar2 ShowIconBar3 GenericConfirmName GenericConfirm
	global ScaleWidth ProgressPercentComplete ProgressActionTitle ProgressDetailCount TotalRecords ProcessedRecords


##########################
# File Dialog variables
	global FileSelectTypeList buttonImagePathFileDialog WindowName ToolTip fullDirPath returnFileName returnFileName returnFullPath fileDialogOk

		if {$PPref(ConfirmFileDeletions) == "Yes"} {
			set GenericConfirm 2
			Window show .genericConfirm
			widgetUpdate
			set GenericConfirmName "Delete $SelectedFactory factory file"
			append GenericConfirmName "  $SelectedFactory  ?"
			wm title .genericConfirm "Delete File Confirmation"
			tkwait window .genericConfirm
			if {$GenericConfirm == 1} {
				set r [file delete -force /opt/FreeFactory/Factories/$SelectedFactory]
				ScrolledListBoxFactoryFilesFactorySelection delete 0 end
				foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
					ScrolledListBoxFactoryFilesFactorySelection insert end [file tail $item]
					if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" || [file attributes $item -permissions]=="00444"} {
						ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #ff0000
					}
					if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
						|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
						|| [file attributes $item -permissions]=="00660"} {
						ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #0000ff
					}
				}
			set SelectedFactory ""
			}
		} else {
			set r [file delete -force /opt/FreeFactory/Factories/$SelectedFactory]
			ScrolledListBoxFactoryFilesFactorySelection clear
			ScrolledListBoxFactoryFilesFactorySelection delete 0 end
			foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
				ScrolledListBoxFactoryFilesFactorySelection insert end [file tail $item]
				if {[file attributes $item -permissions]=="00400" || [file attributes $item -permissions]=="00440" || [file attributes $item -permissions]=="00444"} {
					ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #ff0000
				}
				if {[file attributes $item -permissions]=="00600" || [file attributes $item -permissions]=="00664" \
					|| [file attributes $item -permissions]=="00666" || [file attributes $item -permissions]=="00644" \
					|| [file attributes $item -permissions]=="00660"} {
					ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -foreground #0000ff
				}
			}
			set SelectedFactory ""
		}
}
# End DeleteFactoryFile
################################################################################
################################################################################
################################################################################
################################################################################

