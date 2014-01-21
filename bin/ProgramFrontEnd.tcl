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
# System Control variables
	global PPref screenx screeny passconfig SystemTime FreeFactoryInstalledVERSION FreeFactoryInstallType WindowSizeX WindowSizeY FontSizeLabel FontSizeText
	global SelectAllText ConfirmFileSaves ConfirmFileDeletions SettingsCancelConfirm
	global ScaleWidth ProgressPercentComplete ProgressActionTitle ProgressDetailCount TotalRecords ProcessedRecords

##########################
# Free Factory variables
	global DeleteSource DeleteConversionLogs EnableFactory
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry FFMxProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType FTPDeleteAfter
	global RunFrom FactoryLinks FreeFactoryAction FactoryEnableEMail FactoryEMailNameEntry FactoryEMailAddressEntry FactoryEMailsName
	global EnableFactoryLinking FactoryEMailsAddress FactoryEMailMessage GlobalEMailMessage

	global DeleteSourceTmp DeleteConversionLogsTmp EnableFactoryTmp
	global FactoryDescriptionTmp NotifyDirectoryEntryTmp SelectedFactoryTmp OutputFileSuffixEntryTmp FFMxProgramTmp OutputDirectoryEntryTmp
	global FTPProgramTmp FTPURLEntryTmp FTPUserNameEntryTmp FTPPasswordEntryTmp FTPRemotePathEntryTmp FTPTransferTypeTmp FTPDeleteAfterTmp
	global RunFromTmp FactoryLinksTmp FreeFactoryActionTmp FactoryEnableEMailTmp FactoryEMailNameEntryTmp FactoryEMailAddressEntryTmp FactoryEMailsNameTmp
	global EnableFactoryLinkingTmp FactoryEMailsAddressTmp FactoryEMailMessageTmp

##########################
# Video and Audio variables
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

	global VideoCodecsTmp VideoWrapperTmp VideoFrameRateTmp VideoSizeTmp VideoTargetTmp VideoTagsTmp ThreadsTmp AspectTmp VideoBitRateTmp VideoPresetTmp VideoStreamIDTmp
	global GroupPicSizeEntryTmp BFramesEntryTmp FrameStrategyEntryTmp StartTimeOffsetEntryTmp ForceFormatTmp
	global AudioCodecsTmp AudioBitRateTmp AudioSampleRateTmp AudioTagTmp AudioChannelsTmp AudioStreamIDTmp AudioFileExtensionTmp

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
	global LogListPos LogListName LogList
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
	set xCord [expr int(($screenx-950)/2)]
	set yCord [expr int(($screeny-550)/2)]
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
    wm geometry $top 950x550+$xCord+$yCord; update
    wm maxsize $top 950 550
    wm minsize $top 950 550
    wm overrideredirect $top 0
    wm resizable $top 0 0
    wm deiconify $top
    wm title $top "New Toplevel 1"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    bind $top <ButtonRelease-3> {tk_messageBox -message %W}

    bind $top <Escape> {exit}
    bind $top <Control-n> {ButtonNew invoke}
    bind $top <Control-N> {ButtonNew invoke}
    bind $top <Control-s> {ButtonSave invoke}
    bind $top <Control-S> {ButtonSave invoke}
    bind $top <Control-d> {ButtonDelete invoke}
    bind $top <Control-D> {ButtonDelete invoke}
    bind $top <Control-h> {ButtonHelp invoke}
    bind $top <Control-H> {ButtonHelp invoke}
    bind $top <F1> {ButtonHelp invoke}

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

	$site_3_0 add cascade -menu "$site_3_0.men03" -label "View"
	vTcl:DefineAlias "$site_3_0.men03" "Menu3ProgramFrontEnd" vTcl:WidgetProc "Toplevel1" 1

	menu $site_3_0.men03 -tearoff 0
	$site_3_0.men03 add command -command {
		source "/opt/FreeFactory/bin/FreeFactoryViewLogs.tcl"
		Window show .freeFactoryViewLogs
		Window show .freeFactoryViewLogs
		widgetUpdate
		InitFreeFactoryViewLogs
#		FillLogList
	} -label "View Logs"

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

	button $site_4_4.viewLogsButton -borderwidth 0 -highlightthickness 0 -image [vTcl:image:get_image [file join / opt FreeFactory Pics log4-32x32.gif]] \
	-command {
		source "/opt/FreeFactory/bin/FreeFactoryViewLogs.tcl"
		Window show .freeFactoryViewLogs
		Window show .freeFactoryViewLogs
		widgetUpdate
		FillLogList
	} -text ""
	vTcl:DefineAlias "$site_4_4.viewLogsButton" "ButtonViewLogsFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_4.viewLogsButton -in $site_4_4 -anchor nw -expand 0 -fill none -side left
	balloon $site_4_4.viewLogsButton "View Logs"

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

	label $site_3_1.readOnlyFactorysLabel -text "Read Only" -background $PPref(color,widget,back) -foreground #ff0000 -border 1 -relief sunken
	vTcl:DefineAlias "$site_3_1.readOnlyFactorysLabel" "LabelReadOnlyFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_1.readOnlyFactorysLabel -in $site_3_1 -anchor w -expand 0 -fill none -side left

	label $site_3_1.disableFactorysLabel -text "Disabled" -background #efefef -foreground #0000ff -border 1 -relief sunken
	vTcl:DefineAlias "$site_3_1.disableFactorysLabel" "LabelDisabledFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_1.disableFactorysLabel -in $site_3_1 -anchor center -expand 1 -fill none -side left

	label $site_3_1.readWriteFactorysLabel -text "Read Write" -background $PPref(color,widget,back) -foreground #0000ff -border 1 -relief sunken
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
		set SelectedFactoryTmp2 [ScrolledListBoxFactoryFilesFactorySelection get [ScrolledListBoxFactoryFilesFactorySelection curselection ]]
# This first condition statement is a hack.  For some reason when
# the program is first run and the first click is made on a factory
# the checking condition statement returned a false positive meaning
# somehow one of the variables got changed.  Unable to track in down
# at present ant this is a fix.
		if {$SelectedFactoryTmp != "" && $SelectedFactoryTmp2 != $SelectedFactory} {
# Before switching factories check to see if anything has changed and
# prompt to save before switching.
			if {$FactoryDescriptionTmp != $FactoryDescription || $NotifyDirectoryEntryTmp != $NotifyDirectoryEntry || $OutputDirectoryEntryTmp != $OutputDirectoryEntry \
			|| $OutputFileSuffixEntryTmp != $OutputFileSuffixEntry || $FFMxProgramTmp != $FFMxProgram || $RunFromTmp != $RunFrom \
			|| $FTPProgramTmp != $FTPProgram || $FTPURLEntryTmp != $FTPURLEntry || $FTPUserNameEntryTmp != $FTPUserNameEntry \
			|| $FTPPasswordEntryTmp != $FTPPasswordEntry || $FTPRemotePathEntryTmp != $FTPRemotePathEntry || $FTPTransferTypeTmp != $FTPTransferType \
			|| $FTPDeleteAfterTmp != $FTPDeleteAfter || $VideoCodecsTmp != $VideoCodecs || $VideoWrapperTmp != $VideoWrapper \
			|| $VideoFrameRateTmp != $VideoFrameRate || $VideoSizeTmp != $VideoSize || $VideoTargetTmp != $VideoTarget \
			|| $VideoTagsTmp != $VideoTags || $ThreadsTmp != $Threads || $AspectTmp != $Aspect \
			|| $VideoBitRateTmp != $VideoBitRate || $VideoPresetTmp != $VideoPreset || $VideoStreamIDTmp != $VideoStreamID \
			|| $GroupPicSizeEntryTmp != $GroupPicSizeEntry	|| $BFramesEntryTmp != $BFramesEntry || $FrameStrategyEntryTmp != $FrameStrategyEntry \
			|| $ForceFormatTmp != $ForceFormat || $StartTimeOffsetEntryTmp != $StartTimeOffsetEntry || $AudioCodecsTmp != $AudioCodecs \
			|| $AudioBitRateTmp != $AudioBitRate || $AudioSampleRateTmp != $AudioSampleRate || $AudioFileExtensionTmp != $AudioFileExtension \
			|| $AudioTagTmp != $AudioTag || $AudioChannelsTmp != $AudioChannels || $AudioStreamIDTmp != $AudioStreamID \
			|| $DeleteSourceTmp != $DeleteSource || $DeleteConversionLogsTmp != $DeleteConversionLogs || $EnableFactoryTmp != $EnableFactory \
			|| $FreeFactoryActionTmp != $FreeFactoryAction || $FactoryLinksTmp != $FactoryLinks || $FactoryEnableEMailTmp != $FactoryEnableEMail \
			|| $FactoryEMailsNameTmp != $FactoryEMailsName || $FactoryEMailsAddressTmp != $FactoryEMailsAddress || $FactoryEMailMessageTmp != $FactoryEMailMessage \
			|| $EnableFactoryLinkingTmp != $EnableFactoryLinking} {
				set GenericConfirm 2
				Window show .genericConfirm
				widgetUpdate
				set GenericConfirmName "This factory has changed. Save\nfactory file before loading new ?"
				wm title .genericConfirm "Save Factory Confirmation"
				tkwait window .genericConfirm
				if {$GenericConfirm == 1} {
					SaveFactoryFile
				} else {
					if {[file exists "/opt/FreeFactory/Factories/$SelectedFactory-Message"]} {
						file delete -force "/opt/FreeFactory/Factories/$SelectedFactory-Message"
					}
				}
			}
		}
# Now set the variables and switch to the new factory
		if {$SelectedFactoryTmp2 != $SelectedFactory} {
			set SelectedFactory $SelectedFactoryTmp2
			set SelectedFactoryTmp $SelectedFactory
			InitVariables
			ButtonAddLink configure -state disable
			ButtonRemoveLink configure -state disable
			ButtonAddEMail configure -state disable
			ButtonUpdateEMail configure -state disable
			ButtonRemoveEMail configure -state disable
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
						"FFMXPROGRAM" {set FFMxProgram $FactoryValue}
						"RUNFROM" {set RunFrom $FactoryValue}
						"FTPPROGRAM" {set FTPProgram $FactoryValue}
						"FTPURL" {set FTPURLEntry $FactoryValue}
						"FTPUSERNAME" {set FTPUserNameEntry $FactoryValue}
						"FTPPASSWORD" {
							set FTPPasswordEntry $FactoryValue
# This will decode the FTP password variable
#						set PasswordChars [string length $FactoryValue]
#						set DecodedPassword ""
#						for {set x 0} {$x < $PasswordChars} {incr x} {
#							set DecodedChar  [format %c [expr [scan [string index $FactoryValue $x] %c] - 128]]
#							append DecodedPassword $DecodedChar
#						}
#						set FTPPasswordEntry $DecodedPassword
						}
						"FTPREMOTEPATH" {set FTPRemotePathEntry $FactoryValue}
						"FTPTRANSFERTYPE" {set FTPTransferType $FactoryValue}
						"FTPDELETEAFTER" {set FTPDeleteAfter $FactoryValue}
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
						"DELETESOURCE" {set DeleteSource $FactoryValue}
						"DELETECONVERSIONLOGS" {set DeleteConversionLogs $FactoryValue}
						"ENABLEFACTORY" {set EnableFactory $FactoryValue}
						"FREEFRACTORYACTION" {set FreeFactoryAction $FactoryValue}
						"ENABLEFACTORYLINKING" {set EnableFactoryLinking $FactoryValue}
						"FACTORYLINKS" {set FactoryLinks $FactoryValue}
						"FACTORYENABLEEMAIL" {set FactoryEnableEMail $FactoryValue}
						"FACTORYEMAILNAME" {set FactoryEMailsName $FactoryValue}
						"FACTORYEMAILADDRESS" {set FactoryEMailsAddress $FactoryValue}
						"FACTORYEMAILMESSAGESTART" {
							set FactoryEMailMessage ""
							while {![eof $FileHandle] && $FactoryValue !="FACTORYEMAILMESSAGEEND"} {
								gets $FileHandle FactoryValue
								if {$FactoryValue != "FACTORYEMAILMESSAGEEND"} {
									append FactoryEMailMessage $FactoryValue\n
	
								}
							}
						}
					}
				}
			}
			close $FileHandle

			set FactoryDescriptionTmp $FactoryDescription
			set NotifyDirectoryEntryTmp $NotifyDirectoryEntry
			set OutputDirectoryEntryTmp $OutputDirectoryEntry
			set OutputFileSuffixEntryTmp $OutputFileSuffixEntry
			set FFMxProgramTmp $FFMxProgram
			set RunFromTmp $RunFrom
			set FTPProgramTmp $FTPProgram
			set FTPURLEntryTmp $FTPURLEntry
			set FTPUserNameEntryTmp $FTPUserNameEntry
			set FTPPasswordEntryTmp $FTPPasswordEntry
			set FTPRemotePathEntryTmp $FTPRemotePathEntry
			set FTPTransferTypeTmp $FTPTransferType
			set FTPDeleteAfterTmp $FTPDeleteAfter
			set VideoCodecsTmp $VideoCodecs
			set VideoWrapperTmp $VideoWrapper
			set VideoFrameRateTmp $VideoFrameRate
			set VideoSizeTmp $VideoSize
			set VideoTargetTmp $VideoTarget
			set VideoTagsTmp $VideoTags
			set ThreadsTmp $Threads
			set AspectTmp $Aspect
			set VideoBitRateTmp $VideoBitRate
			set VideoPresetTmp $VideoPreset
			set VideoStreamIDTmp $VideoStreamID
			set GroupPicSizeEntryTmp $GroupPicSizeEntry
			set BFramesEntryTmp $BFramesEntry
			set FrameStrategyEntryTmp $FrameStrategyEntry
			set ForceFormatTmp $ForceFormat
			set StartTimeOffsetEntryTmp $StartTimeOffsetEntry
			set AudioCodecsTmp $AudioCodecs
			set AudioBitRateTmp $AudioBitRate
			set AudioSampleRateTmp $AudioSampleRate
			set AudioFileExtensionTmp $AudioFileExtension
			set AudioTagTmp $AudioTag
			set AudioChannelsTmp $AudioChannels
			set AudioStreamIDTmp $AudioStreamID
			set DeleteSourceTmp $DeleteSource
			set DeleteConversionLogsTmp $DeleteConversionLogs
			set EnableFactoryTmp $EnableFactory
			set FreeFactoryActionTmp $FreeFactoryAction
			set EnableFactoryLinkingTmp $EnableFactoryLinking
			set FactoryLinksTmp $FactoryLinks
			set FactoryEnableEMailTmp $FactoryEnableEMail
			set FactoryEMailsNameTmp $FactoryEMailsName
			set FactoryEMailsAddressTmp $FactoryEMailsAddress
			set FactoryEMailMessageTmp $FactoryEMailMessage
# Load the list box with factory emails.
			ScrolledListBoxFactoryEMail delete 0 end
			set ListLength [llength $FactoryEMailsName]
			for {set x 0} {$x < $ListLength} {incr x} {
				ScrolledListBoxFactoryEMail insert end [lindex $FactoryEMailsName $x]
			}
			set FactoryEMailNameEntry ""
			set FactoryEMailAddressEntry ""
			ButtonAddEMail configure -state disable
# Load combo box with linked factories.
			ComboBoxLinkedFactory clear
			ComboBoxLinkedFactory insert list end ""
			ScrolledListBoxFactoryLinking delete 0 end
			set ListLength [llength $FactoryLinks]
			foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
# Also check to see if factory already linked.
				set Linked "Ok"
				for {set x 0} {$x < $ListLength} {incr x} {
					if {[file tail $item] == [lindex $FactoryLinks $x]} {
						set Linked "No"
						break
					}
				}
# If factory not already linked and the factory in not itself then add to the combo box.
				if {$SelectedFactory != [file tail $item] && $Linked == "Ok"} {
					ComboBoxLinkedFactory insert list end [file tail $item]
				}
			}
# Load the list box with linked factories.
			ScrolledListBoxFactoryLinking delete 0 end
			for {set x 0} {$x < $ListLength} {incr x} {
				ScrolledListBoxFactoryLinking insert end [lindex $FactoryLinks $x]
				set FileHandle [open "/opt/FreeFactory/Factories/[lindex $FactoryLinks $x]" r]
				while {![eof $FileHandle]} {
					gets $FileHandle FactoryVar
					set EqualDelimiter [string first "=" $FactoryVar]
					if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
						set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
						set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
						if {$FactoryField == "ENABLEFACTORY"} {
							if {$FactoryValue != "Yes"} {
								ScrolledListBoxFactoryLinking itemconfigure end -background #efefef
							}
						}
					}
				}
				close $FileHandle
			}
		}
	} -width 200
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

	frame $site_5_0.rightFrame -relief flat -height 50 -width 100 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_0.rightFrame" "FrameRight" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1 $site_5_0.rightFrame

	::iwidgets::labeledframe $site_5_1.factoryOptionsFrame -labelpos nw -labeltext "Factory Options"
	vTcl:DefineAlias "$site_5_1.factoryOptionsFrame" "LabeledFrameFactoryOptions" vTcl:WidgetProc "Toplevel1" 1

	set site_5_2 [$site_5_1.factoryOptionsFrame childsite]

	::iwidgets::entryfield $site_5_2.factoryDescriptionEntry -width 35 -labeltext "Description"  -textvariable FactoryDescription -relief sunken -justify left
	vTcl:DefineAlias "$site_5_2.factoryDescriptionEntry" "FactoryDescriptionEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_2.factoryDescriptionEntry"
	set BindWidgetEntry "$site_5_2.factoryDescriptionEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFactoryDescriptionChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2.factoryDescriptionEntry -in $site_5_2 -anchor nw -expand 0 -fill x -side top
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFactoryDescriptionChild select range 0 end}
		EntryFactoryDescriptionChild icursor end
	}
        bind $BindWidgetEntry <Key-Return> {focus .programFrontEnd.middleFrame.rightFrame.notifyDirectoryFrame.notifyDirectoryEntry.lwchildsite.entry}
        bind $BindWidgetEntry <Key-KP_Enter> {focus .programFrontEnd.middleFrame.rightFrame.notifyDirectoryFrame.notifyDirectoryEntry.lwchildsite.entry}

	frame $site_5_2.notifyDirectoryFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_2.notifyDirectoryFrame" "FrameNotifyDirectory" vTcl:WidgetProc "Toplevel1" 1

	set site_5_2_0 $site_5_2.notifyDirectoryFrame

	::iwidgets::combobox $site_5_2_0.notifyDirectoryComboBoxFactorySelection -labeltext "Notify Directory" -labelpos w \
        -highlightthickness 0 -command {} -width 12 -listheight 100 -justify left -selectioncommand {
	} -textvariable NotifyDirectoryEntry -justify left
	vTcl:DefineAlias "$site_5_2_0.notifyDirectoryComboBoxFactorySelection" "ComboBoxNotifyDirectoryFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.notifyDirectoryComboBoxFactorySelection -in $site_5_2_0 -anchor w -expand 1 -fill x -side left

	button $site_5_2_0.getNotifyDirectoryButton \
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
	vTcl:DefineAlias "$site_5_2_0.getNotifyDirectoryButton" "ButtonGetNotifyDirectorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.getNotifyDirectoryButton -in $site_5_2_0 -anchor ne -expand 0 -fill none -side right
	balloon $site_5_2_0.getNotifyDirectoryButton "Browse"

	pack $site_5_2.notifyDirectoryFrame -in $site_5_2 -anchor w -expand 0 -fill x -side top

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

	pack $site_5_2.outputDirectoryFrame -in $site_5_2 -anchor w -expand 0 -fill x -side top

	frame $site_5_2.outputFileSuffixFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_2.outputFileSuffixFrame" "FrameOutputFileSuffix" vTcl:WidgetProc "Toplevel1" 1

	set site_5_3_0 $site_5_2.outputFileSuffixFrame

	::iwidgets::entryfield $site_5_3_0.outputFileSuffixEntry -width 13 -labeltext "Output File Suffix"  -textvariable OutputFileSuffixEntry -relief sunken -justify left
	pack $site_5_3_0.outputFileSuffixEntry -in $site_5_3_0 -anchor nw -expand 0 -fill none -side left
	vTcl:DefineAlias "$site_5_3_0.outputFileSuffixEntry" "OutputFileSuffixEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_3_0.outputFileSuffixEntry"
	set BindWidgetEntry "$site_5_3_0.outputFileSuffixEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryOutputFileSuffixChild" vTcl:WidgetProc "Toplevel1" 1

	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryOutputFileSuffixChild select range 0 end}
		EntryOutputFileSuffixChild icursor end
	}

	radiobutton $site_5_3_0.runFromOptRadioButton \
	-command {} -text opt -value "opt" -variable RunFrom
	vTcl:DefineAlias "$site_5_3_0.runFromOptRadioButton" "RadioButtonRunFromOpt" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.runFromOptRadioButton -in $site_5_3_0 -anchor e -expand 1 -fill none -side right

	radiobutton $site_5_3_0.runFromUSRRadioButton \
	-command {} -text usr -value "usr" -variable RunFrom
	vTcl:DefineAlias "$site_5_3_0.runFromUSRRadioButton" "RadioButtonRunFromUSR" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.runFromUSRRadioButton -in $site_5_3_0 -anchor e -expand 1 -fill none -side right

	label $site_5_3_0.runFromLabel -text "Run From" -background #ececec
	vTcl:DefineAlias "$site_5_3_0.runFromLabel" "LabelRunFrom" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.runFromLabel -in $site_5_3_0 -anchor e -expand 1 -padx 2 -fill none -side right

	::iwidgets::combobox $site_5_3_0.fFMxProgramComboBoxFactorySelection -labeltext "FFMx Program" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 50 -selectioncommand {
	} -textvariable FFMxProgram -justify left
	vTcl:DefineAlias "$site_5_3_0.fFMxProgramComboBoxFactorySelection" "ComboBoxFFMxProgramFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_3_0.fFMxProgramComboBoxFactorySelection -in $site_5_3_0 -anchor e -expand 0 -fill none -side right

	pack $site_5_2.outputFileSuffixFrame -in $site_5_2 -anchor w -expand 0 -fill x  -pady 3 -side top

	frame $site_5_2.enableFactoryFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_2.enableFactoryFrame" "FrameEnableFactory" vTcl:WidgetProc "Toplevel1" 1

	set site_5_2_0  $site_5_2.enableFactoryFrame

	checkbutton $site_5_2_0.enableFactoryCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Enable Factory" -variable EnableFactory
	vTcl:DefineAlias "$site_5_2_0.enableFactoryCheckBox" "CheckButtonEnableFactory" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.enableFactoryCheckBox -in $site_5_2_0 -anchor nw -expand 0 -padx 5 -fill x -side left

	checkbutton $site_5_2_0.removeLogsCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Remove Logs" -variable DeleteConversionLogs
	vTcl:DefineAlias "$site_5_2_0.removeLogsCheckBox" "CheckButtonRemoveLogs" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.removeLogsCheckBox -in $site_5_2_0 -anchor nw -expand 0 -padx 5 -fill x -side left

	checkbutton $site_5_2_0.removeSourceCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Remove Source" -variable DeleteSource
	vTcl:DefineAlias "$site_5_2_0.removeSourceCheckBox" "CheckButtonRemoveSource" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.removeSourceCheckBox -in $site_5_2_0 -anchor nw -expand 0 -padx 5 -fill x -side left

	radiobutton $site_5_2_0.freeFactoryActionCopyRadioButton \
	-command {} -text Copy -value "Copy" -variable FreeFactoryAction
	vTcl:DefineAlias "$site_5_2_0.freeFactoryActionCopyRadioButton" "RadioButtonFreeFactoryActionCopy" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.freeFactoryActionCopyRadioButton -in $site_5_2_0 -anchor ne -expand 0 -fill none -side right

	radiobutton $site_5_2_0.freeFactoryActionEncodeRadioButton \
	-command {} -text "Encode" -value "Encode" -variable FreeFactoryAction
	vTcl:DefineAlias "$site_5_2_0.freeFactoryActionEncodeRadioButton" "RadioButtonFreeFactoryActionEncode" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.freeFactoryActionEncodeRadioButton -in $site_5_2_0 -anchor ne -expand 0 -fill none -side right

	label $site_5_2_0.freeFactoryActionLabel -text "Action" -background #ececec
	vTcl:DefineAlias "$site_5_2_0.freeFactoryActionLabel" "LabelFreeFactoryAction" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_2_0.freeFactoryActionLabel -in $site_5_2_0 -anchor ne -expand 0 -padx 0 -fill none -side right

	pack $site_5_2.enableFactoryFrame -in $site_5_2 -anchor w -expand 1 -fill x -pady 3 -side top

	::iwidgets::labeledframe $site_5_2.ftpOptions -labelpos nw -labeltext "FTP Options"
	vTcl:DefineAlias "$site_5_2.ftpOptions" "LabeledFrameFTPOptions" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_0 [$site_5_2.ftpOptions childsite]

	frame $site_6_0_0.ftpProgramFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_6_0_0.ftpProgramFrame" "FrameFTPProgram" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_1 $site_6_0_0.ftpProgramFrame

	::iwidgets::entryfield $site_6_0_1.ftpURLEntry -width 12 -labeltext "URL"  -textvariable FTPURLEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpURLEntry" "FTPURLEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpURLEntry"
	set BindWidgetEntry "$site_6_0_1.ftpURLEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPURLChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpURLEntry -in $site_6_0_1 -anchor nw -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPURLChild select range 0 end}
		EntryFTPURLChild icursor end
	}

	::iwidgets::entryfield $site_6_0_1.ftpUserNameEntry -width 12 -labeltext "User Name"  -textvariable FTPUserNameEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpUserNameEntry" "FTPUserNameEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpUserNameEntry"
	set BindWidgetEntry "$site_6_0_1.ftpUserNameEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPUserNameChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpUserNameEntry -in $site_6_0_1 -anchor nw -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPUserNameChild select range 0 end}
		EntryFTPUserNameChild icursor end
	}

	::iwidgets::entryfield $site_6_0_1.ftpPasswordEntry -width 12 -labeltext "Password"  -textvariable FTPPasswordEntry -relief sunken -justify left -show "*"
	vTcl:DefineAlias "$site_6_0_1.ftpPasswordEntry" "FTPPasswordEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpPasswordEntry"
	set BindWidgetEntry "$site_6_0_1.ftpPasswordEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPPasswordChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpPasswordEntry -in $site_6_0_1 -anchor nw -expand 1 -fill none -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPPasswordChild select range 0 end}
		EntryFTPPasswordChild icursor end
	}

	pack $site_6_0_0.ftpProgramFrame -in $site_6_0_0 -anchor w -expand 0 -fill x -side top

	frame $site_6_0_0.ftpRemotePathFrame -height 2 -highlightcolor black -relief flat -width 12  -border 2
	vTcl:DefineAlias "$site_6_0_0.ftpRemotePathFrame" "FrameFTPRemotePath" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_1 $site_6_0_0.ftpRemotePathFrame

	::iwidgets::combobox $site_6_0_1.ftpProgramComboBoxFactorySelection -labeltext "FTP Program" -labelpos w \
        -highlightthickness 0 -command {} -width 10 -listheight 100 -selectioncommand {
	} -textvariable FTPProgram -justify  left
	vTcl:DefineAlias "$site_6_0_1.ftpProgramComboBoxFactorySelection" "ComboBoxFTPProgramFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpProgramComboBoxFactorySelection -in $site_6_0_1 -anchor w -expand 1 -fill none -side left

	::iwidgets::entryfield $site_6_0_1.ftpRemotePathEntry -width 20 -labeltext "FTP Remote Path"  -textvariable FTPRemotePathEntry -relief sunken -justify left
	vTcl:DefineAlias "$site_6_0_1.ftpRemotePathEntry" "FTPRemotePathEntry" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_6_0_1.ftpRemotePathEntry"
	set BindWidgetEntry "$site_6_0_1.ftpRemotePathEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFTPRemotePathChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpRemotePathEntry -in $site_6_0_1 -anchor nw -expand 1 -fill x -side left
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFTPRemotePathChild select range 0 end}
		EntryFTPRemotePathChild icursor end
	}

	pack $site_6_0_0.ftpRemotePathFrame -in $site_6_0_0 -anchor nw -expand 0 -fill x -side top

	frame $site_6_0_0.ftpTransferTypeFrame -height 2 -highlightcolor black -relief flat -width 12  -border 2
	vTcl:DefineAlias "$site_6_0_0.ftpTransferTypeFrame" "FrameFTPTransferType" vTcl:WidgetProc "Toplevel1" 1

	set site_6_0_1 $site_6_0_0.ftpTransferTypeFrame

	checkbutton $site_6_0_1.ftpDeleteAfterCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Delete Output File After FTP" -variable FTPDeleteAfter
	vTcl:DefineAlias "$site_6_0_1.ftpDeleteAfterCheckBox" "CheckButtonFTPDeleteAfter" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpDeleteAfterCheckBox -in $site_6_0_1 -anchor nw -expand 0 -padx 2 -fill x -side left

	radiobutton $site_6_0_1.ftpTransferTypebinRadioButton \
	-command {} -text Binary -value "bin" -variable FTPTransferType
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypebinRadioButton" "RadioButtonFTPTransferTypeBIN" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypebinRadioButton -in $site_6_0_1 -anchor nw -expand 0 -fill none -side right

	radiobutton $site_6_0_1.ftpTransferTypeascRadioButton \
	-command {} -text ASCII -value "asc" -variable FTPTransferType
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypeascRadioButton" "RadioButtonFTPTransferTypeASC" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypeascRadioButton -in $site_6_0_1 -anchor nw -expand 0 -fill none -side right

	label $site_6_0_1.ftpTransferTypeLabel -text "Transfer Type:" -background #ececec
	vTcl:DefineAlias "$site_6_0_1.ftpTransferTypeLabel" "LabelFTPTransferType" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0_1.ftpTransferTypeLabel -in $site_6_0_1 -anchor w -expand 0 -padx 2 -fill none -side right

	pack $site_6_0_0.ftpTransferTypeFrame -in $site_6_0_0 -anchor nw -expand 0 -fill x -side top

	pack $site_5_2.ftpOptions -in $site_5_2 -anchor w -expand 1 -fill x -pady 5 -side top

	pack $site_5_1.factoryOptionsFrame -in $site_5_1 -anchor w -expand 1 -fill x -side top

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
	} -textvariable VideoFrameRate -justify right
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
        -highlightthickness 0 -command {} -width 25 -listheight 100 -selectioncommand {
	} -textvariable VideoPreset -justify  left
	vTcl:DefineAlias "$site_6_0.vPresetComboBoxFactorySelection" "ComboBoxVideoPresetFactorySelection" vTcl:WidgetProc "Toplevel1" 1
	pack $site_6_0.vPresetComboBoxFactorySelection -in $site_6_0 -anchor w -expand 0 -fill none -side top

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
	pack $site_5_0.rightFrame -in $site_1_0.middleFrame -anchor nw -expand 0 -fill none -side left

	frame $site_5_0.factoryEMailAndLinkFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_0.factoryEMailAndLinkFrame" "FrameEMailAndLink" vTcl:WidgetProc "Toplevel1" 1

	set site_5_0_0  $site_5_0.factoryEMailAndLinkFrame

	::iwidgets::labeledframe $site_5_0_0.factoryEMailLabeledFrame -labelpos nw -labeltext "Factory Email"
	vTcl:DefineAlias "$site_5_0_0.factoryEMailLabeledFrame" "LabeledFrameFactoryEmail" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1 [$site_5_0_0.factoryEMailLabeledFrame childsite]

	frame $site_5_1.enableEMailFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_1.enableEMailFrame" "FrameEMailEnable" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1_0  $site_5_1.enableEMailFrame

	checkbutton $site_5_1_0.enableFactoryEMailCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Enable EMail" -variable FactoryEnableEMail
	vTcl:DefineAlias "$site_5_1_0.enableFactoryEMailCheckBox" "CheckButtonEnableFactoryEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.enableFactoryEMailCheckBox -in $site_5_1_0 -anchor nw -expand 0 -padx 2 -fill x -side left

	button $site_5_1_0.addFactoryEMailMessageButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		source "/opt/FreeFactory/bin/FreeFactoryEMailMessage.tcl"
		Window show .freeFactoryEMailMessage
		Window show .freeFactoryEMailMessage
		widgetUpdate
		ScrolledTextFactoryEMailMessage clear
		ScrolledTextFactoryEMailMessage insert end $FactoryEMailMessage
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics message32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.addFactoryEMailMessageButton" "ButtonAddFactoryEMailMessage" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.addFactoryEMailMessageButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side right
	balloon $site_5_1_0.addFactoryEMailMessageButton "Add Message"

	pack $site_5_1.enableEMailFrame -in $site_5_1 -anchor w -expand 1 -fill x -side top

	::iwidgets::entryfield $site_5_1.eMailNameEntry -width 7 -labelpos w -labeltext "Name" -textvariable FactoryEMailNameEntry
	vTcl:DefineAlias "$site_5_1.eMailNameEntry" "EntryFactoryEMailName" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.eMailNameEntry -in $site_5_1 -anchor nw -expand 0 -fill x -side top
	set BindWidget "$site_5_1.eMailNameEntry"
	set BindWidgetEntry "$site_5_1.eMailNameEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidgetEntry" "EntryFactoryEMailNameChild" vTcl:WidgetProc "Toplevel1" 1
        bind $BindWidgetEntry <Key-Return> {focus .programFrontEnd.middleFrame.factoryEMailAndLinkFrame.factoryEMailLabeledFrame.childsite.eMailAddressEntry.lwchildsite.entry}
        bind $BindWidgetEntry <Key-KP_Enter> {focus .programFrontEnd.middleFrame.factoryEMailAndLinkFrame.factoryEMailLabeledFrame.childsite.eMailAddressEntry.lwchildsite.entry}
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFactoryEMailName selection range 0 end}
		EntryFactoryEMailNameChild icursor end
	}

	::iwidgets::entryfield $site_5_1.eMailAddressEntry -width 7 -labelpos w -labeltext "Address" -textvariable FactoryEMailAddressEntry
	vTcl:DefineAlias "$site_5_1.eMailAddressEntry" "EntryFactoryEMailAddress" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_1.eMailAddressEntry"
	set BindWidgetEntry "$site_5_1.eMailAddressEntry.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "EntryFactoryEMailAddressChild" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.eMailAddressEntry -in $site_5_1 -anchor nw -expand 0 -fill x -side top
        bind $BindWidgetEntry <Key-Return> {focus .programFrontEnd.middleFrame.factoryEMailAndLinkFrame.factoryEMailLabeledFrame.childsite.eMailNameEntry.lwchildsite.entry}
        bind $BindWidgetEntry <Key-KP_Enter> {focus .programFrontEnd.middleFrame.factoryEMailAndLinkFrame.factoryEMailLabeledFrame.childsite.eMailNameEntry.lwchildsite.entry}
	bind $BindWidgetEntry <FocusIn> {
		if {$PPref(SelectAllText) == "Yes"} {EntryFactoryEMailAddress selection range 0 end}
		EntryFactoryEMailAddressChild icursor end
	}

	::iwidgets::scrolledlistbox $site_5_1.factoryEMailListBox -activebackground #f9f9f9 -activerelief raised -background #e6e6e6 \
	-borderwidth 2 -disabledforeground #a3a3a3 -foreground #000000 -height 100 -highlightcolor black -highlightthickness 1 \
	-hscrollmode dynamic -selectmode single -jump 0 -labelpos n -labeltext "" -relief sunken \
	-sbwidth 10 -selectbackground #c4c4c4 -selectborderwidth 1 -selectforeground black -state normal \
	-textbackground #d9d9d9 -troughcolor #c4c4c4 -vscrollmode dynamic -dblclickcommand {} -selectioncommand {
# This code prevents an error when an empty list box is clicked on.
		set EMailFactoryPos -1
		catch [set EMailFactoryPos [ScrolledListBoxFactoryEMail curselection ]]
		if {$EMailFactoryPos > -1 } {
			set FactoryEMailNameEntry [ScrolledListBoxFactoryEMail get [ScrolledListBoxFactoryEMail curselection ]]
			set FactoryEMailAddressEntry [lindex $FactoryEMailsAddress [ScrolledListBoxFactoryEMail curselection ]]
			ButtonAddEMail configure -state disable
			ButtonUpdateEMail configure -state normal
			ButtonRemoveEMail configure -state normal
		}
	} -width 150
	vTcl:DefineAlias "$site_5_1.factoryEMailListBox" "ScrolledListBoxFactoryEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.factoryEMailListBox -in $site_5_1 -anchor n -expand 0 -fill both -side top

	frame $site_5_1.factoryEMailButtonFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_1.factoryEMailButtonFrame" "FrameFactoryEMailButton" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1_0  $site_5_1.factoryEMailButtonFrame

	button $site_5_1_0.newEMailButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		set FactoryEMailNameEntry ""
		set FactoryEMailAddressEntry ""
		ButtonAddEMail configure -state normal
		ButtonUpdateEMail configure -state disable
		ButtonRemoveEMail configure -state disable
		focus .programFrontEnd.middleFrame.factoryEMailAndLinkFrame.factoryEMailLabeledFrame.childsite.eMailNameEntry.lwchildsite.entry
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics new32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.newEMailButton" "ButtonNewEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.newEMailButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.newEMailButton "New EMail"

	button $site_5_1_0.addEMailButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		if {[string trim $FactoryEMailNameEntry] !="" && [string trim $FactoryEMailAddressEntry] !=""} {
			set ListLength [llength $FactoryEMailsName]
			set InList "No"
			for {set x 0} {$x < $ListLength} {incr x} {
				if {[lindex $FactoryEMailsName $x] == $FactoryEMailNameEntry} {
					set InList "Yes"
					break
				}
			}
			if {$InList == "No"} {
				lappend FactoryEMailsName $FactoryEMailNameEntry
				lappend FactoryEMailsAddress $FactoryEMailAddressEntry
			}
# Load the list box with factory emails.
			ScrolledListBoxFactoryEMail delete 0 end
			set ListLength [llength $FactoryEMailsName]
			for {set x 0} {$x < $ListLength} {incr x} {
				ScrolledListBoxFactoryEMail insert end [lindex $FactoryEMailsName $x]
			}
			set FactoryEMailNameEntry ""
			set FactoryEMailAddressEntry ""
			ButtonAddEMail configure -state disable
		}
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics AddEMailUser32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.addEMailButton" "ButtonAddEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.addEMailButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.addEMailButton "Add EMail - The factctory\nmust be saved to actually\nsave any additions."

	button $site_5_1_0.updateEMailButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		set ListLength [llength $FactoryEMailsName]
		set InList "No"
		for {set x 0} {$x < $ListLength} {incr x} {
			if {[lindex $FactoryEMailsName $x] == $FactoryEMailNameEntry} {
				set InList "Yes"
				break
			}
		}
		if {$InList == "No"} {
			set FactoryEMailsName [lreplace $FactoryEMailsName $EMailFactoryPos $EMailFactoryPos $FactoryEMailNameEntry]
			set FactoryEMailsAddress [lreplace $FactoryEMailsAddress $EMailFactoryPos $EMailFactoryPos $FactoryEMailAddressEntry]
		}
# Load the list box with factory emails.
		ScrolledListBoxFactoryEMail delete 0 end
		for {set x 0} {$x < $ListLength} {incr x} {
			ScrolledListBoxFactoryEMail insert end [lindex $FactoryEMailsName $x]
		}
		set FactoryEMailNameEntry ""
		set FactoryEMailAddressEntry ""
		ButtonUpdateEMail configure -state disable
		ButtonRemoveEMail configure -state disable
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics update32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.updateEMailButton" "ButtonUpdateEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.updateEMailButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.updateEMailButton "Update EMail - The factctory\nmust be saved to actually\nsave any changes."

	button $site_5_1_0.removeEMailButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		set FactoryEMailsNameRemove ""
		set FactoryEMailsAddressRemove ""
		set ListLength [llength $FactoryEMailsName]
		for {set x 0} {$x < $ListLength} {incr x} {
			if {$EMailFactoryPos != $x} {
				lappend FactoryEMailsNameRemove [lindex $FactoryEMailsName $x]
				lappend FactoryEMailsAddressRemove [lindex $FactoryEMailsAddress $x]
			}
		}
		set FactoryEMailsName $FactoryEMailsNameRemove
		set FactoryEMailsAddress $FactoryEMailsAddressRemove
# Load the list box with linked factories.
		ScrolledListBoxFactoryEMail delete 0 end
		for {set x 0} {$x < $ListLength} {incr x} {
			ScrolledListBoxFactoryEMail insert end [lindex $FactoryEMailsName $x]
		}
		set FactoryEMailNameEntry ""
		set FactoryEMailAddressEntry ""
		ButtonUpdateEMail configure -state disable
		ButtonRemoveEMail configure -state disable
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics RemoveEMailUser32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.removeEMailButton" "ButtonRemoveEMail" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.removeEMailButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.removeEMailButton "Remove EMail -  - The factctory\nmust be saved to actually\nrecord any removals."

	pack $site_5_1.factoryEMailButtonFrame -in $site_5_1 -anchor nw -expand 0 -fill x -side top
	pack $site_5_0_0.factoryEMailLabeledFrame -in $site_5_0_0 -anchor nw -expand 0 -fill both -side top

	::iwidgets::labeledframe $site_5_0_0.factoryLinkingLabeledFrame -labelpos nw -labeltext "Factory Linking"
	vTcl:DefineAlias "$site_5_0_0.factoryLinkingLabeledFrame" "LabeledFrameFactoryLinking" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1 [$site_5_0_0.factoryLinkingLabeledFrame childsite]

	checkbutton $site_5_1.enableFactoryLinkingCheckBox -command {} -offvalue "No" -onvalue "Yes"  -text "Enable Factory Linking" -variable EnableFactoryLinking
	vTcl:DefineAlias "$site_5_1.enableFactoryLinkingCheckBox" "CheckButtonEnableFactoryLinking" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.enableFactoryLinkingCheckBox -in $site_5_1 -anchor nw -expand 0 -padx 0 -fill none -side top

	::iwidgets::combobox $site_5_1.linkedFactoryComboBoxFactorySelection -editable 0 -labeltext "Selected Factory" -labelpos n \
        -highlightthickness 0 -command {} -width 13 -listheight 350 -selectioncommand {
# Only disable the Add button if there is something to add
		if {$LinkedFactory !=""} {
			ButtonAddLink configure -state normal
			ButtonRemoveLink configure -state disable
		} else {
			ButtonAddLink configure -state disable
			ButtonRemoveLink configure -state disable
		}
	} -textvariable LinkedFactory -justify  left
	vTcl:DefineAlias "$site_5_1.linkedFactoryComboBoxFactorySelection" "ComboBoxLinkedFactory" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.linkedFactoryComboBoxFactorySelection -in $site_5_1 -anchor nw -expand 0 -fill x -side top
	set BindWidget "$site_5_1.linkedFactoryComboBoxFactorySelection.lwchildsite.entry"
	vTcl:DefineAlias "$BindWidget" "ComboBoxLinkedFactoryEntryChild" vTcl:WidgetProc "Toplevel1" 1

	::iwidgets::entryfield $site_5_1.linkedListEntryLabel -width 10 -labelpos w -relief flat -labeltext "Linked To:" -textvariable SelectedFactory
	vTcl:DefineAlias "$site_5_1.linkedListEntryLabel" "EntryLabelLinkedFactories" vTcl:WidgetProc "Toplevel1" 1
	set BindWidget "$site_5_1.linkedListEntryLabel.lwchildsite.entry"
	pack $site_5_1.linkedListEntryLabel -in $site_5_1 -anchor w -expand 0 -fill x -side top

	::iwidgets::scrolledlistbox $site_5_1.linkedFactoriesListBox -activebackground #f9f9f9 -activerelief raised -background #e6e6e6 \
	-borderwidth 2 -disabledforeground #a3a3a3 -foreground #000000 -height 100 -highlightcolor black -highlightthickness 1 \
	-hscrollmode dynamic -selectmode single -jump 0 -labelpos n -labeltext "" -relief sunken \
	-sbwidth 10 -selectbackground #c4c4c4 -selectborderwidth 1 -selectforeground black -state normal \
	-textbackground #d9d9d9 -troughcolor #c4c4c4 -vscrollmode dynamic -dblclickcommand {} -selectioncommand {
# This code prevents an error when an empty list box is clicked on.
		set LinkedFactoryPos -1
		catch [set LinkedFactoryPos [ScrolledListBoxFactoryLinking curselection ]]
		if {$LinkedFactoryPos > -1 } {
			set LinkedFactory [ScrolledListBoxFactoryLinking get [ScrolledListBoxFactoryLinking curselection ]]
			ButtonAddLink configure -state disable
			ButtonRemoveLink configure -state normal
		}
	} -width 150
	vTcl:DefineAlias "$site_5_1.linkedFactoriesListBox" "ScrolledListBoxFactoryLinking" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1.linkedFactoriesListBox -in $site_5_1 -anchor n -expand 1 -fill both -side top

	frame $site_5_1.factoryLinkingButtonFrame -height 31 -relief flat -height 50 -borderwidth 0 -highlightthickness 0 -highlightcolor #e6e6e6
	vTcl:DefineAlias "$site_5_1.factoryLinkingButtonFrame" "FrameFactoryLinkingButton" vTcl:WidgetProc "Toplevel1" 1

	set site_5_1_0  $site_5_1.factoryLinkingButtonFrame

	button $site_5_1_0.addLinkButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		lappend FactoryLinks $LinkedFactory
		set LinkedFactory ""
		ComboBoxLinkedFactory clear
		ComboBoxLinkedFactory insert list end ""
		ScrolledListBoxFactoryLinking delete 0 end
		set ListLength [llength $FactoryLinks]
		foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
# Also check to see if factory already linked.
			set Linked "Ok"
			for {set x 0} {$x < $ListLength} {incr x} {
				if {[file tail $item] == [lindex $FactoryLinks $x]} {
					set Linked "No"
					break
				}
			}
# If factory not already linked and the factory in not itself then add to the combo box.
			if {$SelectedFactory != [file tail $item] && $Linked == "Ok"} {
				ComboBoxLinkedFactory insert list end [file tail $item]
			}
		}
# Load the list box with linked factories.
		ScrolledListBoxFactoryLinking delete 0 end
		for {set x 0} {$x < $ListLength} {incr x} {
			ScrolledListBoxFactoryLinking insert end [lindex $FactoryLinks $x]
			set FileHandle [open "/opt/FreeFactory/Factories/[lindex $FactoryLinks $x]" r]
			while {![eof $FileHandle]} {
				gets $FileHandle FactoryVar
				set EqualDelimiter [string first "=" $FactoryVar]
				if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
					set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
					set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
					if {$FactoryField == "ENABLEFACTORY"} {
						if {$FactoryValue != "Yes"} {
							ScrolledListBoxFactoryLinking itemconfigure end -background #efefef
						}
					}
				}
			}
			close $FileHandle
		}
		ButtonAddLink configure -state disable
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics AddFactoryLink32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.addLinkButton" "ButtonAddLink" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.addLinkButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.addLinkButton "Add Link - The factctory\nmust be saved to actually\nsave any additions."

	button $site_5_1_0.removeLinkButton -borderwidth 1 -highlightthickness 0 -relief raised \
	-command {
		set FactoryLinksRemove ""
		set ListLength [llength $FactoryLinks]
		for {set x 0} {$x < $ListLength} {incr x} {
			if {$LinkedFactoryPos != $x} {
				lappend FactoryLinksRemove [lindex $FactoryLinks $x]
			}
		}
		set FactoryLinks $FactoryLinksRemove
		set LinkedFactory ""
		ComboBoxLinkedFactory clear
		ComboBoxLinkedFactory insert list end ""
		ScrolledListBoxFactoryLinking delete 0 end
		set ListLength [llength $FactoryLinks]
		foreach item [lsort [glob -nocomplain /opt/FreeFactory/Factories/*]] {
# Also check to see if factory already linked.
			set Linked "Ok"
			for {set x 0} {$x < $ListLength} {incr x} {
				if {[file tail $item] == [lindex $FactoryLinks $x]} {
					set Linked "No"
					break
				}
			}
# If factory not already linked and the factory in not itself then add to the combo box.
			if {$SelectedFactory != [file tail $item] && $Linked == "Ok"} {
				ComboBoxLinkedFactory insert list end [file tail $item]
			}
		}
# Load the list box with linked factories.
		ScrolledListBoxFactoryLinking delete 0 end
		for {set x 0} {$x < $ListLength} {incr x} {
			ScrolledListBoxFactoryLinking insert end [lindex $FactoryLinks $x]
			set FileHandle [open "/opt/FreeFactory/Factories/[lindex $FactoryLinks $x]" r]
			while {![eof $FileHandle]} {
				gets $FileHandle FactoryVar
				set EqualDelimiter [string first "=" $FactoryVar]
				if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
					set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
					set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
					if {$FactoryField == "ENABLEFACTORY"} {
						if {$FactoryValue != "Yes"} {
							ScrolledListBoxFactoryLinking itemconfigure end -background #efefef
						}
					}
				}
			}
			close $FileHandle
		}
		ComboBoxLinkedFactory clear entry
		ButtonRemoveLink configure -state disable
	} -image [vTcl:image:get_image [file join / opt FreeFactory Pics RemoveFactoryLink32x32.gif]]
	vTcl:DefineAlias "$site_5_1_0.removeLinkButton" "ButtonRemoveLink" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_1_0.removeLinkButton -in $site_5_1_0 -anchor center -expand 1 -fill none -side left
	balloon $site_5_1_0.removeLinkButton "Remove Link - The factctory\nmust be saved to actually\nrecord any removals."

	pack $site_5_1.factoryLinkingButtonFrame -in $site_5_1 -anchor nw -expand 0 -fill x -side top
	pack $site_5_0_0.factoryLinkingLabeledFrame -in $site_5_0_0 -anchor nw -expand 1 -fill both -side top

	pack $site_5_0.factoryEMailAndLinkFrame -in $site_5_0 -anchor w -expand 1 -fill x -side left

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
	global DeleteSource DeleteConversionLogs EnableFactory
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry FFMxProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType FTPDeleteAfter
	global RunFrom FactoryLinks FreeFactoryAction FactoryEnableEMail FactoryEMailNameEntry FactoryEMailAddressEntry FactoryEMailsName
	global EnableFactoryLinking FactoryEMailsAddress FactoryEMailMessage GlobalEMailMessage

	global DeleteSourceTmp DeleteConversionLogsTmp EnableFactoryTmp
	global FactoryDescriptionTmp NotifyDirectoryEntryTmp SelectedFactoryTmp OutputFileSuffixEntryTmp FFMxProgramTmp OutputDirectoryEntryTmp
	global FTPProgramTmp FTPURLEntryTmp FTPUserNameEntryTmp FTPPasswordEntryTmp FTPRemotePathEntryTmp FTPTransferTypeTmp FTPDeleteAfterTmp
	global RunFromTmp FactoryLinksTmp FreeFactoryActionTmp FactoryEnableEMailTmp FactoryEMailNameEntryTmp FactoryEMailAddressEntryTmp FactoryEMailsNameTmp
	global EnableFactoryLinkingTmp FactoryEMailsAddressTmp FactoryEMailMessageTmp

##########################
# Video and Audio variables
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

	global VideoCodecsTmp VideoWrapperTmp VideoFrameRateTmp VideoSizeTmp VideoTargetTmp VideoTagsTmp ThreadsTmp AspectTmp VideoBitRateTmp VideoPresetTmp VideoStreamIDTmp
	global GroupPicSizeEntryTmp BFramesEntryTmp FrameStrategyEntryTmp StartTimeOffsetEntryTmp ForceFormatTmp
	global AudioCodecsTmp AudioBitRateTmp AudioSampleRateTmp AudioTagTmp AudioChannelsTmp AudioStreamIDTmp AudioFileExtensionTmp

	set SelectedFactory ""
	set SelectedFactoryTmp ""
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
		set FileHandle [open $item r]
		while {![eof $FileHandle]} {
			gets $FileHandle FactoryVar
			set EqualDelimiter [string first "=" $FactoryVar]
			if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
				set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
				set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
				switch $FactoryField {
					"ENABLEFACTORY" {
						if {$FactoryValue != "Yes"} {
							ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -background #efefef
						}
					}
				}
			}
		}
		close $FileHandle
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
		ComboBoxNotifyDirectoryFactorySelection insert list end [lindex $NotifyDirectory 0]
	}
	close $FileHandle

	ComboBoxFFMxProgramFactorySelection clear
	ComboBoxFFMxProgramFactorySelection insert list end ""
	ComboBoxFFMxProgramFactorySelection insert list end "ffmbc"
	ComboBoxFFMxProgramFactorySelection insert list end "ffmpeg"
#	ComboBoxFFMxProgramFactorySelection insert list end "libav"

	ComboBoxFTPProgramFactorySelection clear
	ComboBoxFTPProgramFactorySelection insert list end ""
	ComboBoxFTPProgramFactorySelection insert list end "ftp"
	ComboBoxFTPProgramFactorySelection insert list end "lftp"
	ComboBoxFTPProgramFactorySelection insert list end "ncftp"

	ComboBoxVideoCodecsFactorySelection clear
	ComboBoxVideoCodecsFactorySelection insert list end ""
	ComboBoxVideoCodecsFactorySelection insert list end "copy"
	ComboBoxVideoCodecsFactorySelection insert list end "DNxHD"
	ComboBoxVideoCodecsFactorySelection insert list end "dvcpro-hd"
	ComboBoxVideoCodecsFactorySelection insert list end "h264"
	ComboBoxVideoCodecsFactorySelection insert list end "libx264"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg1video"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg2video"
	ComboBoxVideoCodecsFactorySelection insert list end "mpeg4"
	ComboBoxVideoCodecsFactorySelection insert list end "mxf"
	ComboBoxVideoCodecsFactorySelection insert list end "xdcam"
	ComboBoxVideoCodecsFactorySelection insert list end "xvid"
	ComboBoxVideoCodecsFactorySelection insert list end "flv1"
	ComboBoxVideoCodecsFactorySelection insert list end "jpeg2000"
	ComboBoxVideoCodecsFactorySelection insert list end "mjpeg"
	ComboBoxVideoCodecsFactorySelection insert list end "wmv1"
	ComboBoxVideoCodecsFactorySelection insert list end "wmv2"
	ComboBoxVideoCodecsFactorySelection insert list end "wmv3"

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
	ComboBoxTargetFactorySelection insert list end "ntsc-dvd"
	ComboBoxTargetFactorySelection insert list end "pal-dvd"
	ComboBoxTargetFactorySelection insert list end "film-dvd"
	ComboBoxTargetFactorySelection insert list end "vcd"
	ComboBoxTargetFactorySelection insert list end "svcd"
	ComboBoxTargetFactorySelection insert list end "imx30"
	ComboBoxTargetFactorySelection insert list end "imx50"

	ComboBoxTagsFactorySelection clear
	ComboBoxTagsFactorySelection insert list end ""
	ComboBoxTagsFactorySelection insert list end "dvc"
	ComboBoxTagsFactorySelection insert list end "mp4v"
	ComboBoxTagsFactorySelection insert list end "xd5b"

	ComboBoxThreadsFactorySelection clear
	ComboBoxThreadsFactorySelection insert list end ""
	ComboBoxThreadsFactorySelection insert list end "1"
	ComboBoxThreadsFactorySelection insert list end "2"
	ComboBoxThreadsFactorySelection insert list end "4"
	ComboBoxThreadsFactorySelection insert list end "8"

	ComboBoxAspectFactorySelection clear
	ComboBoxAspectFactorySelection insert list end ""
	ComboBoxAspectFactorySelection insert list end "4:3"
	ComboBoxAspectFactorySelection insert list end "5:4"
	ComboBoxAspectFactorySelection insert list end "16:9"
	ComboBoxAspectFactorySelection insert list end "1.85:1"

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
	ComboBoxVideoPresetFactorySelection insert list end "libx264-baseline"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-default"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-faster"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-faster_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-fast"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-fast_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-fastfirstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-hq"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-ipod320"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-ipod640"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_fast"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_max"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_medium"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_slower"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_slow"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-lossless_ultrafast"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-main"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-max"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-medium"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-medium_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-normal"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-placebo"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-placebo_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slower"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slower_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slow"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slow_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-slowfirstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-ultrafast"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-ultrafast_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-veryfast"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-veryfast_firstpass"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-veryslow"
	ComboBoxVideoPresetFactorySelection insert list end "libx264-veryslow_firstpass"

	ComboBoxForceFormatFactorySelection clear
	ComboBoxForceFormatFactorySelection insert list end ""
	ComboBoxForceFormatFactorySelection insert list end "vob"

	ComboBoxAudioCodecsFactorySelection clear
	ComboBoxAudioCodecsFactorySelection insert list end ""
	ComboBoxAudioCodecsFactorySelection insert list end "copy"
	ComboBoxAudioCodecsFactorySelection insert list end "ac3"
	ComboBoxAudioCodecsFactorySelection insert list end "ac3_fixed"
	ComboBoxAudioCodecsFactorySelection insert list end "dts"
	ComboBoxAudioCodecsFactorySelection insert list end "acc"
	ComboBoxAudioCodecsFactorySelection insert list end "libfaac"
	ComboBoxAudioCodecsFactorySelection insert list end "mp2"
	ComboBoxAudioCodecsFactorySelection insert list end "mp3"
	ComboBoxAudioCodecsFactorySelection insert list end "pcm_s16le"
	ComboBoxAudioCodecsFactorySelection insert list end "flac"
	ComboBoxAudioCodecsFactorySelection insert list end "ape"
	ComboBoxAudioCodecsFactorySelection insert list end "s302m"

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
	ComboBoxAudioFileExtensionFactorySelection insert list end ".flac"
	ComboBoxAudioFileExtensionFactorySelection insert list end ".ape"

	ComboBoxAudioTagFactorySelection clear
	ComboBoxAudioTagFactorySelection insert list end ""
	ComboBoxAudioTagFactorySelection insert list end "sowt"

	ComboBoxAudioChannelsFactorySelection clear
	ComboBoxAudioChannelsFactorySelection insert list end ""
	ComboBoxAudioChannelsFactorySelection insert list end "1"
	ComboBoxAudioChannelsFactorySelection insert list end "2"
	ComboBoxAudioChannelsFactorySelection insert list end "3"
	ComboBoxAudioChannelsFactorySelection insert list end "6"

	ButtonAddLink configure -state disable
	ButtonRemoveLink configure -state disable
	ButtonAddEMail configure -state disable
	ButtonUpdateEMail configure -state disable
	ButtonRemoveEMail configure -state disable


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
	global PPref
##########################
# Free Factory variables
	global DeleteSource DeleteConversionLogs EnableFactory
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry FFMxProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType FTPDeleteAfter
	global RunFrom FactoryLinks FreeFactoryAction FactoryEnableEMail FactoryEMailNameEntry FactoryEMailAddressEntry FactoryEMailsName
	global EnableFactoryLinking FactoryEMailsAddress FactoryEMailMessage GlobalEMailMessage

	global DeleteSourceTmp DeleteConversionLogsTmp EnableFactoryTmp
	global FactoryDescriptionTmp NotifyDirectoryEntryTmp SelectedFactoryTmp OutputFileSuffixEntryTmp FFMxProgramTmp OutputDirectoryEntryTmp
	global FTPProgramTmp FTPURLEntryTmp FTPUserNameEntryTmp FTPPasswordEntryTmp FTPRemotePathEntryTmp FTPTransferTypeTmp FTPDeleteAfterTmp
	global RunFromTmp FactoryLinksTmp FreeFactoryActionTmp FactoryEnableEMailTmp FactoryEMailNameEntryTmp FactoryEMailAddressEntryTmp FactoryEMailsNameTmp
	global EnableFactoryLinkingTmp FactoryEMailsAddressTmp FactoryEMailMessageTmp

##########################
# Video and Audio variables
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

	global VideoCodecsTmp VideoWrapperTmp VideoFrameRateTmp VideoSizeTmp VideoTargetTmp VideoTagsTmp ThreadsTmp AspectTmp VideoBitRateTmp VideoPresetTmp VideoStreamIDTmp
	global GroupPicSizeEntryTmp BFramesEntryTmp FrameStrategyEntryTmp StartTimeOffsetEntryTmp ForceFormatTmp
	global AudioCodecsTmp AudioBitRateTmp AudioSampleRateTmp AudioTagTmp AudioChannelsTmp AudioStreamIDTmp AudioFileExtensionTmp

		set FactoryDescription ""
		set NotifyDirectoryEntry ""
		set OutputDirectoryEntry ""
		set OutputFileSuffixEntry ""
		set FFMxProgram $PPref(FFMxProgram)
		set RunFrom $PPref(RunFrom)
		set DeleteSource $PPref(DeleteSource)
		set DeleteConversionLogs $PPref(DeleteLogs)
		set EnableFactory $PPref(EnableFactory)
		set FreeFactoryAction $PPref(FreeFactoryAction)
		set FTPProgram ""
		set FTPURLEntry ""
		set FTPUserNameEntry ""
		set FTPPasswordEntry ""
		set FTPRemotePathEntry ""
		set FTPTransferType $PPref(FTPTransferType)
		set FTPDeleteAfter $PPref(FTPDeleteAfter)
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
		set FactoryEnableEMail $PPref(EnableEMail)
		set FactoryEMailsName ""
		set FactoryEMailsAddress ""
		set FactoryEMailMessage ""
		set EnableFactoryLinking $PPref(EnableFactoryLinking)
		set FactoryLinks ""

		set FactoryDescriptionTmp $FactoryDescription
		set NotifyDirectoryEntryTmp $NotifyDirectoryEntry
		set OutputDirectoryEntryTmp $OutputDirectoryEntry
		set OutputFileSuffixEntryTmp $OutputFileSuffixEntry
		set FFMxProgramTmp $FFMxProgram
		set RunFromTmp $RunFrom
		set FTPProgramTmp $FTPProgram
		set FTPURLEntryTmp $FTPURLEntry
		set FTPUserNameEntryTmp $FTPUserNameEntry
		set FTPPasswordEntryTmp $FTPPasswordEntry
		set FTPRemotePathEntryTmp $FTPRemotePathEntry
		set FTPTransferTypeTmp $FTPTransferType
		set FTPDeleteAfterTmp $FTPDeleteAfter
		set VideoCodecsTmp $VideoCodecs
		set VideoWrapperTmp $VideoWrapper
		set VideoFrameRateTmp $VideoFrameRate
		set VideoSizeTmp $VideoSize
		set VideoTargetTmp $VideoTarget
		set VideoTagsTmp $VideoTags
		set ThreadsTmp $Threads
		set AspectTmp $Aspect
		set VideoBitRateTmp $VideoBitRate
		set VideoPresetTmp $VideoPreset
		set VideoStreamIDTmp $VideoStreamID
		set GroupPicSizeEntryTmp $GroupPicSizeEntry
		set BFramesEntryTmp $BFramesEntry
		set FrameStrategyEntryTmp $FrameStrategyEntry
		set ForceFormatTmp $ForceFormat
		set StartTimeOffsetEntryTmp $StartTimeOffsetEntry
		set AudioCodecsTmp $AudioCodecs
		set AudioBitRateTmp $AudioBitRate
		set AudioSampleRateTmp $AudioSampleRate
		set AudioFileExtensionTmp $AudioFileExtension
		set AudioTagTmp $AudioTag
		set AudioChannelsTmp $AudioChannels
		set AudioStreamIDTmp $AudioStreamID
		set DeleteSourceTmp $DeleteSource
		set DeleteConversionLogsTmp $DeleteConversionLogs
		set EnableFactoryTmp $EnableFactory
		set FreeFactoryActionTmp $FreeFactoryAction
		set FactoryEnableEMailTmp $FactoryEnableEMail
		set FactoryEMailsNameTmp $FactoryEMailsName
		set FactoryEMailsAddressTmp $FactoryEMailsAddress
		set FactoryEMailMessageTmp $FactoryEMailMessage
		set EnableFactoryLinkingTmp $EnableFactoryLinking
		set FactoryLinksTmp $FactoryLinks
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
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

##########################
# Free Factory variables
	global DeleteSource DeleteConversionLogs EnableFactory
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry FFMxProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType FTPDeleteAfter
	global RunFrom FactoryLinks FreeFactoryAction FactoryEnableEMail FactoryEMailNameEntry FactoryEMailAddressEntry FactoryEMailsName
	global EnableFactoryLinking FactoryEMailsAddress FactoryEMailMessage

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
	puts $FileHandle "FFMXPROGRAM=[string trim $FFMxProgram]"
	puts $FileHandle "RUNFROM=[string trim $RunFrom]"
	puts $FileHandle "FTPPROGRAM=[string trim $FTPProgram]"
	puts $FileHandle "FTPURL=[string trim $FTPURLEntry]"
	puts $FileHandle "FTPUSERNAME=[string trim $FTPUserNameEntry]"
# Code to encode password
#	set PasswordChars [string length $FTPPasswordEntry]
#	set EncodedPassword ""
#	for {set x 0} {$x < $PasswordChars} {incr x} {
#		set EncodedChar  [format %c [expr [scan [string index $FTPPasswordEntry $x] %c] + 128]]
#		append EncodedPassword $EncodedChar
#	}
#	puts $FileHandle "FTPPASSWORD=[string trim $EncodedPassword]"
	puts $FileHandle "FTPPASSWORD=[string trim $FTPPasswordEntry]"
	puts $FileHandle "FTPREMOTEPATH=[string trim $FTPRemotePathEntry]"
	puts $FileHandle "FTPTRANSFERTYPE=[string trim $FTPTransferType]"
	puts $FileHandle "FTPDELETEAFTER=[string trim $FTPDeleteAfter]"
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
	puts $FileHandle "DELETESOURCE=[string trim $DeleteSource]"
	puts $FileHandle "DELETECONVERSIONLOGS=[string trim $DeleteConversionLogs]"
	puts $FileHandle "ENABLEFACTORY=[string trim $EnableFactory]"
	puts $FileHandle "FREEFRACTORYACTION=[string trim $FreeFactoryAction]"
	puts $FileHandle "ENABLEFACTORYLINKING=[string trim $EnableFactoryLinking]"
	puts $FileHandle "FACTORYLINKS=[string trim $FactoryLinks]"
	puts $FileHandle "FACTORYENABLEEMAIL=[string trim $FactoryEnableEMail]"
	puts $FileHandle "FACTORYEMAILNAME=[string trim $FactoryEMailsName]"
	puts $FileHandle "FACTORYEMAILADDRESS=[string trim $FactoryEMailsAddress]"
	puts $FileHandle "FACTORYEMAILMESSAGESTART="
	if {[string trim $FactoryEMailMessage] != ""} {
			puts $FileHandle $FactoryEMailMessage
	}
	puts $FileHandle "FACTORYEMAILMESSAGEEND"
	close $FileHandle
	set SelectedFactory ""
	InitVariables
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
		set FileHandle [open $item r]
		while {![eof $FileHandle]} {
			gets $FileHandle FactoryVar
			set EqualDelimiter [string first "=" $FactoryVar]
			if {$EqualDelimiter>0 && [string first "#" [string trim $FactoryVar]]!=0} {
				set FactoryField [string trim [string range $FactoryVar 0 [expr $EqualDelimiter - 1]]]
				set FactoryValue [string trim [string range $FactoryVar [expr $EqualDelimiter + 1] end]]
				switch $FactoryField {
					"ENABLEFACTORY" {
						if {$FactoryValue != "Yes"} {
							ScrolledListBoxFactoryFilesFactorySelection itemconfigure end -background #efefef
						}
					}
				}
			}
		}
		close $FileHandle
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
	global VideoCodecs VideoWrapper VideoFrameRate VideoSize VideoTarget VideoTags Threads Aspect VideoBitRate VideoPreset VideoStreamID
	global GroupPicSizeEntry BFramesEntry FrameStrategyEntry StartTimeOffsetEntry ForceFormat
	global AudioCodecs AudioBitRate AudioSampleRate AudioTag AudioChannels AudioStreamID AudioFileExtension

##########################
# Free Factory variables
	global DeleteSource DeleteConversionLogs EnableFactory
	global FactoryDescription NotifyDirectoryEntry SelectedFactory OutputFileSuffixEntry FFMxProgram OutputDirectoryEntry
	global FTPProgram FTPURLEntry FTPUserNameEntry FTPPasswordEntry FTPRemotePathEntry FTPTransferType FTPDeleteAfter
	global RunFrom FactoryLinks FreeFactoryAction FactoryEnableEMail FactoryEMailNameEntry FactoryEMailAddressEntry FactoryEMailsName
	global EnableFactoryLinking FactoryEMailsAddress FactoryEMailMessage

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
