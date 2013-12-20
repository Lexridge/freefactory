################################################################################################
#               This code is licensed under the GPLv3
#    The following terms apply to all files associated with the software
#            unless explicitly disclaimed in individual files.
#
#                Copyright 2008 Tux Technology, LLC
#                               by
#                          Karl Swisher
#
#                         FileDialog.tcl
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
# Program:FileDialog.tcl
#
# User Variables:
#
#   Input to dialog:
#	FileSelectTypeList = This is for the file type filter
#	buttonImagePathFileDialog = Path to image for open/save button
#	WindowName = Window Title
#	ToolTip = Changes the tool tip depending on operation options are Open, Save, Import, Export.  Curently
#                 does not function.
#	fullDirPath = The full directory path that the dialog will start in.  Does not end with /
#
#   Output from dialog:
#       returnFilePath = The Full path including the selected file
#       returnFileName = The file name returned
#       returnFullPath = The full path including the file name.
#       fileDialogOk   = Variable indicating the file dialog action was or was not cancelled.
#
################################################################################################
proc vTclWindow.fileDialog {base} {
	global returnFilePath returnFileName returnFullPath fileDialogOk dirpath 
	global fullDirPath FileSelectTypeList ToolTip WindowName buttonImagePathFileDialog
	global screenx screeny PPref PasteOverwriteFileName fileOverwriteConfirm
	global RenameDisplay fileRename selectFileType
	global ViewTypeButton

############################################################################
############################################################################
# This positions the window on the screen.  It uses the screen size information to determine
# placement.
	set xCord [expr int(($screenx-494)/2)]
	set yCord [expr int(($screeny-313)/2)]
############################################################################
############################################################################
	if {$base == ""} {set base .fileDialog}
	if {[winfo exists $base]} {wm deiconify $base; return}
	set top $base
###################
# CREATING WIDGETS
###################
	vTcl:toplevel $top -class Toplevel -height 539 -highlightcolor black -width 794 
	wm withdraw $top
	wm focusmodel $top passive
	wm geometry $top 494x313+$xCord+$yCord; update
	wm maxsize $top 1265 994
	wm minsize $top 494 313
	wm overrideredirect $top 0
	wm resizable $top 1 1
	wm title $top "Open File..."
	vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
	bindtags $top "$top Toplevel all _TopLevel"
#################################################################################
# This is the right click release popup menu code.  This is bound to the top level of
# file dialog box.  Have tried to bind this to the listbox widget without success.
# If were able to bind to specific widgets then custom popups could be created.  If
# bound to the left side frame then a popup could be created to add additional buttons 
# of favorites. 
	bind $top <ButtonRelease-3> {
# Keep an extra line here commented out.  vTCL puts a %W in place of the path name of
# where ever the mouse is when the button is released.  This causes an error
#	set openReqPopUp [tk_popup .fileDialog.fileDialogPopUp [winfo pointerx .fileDialog] [winfo pointery .fileDialog] 0]
#
#  This popup will be displayed relative to mouse location.
		MenuPopUpFileDialog configure -foreground $PPref(color,window,fore) -background $PPref(color,window,back) -font $PPref(fonts,label) -activeforeground $PPref(color,active,fore) -activebackground $PPref(color,active,back) 
	
		set openReqPopUp [tk_popup .fileDialog.fileDialogPopUp [winfo pointerx .fileDialog] [winfo pointery .fileDialog] 0]
	}
	bind $top <Escape> {
		set returnFilePath ""
		if {[winfo exist .fileDialogProperties]} {
			destroy window .fileDialogProperties
		}
		if {[winfo exist .newDirNameReq]} {
			destroy window .newDirNameReq
		}
		if {[winfo exist .fileRename]} {
			destroy window .fileRename
		}
		destroy window .fileDialog
	}
	vTcl:FireEvent $top <<Create>>
	wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

	frame $top.frameTop -height 35 -highlightcolor black -relief raised -width 495 -border 0
	vTcl:DefineAlias "$top.frameTop" "FrameTopFileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_3_0 $top.frameTop

	label $site_3_0.lookInLabel -activebackground #f9f9f9 -activeforeground black -foreground black \
	-highlightcolor black -text "Look In:"
	vTcl:DefineAlias "$site_3_0.lookInLabel" "LabelLookInFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.lookInLabel -in $site_3_0 -anchor nw -expand 0 -fill none -side left
#########################################################################
# Start Up Level Combo Box
	::iwidgets::combobox $site_3_0.upLevelComboBox \
        -command {namespace inscope ::iwidgets::Combobox {::.fileDialog.frameTop.upLevelComboBox _addToList}} \
	-selectioncommand {
		set backLevelName $fullDirPath
		set fullDirPath [ComboBoxUpLevelFileDialog getcurselection]
		if {[string length $fullDirPath] > 1} {append fullDirPath {/}}
		if {$fullDirPath!=""} {
			set r [cd $fullDirPath]
# Redo the listbox for the new directory
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
		       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		}
	} -textbackground #fefefe -width 20
	vTcl:DefineAlias "$site_3_0.upLevelComboBox" "ComboBoxUpLevelFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.upLevelComboBox -in $site_3_0 -anchor nw -expand 1 -fill x -side left
# End Up Level Combo Box Button
#########################################################################
#########################################################################
# Start Back Level Button
	button $site_3_0.backLevelButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		if {$fullDirPath!=""} {
			set backLevelNameTmp $fullDirPath
			set fullDirPath $backLevelName
			set backLevelName $backLevelNameTmp
###################
# Run system cd command to go up a level
			set r [cd $fullDirPath]
# Replace the current with the new selected path
			ComboBoxUpLevelFileDialog delete entry 0 end
			ComboBoxUpLevelFileDialog insert entry end $fullDirPath
###################################
# Redo the file list box
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       			if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		}
	 } -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics back.gif]]
	vTcl:DefineAlias "$site_3_0.backLevelButton" "ButtonBackLevelFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.backLevelButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.backLevelButton "Back"

# End Back Level Button
#########################################################################
#########################################################################
# Start Up Level Button
    button $site_3_0.upLevelButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
		if {[expr [string last "/" $fullDirPath]] > 0} {
			set fullDirPath [string range $fullDirPath 0 [expr [string last "/" $fullDirPath] -1]]
		} else {
			set fullDirPath {/}
		}
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
###################
# Run system cd command to go up a level
		set r [cd $fullDirPath]
###################################
# Redo the file list box
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	 } -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics pgaccess uplevel.gif]]
	vTcl:DefineAlias "$site_3_0.upLevelButton" "ButtonUpLevelFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.upLevelButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.upLevelButton "Up Level"

# End Up Level Button
#########################################################################
#########################################################################
# Start New Directory Button
	button $site_3_0.newDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		global PPref
		global newDirNameName
		set newDirNameName {}
		Window show .newDirNameReq
		Window show .newDirNameReq
		widgetUpdate
		focus .newDirNameReq.entryNewDirName.lwchildsite.entry
	} -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics folder_new.gif]]
	vTcl:DefineAlias "$site_3_0.newDirButton" "ButtonNewDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.newDirButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.newDirButton "New Directory"

# End New Directory Button
#########################################################################
#########################################################################
# Start Copy Button
	button $site_3_0.copyButton -borderwidth 0 -relief flat -highlightthickness 0 \
        -activebackground #f9f9f9 -activeforeground black \
        -command {
		ButtonPasteFileDialog configure -state normal
		MenuPopUpFileDialog entryconfigure 5 -state  normal
		copyFileDialog
	} -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics editcopy.gif]]
	vTcl:DefineAlias "$site_3_0.copyButton" "ButtonCopyFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.copyButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.copyButton "Copy"

# End Copy Button
#########################################################################
#########################################################################
# Start Cut Button
	button $site_3_0.cutButton -borderwidth 0 -relief flat -highlightthickness 0  \
	-activebackground #f9f9f9 -activeforeground black \
        -command {
		ButtonPasteFileDialog configure -state normal
		MenuPopUpFileDialog entryconfigure 5 -state  normal
		cutFileDialog
	} -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics cut.gif]]
	vTcl:DefineAlias "$site_3_0.cutButton" "ButtonCutFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.cutButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.cutButton "Cut"

# End Cut Button
#########################################################################
#########################################################################
# Start Paste Button
	button $site_3_0.pasteButton -borderwidth 0 -relief flat -highlightthickness 0 \
        -activebackground #f9f9f9 -activeforeground black \
        -command {
			pasteFileDialog
	} -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics editpaste.gif]]
	vTcl:DefineAlias "$site_3_0.pasteButton" "ButtonPasteFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.pasteButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.pasteButton "Paste"

# End Paste Button
#########################################################################
#########################################################################
# Start Delete Button
# This code is the same as above.  Could maybe put into a single proc call in the future.
	button $site_3_0.deleteButton -borderwidth 0 -relief flat -highlightthickness 0 \
	-activebackground #f9f9f9 -activeforeground black -command {
		deleteFileDialog
	} -foreground black -highlightcolor black \
	-image [vTcl:image:get_image [file join / usr local  OpenBlend Pics remove.gif]] 
	vTcl:DefineAlias "$site_3_0.deleteButton" "ButtonDeleteFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_3_0.deleteButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
	balloon $site_3_0.deleteButton "Delete"
# End Delete Button
#########################################################################
#################################################################
# Start View Type Butto
	menubutton $site_3_0.viewTypeButton -borderwidth 0 -relief flat -highlightthickness 0 \
	-activebackground #f9f9f9 -activeforeground black -foreground black -height 23 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics show.gif]] \
        -indicatoron 1 -menu "$site_3_0.viewTypeButton.m" -padx 5 -pady 5 -relief raised -width 24
	vTcl:DefineAlias "$site_3_0.viewTypeButton" "MenuButtonViewFileDialog" vTcl:WidgetProc "Toplevel1" 1
	balloon $site_3_0.viewTypeButton "View Type"

	menu $site_3_0.viewTypeButton.m -activebackground #f9f9f9 -activeforeground black -foreground black -tearoff 0
	vTcl:DefineAlias "$site_3_0.viewTypeButton.m" "MenuButtonMenu1ViewFileDialog" vTcl:WidgetProc "Toplevel1" 1

###################################
# Start List menu item

	$site_3_0.viewTypeButton.m add radiobutton -value 1 -variable ViewTypeButton -command {
# global fileDisplayType
		set fileDisplayType "List"
# If previous view type was properties then get rid of that dialog box
		if {[winfo exist .fileDialogProperties]} {destroy window .fileDialogProperties}
# This one clears the listbox for the new directory
		redoFileDialogListBox

	} -label "List" -state active

# End List menu item
####################################
####################################
# Start Details menu item
	$site_3_0.viewTypeButton.m add radiobutton -value 2 -variable ViewTypeButton -command {
# global fileDisplayType
		set fileDisplayType "Details"
		if {[winfo exist .fileDialogProperties]} {destroy window .fileDialogProperties}
# This one clears the listbox for the new directory
		redoFileDialogListBox
	} -label "Details"

# End Details menu item
####################################
####################################
# Start Properties menu item

	$site_3_0.viewTypeButton.m add radiobutton -value 3 -variable ViewTypeButton -command {
		set fileDisplayType {Properties}
       		if {![winfo exist .fileDialogProperties]} {
			Window show .fileDialogProperties
			initFileDialogProperties
		}
		redoFileDialogListBox
		if {$fileNameList !=""} {
		    	set dirpathProperty [ScrolledListBoxFileViewFileDialog get [ScrolledListBoxFileViewFileDialog curselection] [ScrolledListBoxFileViewFileDialog curselection]]
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}

	} -label "Properties"
# End Properties menu item
####################################
####################################
# Start Preview menu item
#	$site_3_0.viewTypeButton.m add command -command {set fileDisplayType "Preview"} -label "Preview"
# End Preview menu item
####################################
#####################################################
# Start Arrange submenu item
# No code here yet
#	$site_3_0.viewTypeButton.m add separator \

#	$site_3_0.viewTypeButton.m add cascade -menu "$site_3_0.viewTypeButton.m.men59" -label "Arrange Icons"
#	vTcl:DefineAlias "$site_3_0.viewTypeButton.m.men59" "MenuButtonMenu2ViewFileDialog" vTcl:WidgetProc "Toplevel1" 1



#	set site_5_0 $site_3_0.viewTypeButton.m

#	menu $site_5_0.men59 -activebackground #f9f9f9 -activeforeground black -foreground black -tearoff 0
#	$site_5_0.men59 add radiobutton -value 1 -variable arrangeIconsButton -command {} -label "Name" -state active
#	$site_5_0.men59 add radiobutton -value 2 -variable arrangeIconsButton -command {} -label "Type"
#	$site_5_0.men59 add radiobutton -value 3 -variable arrangeIconsButton -command {} -label "Size" 
#	$site_5_0.men59 add radiobutton -value 4 -variable arrangeIconsButton -command {} -label "Date" 


	pack $site_3_0.viewTypeButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left

# End Arrange submenu
#########################################
# End View Type Menu Button
#########################################################################    
	menubutton $site_3_0.toolButton -borderwidth 0 -relief flat -highlightthickness 0 \
	-activebackground #f9f9f9 -activeforeground black -foreground black -height 23 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics tool2.gif]] \
        -indicatoron 1 -menu "$site_3_0.toolButton.m" -padx 5 -pady 5 -relief raised -width 24
	vTcl:DefineAlias "$site_3_0.toolButton" "MenuButtonToolFileDialog" vTcl:WidgetProc "Toplevel1" 1
	balloon $site_3_0.toolButton "Tools"

#####################################################
# This is the far right menu button that has the wrench (Tools) icon.
	menu $site_3_0.toolButton.m -activebackground #f9f9f9 -activeforeground black -foreground black -tearoff 0
	vTcl:DefineAlias "$site_3_0.toolButton.m" "MenuButtonMenu1ToolFileDialog" vTcl:WidgetProc "Toplevel1" 1

	$site_3_0.toolButton.m add command -command {
		global PPref
		Window show .findFileDialog
		Window show .findFileDialog
		widgetUpdate
###########
#  Initialize the data for the widgets
		.findFileDialog.comboboxFindFileDialog clear
		.findFileDialog.comboboxFindFileDialog delete entry 0 end
		.findFileDialog.comboboxFindFileDialog insert entry end [ComboBoxUpLevelFileDialog getcurselection]
#####################
# Use the existing cache of paths already in the top combox look in
		foreach boxinsert $upLevelComboBoxListVar {.findFileDialog.comboboxFindFileDialog insert list end $boxinsert}
		focus .findFileDialog.entryFindFileDialog
		focus .findFileDialog.entryFindFileDialog
	} -label "Find"
##############################################
# Start Delete menu item
	$site_3_0.toolButton.m add command -command {deleteFileDialog} -label "Delete"
# End Delete menu item
##############################################
##############################################
# Start Rename menu item
	$site_3_0.toolButton.m add command -command {renameFileDialog} -label "Rename"
# End Rename menu item
##############################################
##############################################
# Start Print menu item
#	$site_3_0.toolButton.m add command -command {
#		source "/usr/local/OpenBlend/bin/WidgetUpdate.tcl"
#		initPrinterDialog
#	} -label "Print"
# End Print menu item
##############################################
##############################################
# Start Add To Bookmarks menu item
	$site_3_0.toolButton.m add cascade -menu "$site_3_0.toolButton.m.men67" -command {} -label "Add To Bookmarks"
###############################################
# Start submenus for each browser.  It would be nice if Linux users had a single bookmark file
# that all browsers could access.  This would eliminate a lot of code here
#
# The actual writing to the file is done in the file dialog box.  All browser variables are
# nulled in each command because each var in the di
#
##############################################
# Start Konqueror submenu item
	set site_5_0 $site_3_0.toolButton.m

	menu $site_5_0.men67 -tearoff 0
	vTcl:DefineAlias "$site_3_0.toolButton.m.men67" "MenuButtonMenu2ToolFileDialog" vTcl:WidgetProc "Toplevel1" 1

        $site_5_0.men67 add command -command {
		set bookmarkBrowserName {Konqueror}
		set bookmarkBrowserPath $env(HOME)
		append bookmarkBrowserPath {/.kde/share/apps/konqueror/bookmarks.xml}
		if {[file exist $bookmarkBrowserPath]} {
			initBookmarksTitle
		}
	} -label "Konqueror"
# End Konqueror submenu item
##############################################
##############################################
# Start Netscape submenu item
         $site_5_0.men67 add command -command {
		set bookmarkBrowserName {Netscape}
		set bookmarkBrowserPath $env(HOME)
		append bookmarkBrowserPath {/.netscape/bookmarks.html}
		if {[file exist $bookmarkBrowserPath]} {
			initBookmarksTitle
 		}
	} -label "Netscape"
# End Netscape submenu item
##############################################
##############################################
# Start Mozilla submenu item
	$site_5_0.men67 add command -command {
		set bookmarkBrowserName "Mozilla"
		set bookmarkBrowserPath $env(HOME)
		set mozillabookmarkdefault  $env(HOME)
		set mozillabookmarkuser  $env(HOME)
		append mozillabookmarkdefault {/.mozilla/default/}
		append mozillabookmarkuser {/.mozilla/} [string range $env(HOME) [expr [string last {/} $env(HOME)] +1] end] {/}
		append mozillabookmarkdefault  [file tail [glob -nocomplain -directory $mozillabookmarkdefault *.slt]] {/bookmarks.html}
		append mozillabookmarkuser   [file tail [glob -nocomplain -directory $mozillabookmarkuser *.slt]] {/bookmarks.html}
		if {[file exist $mozillabookmarkuser]} {
			set bookmarkBrowserPath $mozillabookmarkuser
			initBookmarksTitle
		} else {
			if {[file exist $mozillabookmarkdefault]} {

				set bookmarkBrowserPath $mozillabookmarkdefault
				initBookmarksTitle
			}
		}
	} -label "Mozilla"

# End Mozilla submenu item
##############################################
##############################################
# Start Nautilus submenu item
        $site_5_0.men67 add command -command {
		set bookmarkBrowserName "Nautilus"
		set bookmarkBrowserPath $env(HOME)
		append bookmarkBrowserPath {/.nautilus/bookmarks.xml}
		if {[file exist $bookmarkBrowserPath]} {initBookmarksTitle}
	} -label "Nautilus"
# End Nautilus submenu item
##############################################
##############################################
# Start Galeon submenu item
        $site_5_0.men67 add command -command {
		set bookmarkBrowserName "Galeon"
		set bookmarkBrowserPath $env(HOME)
		append bookmarkBrowserPath {/.galeon/bookmarks.xbel}
		if {[file exist $bookmarkBrowserPath]} {initBookmarksTitle}
	} -label "Galeon"
# End Galeon submenu item
##############################################
##############################################
# Start Opera submenu item
   $site_5_0.men67 add command -command {
		set bookmarkBrowserName "Opera"
		set bookmarkBrowserPath $env(HOME)
		append bookmarkBrowserPath {/.opera/opera6.adr}
		if {[file exist $bookmarkBrowserPath]} {initBookmarksTitle}
		
	} -label "Opera"
# End Opera submenu item
##############################################
##############################################
# Start Firefox submenu item
	$site_5_0.men67 add command -command {
# Checking for Firefox  Disabled for now.  Firefox bookmarks file is automically generated and states
# do not edit !!!!
		set bookmarkBrowserName "Firefox"
		set bookmarkBrowserPath $env(HOME)
		set firefoxbookmarkdefault "$env(HOME)/.firefox/firefox/"
		append firefoxbookmarkdefault  [file tail [glob -nocomplain -directory $firefoxbookmarkdefault *.default]] "/bookmarks.html"
		if {[file exist $firefoxbookmarkdefault]} {
			set bookmarkBrowserPath $firefoxbookmarkdefault
			initBookmarksTitle
		}
	} -label "Firefox"
# End Mozilla submenu item
##############################################
# End Submenu for Add To Bookmarks
##############################################################    
#######################################
# Start Mount menu item
#
#  This code in the command for now only takes the path to /mnt.  It doesn't actualy
# mount a drive partion or share.  It is the desire eventually have mounting code
# in place of this code.
	$site_3_0.toolButton.m add command -command {
		set backLevelName $fullDirPath
		set fullDirPath {/mnt}
# cd to the directory
		set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
		set duplicateTrigger 0
		foreach tmpvar $upLevelComboBoxListVar {
                        	if {$fullDirPath == $tmpvar} {
				set duplicateTrigger 1
				break
			}
		}
		if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
			set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
			ComboBoxUpLevelFileDialog clear
			foreach tmpvar $upLevelComboBoxListVar {
				ComboBoxUpLevelFileDialog insert list end $tmpvar
               		}
		}
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -label "Mount Drive"

# End Mount menu item
#######################################
#######################################
# Start Properties menu item

	$site_3_0.toolButton.m add separator
	$site_3_0.toolButton.m add command -command {

		set fileDisplayType {Properties}
       		if {![winfo exist .fileDialogProperties]} {
			Window show .fileDialogProperties
			Window show .fileDialogProperties
			initFileDialogProperties
		}
		redoFileDialogListBox
		if {$fileNameList !=""} {
		    	set dirpathProperty [ScrolledListBoxFileViewFileDialog get [ScrolledListBoxFileViewFileDialog curselection] [ScrolledListBoxFileViewFileDialog curselection]]
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -label "Properties"
# End Properties menu item
#######################################
# End Tool Button
#################################################################
	pack $site_3_0.toolButton -in $site_3_0 -anchor nw -expand 0 -fill none -side left
############################################################################3
# Start scrolled frame on the left frame side
	pack $top.frameTop -in $top -anchor nw -expand 1 -fill x -side top


	frame $top.frameTopMaster -height 280 -highlightcolor black -relief groove -width 400  -border 0
	vTcl:DefineAlias "$top.frameTopMaster" "FrameTopMasterFileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_3_0 $top.frameTopMaster

############################################################################3
# Buttons on the left frame side
	::iwidgets::scrolledframe $site_3_0.frameLeft -background #999999 -height 599 -hscrollmode none -vscrollmode dynamic -width 86
	vTcl:DefineAlias "$site_3_0.frameLeft" "ScrolledFrameLeftFileDialog" vTcl:WidgetProc "Toplevel1" 1
	set site_8_0 [$site_3_0.frameLeft childsite]

	button $site_8_0.homeDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
		set fullDirPath $env(HOME)
# cd to the directory
		set r [cd $fullDirPath]
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
		redoFileDialogListBox
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics folder_home.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.homeDirButton" "ButtonHomeDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.homeDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.homeDirButton "Home"

	button $site_8_0.desktopDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
		set fullDirPath $env(HOME)
		append fullDirPath {/Desktop}
# cd to the directory
		set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
		set duplicateTrigger 0
		foreach tmpvar $upLevelComboBoxListVar {
                        	if {$fullDirPath == $tmpvar} {
				set duplicateTrigger 1
				break
			}
		}
		if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
			set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
			ComboBoxUpLevelFileDialog clear
			foreach tmpvar $upLevelComboBoxListVar {
				ComboBoxUpLevelFileDialog insert list end $tmpvar
               		}
		}
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics screen_green.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.desktopDirButton" "ButtonDesktopDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.desktopDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.desktopDirButton "Desktop"

	button $site_8_0.documentsDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
		set fullDirPath $env(HOME)
# Check to see if kde is used.  If so check for the default data path.
		if {[file exist $env(HOME)/.kde/share/config/kdeglobals]} {
			set FileHandle [open $env(HOME)/.kde/share/config/kdeglobals r]
			while {![eof $FileHandle]} {
				gets $FileHandle ReadLine
				if {[string trim $ReadLine]=={[Paths]}} {
					gets $FileHandle ReadLine
					set fullDirPath "$env(HOME)[string trim [string range $ReadLine [expr [string first {$HOME} $ReadLine] + 5] end]]"
					close $FileHandle
					break
				}
			}
		}
# cd to the directory
		set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
		set duplicateTrigger 0
		foreach tmpvar $upLevelComboBoxListVar {
                        	if {$fullDirPath == $tmpvar} {
				set duplicateTrigger 1
				break
			}
		}
			if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
			set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
			ComboBoxUpLevelFileDialog clear
			foreach tmpvar $upLevelComboBoxListVar {
				ComboBoxUpLevelFileDialog insert list end $tmpvar
               		}
		}
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics document.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.documentsDirButton" "ButtonDocumentsDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.documentsDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.documentsDirButton "Documents"

	button $site_8_0.floppyDirButton -borderwidth 0 -relief flat \
        -command {
		set backLevelName $fullDirPath
		set fullDirPath "/media/floppy"
		if {![file exist $fullDirPath]} {
			set fullDirPath "/mnt/floppy"
		}
		if {![file exist $fullDirPath]} {
			set fullDirPath "/mnt"
		}
# cd to the directory
		set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
		set duplicateTrigger 0
		foreach tmpvar $upLevelComboBoxListVar {
                        	if {$fullDirPath == $tmpvar} {
				set duplicateTrigger 1
				break
			}
		}
		if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
			set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
			ComboBoxUpLevelFileDialog clear
			foreach tmpvar $upLevelComboBoxListVar {
				ComboBoxUpLevelFileDialog insert list end $tmpvar
               		}
		}

# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics 3floppy_unmount.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.floppyDirButton" "ButtonFloppyDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.floppyDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.floppyDirButton "Floppy"

	button $site_8_0.cdromDirButton -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
		set fullDirPath "/media/cdrom"
		if {![file exist $fullDirPath]} {
			set fullDirPath "/mnt/cdrom"
		}
		if {![file exist $fullDirPath]} {
			set fullDirPath "/media"
		}
		if {[file exist $fullDirPath]} {
# cd to the directory
			set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
			set duplicateTrigger 0
			foreach tmpvar $upLevelComboBoxListVar {
                	        	if {$fullDirPath == $tmpvar} {
					set duplicateTrigger 1
					break
				}
			}
			if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
				set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
				ComboBoxUpLevelFileDialog clear
				foreach tmpvar $upLevelComboBoxListVar {
					ComboBoxUpLevelFileDialog insert list end $tmpvar
        			}
			}
# Replace the current with the new selected path
			ComboBoxUpLevelFileDialog delete entry 0 end
			ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       			if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		} else {
			set fullDirPath $backLevelName
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics cdrom_mount.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.cdromDirButton" "ButtonCDROMDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.cdromDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.cdromDirButton "CDROM"

	button $site_8_0.mntDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
# Set to slash now but in future will point to a newtwork path
		set fullDirPath "/mnt"
		if {[file exist $fullDirPath]} {
# cd to the directory
			set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
			set duplicateTrigger 0
			foreach tmpvar $upLevelComboBoxListVar {
	                        	if {$fullDirPath == $tmpvar} {
					set duplicateTrigger 1
					break
				}
			}
			if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
				set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
				ComboBoxUpLevelFileDialog clear
				foreach tmpvar $upLevelComboBoxListVar {
					ComboBoxUpLevelFileDialog insert list end $tmpvar
				}
			}
# Replace the current with the new selected path
			ComboBoxUpLevelFileDialog delete entry 0 end
			ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
				if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		} else {
			set fullDirPath $backLevelName
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics gnome_dev_harddisk.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.mntDirButton" "ButtonMntDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.mntDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.mntDirButton "Mount Directory"

	button $site_8_0.mediaDirButton -activebackground #f9f9f9 -activeforeground black \
        -borderwidth 0 -relief flat -highlightthickness 0 \
        -command {
		set backLevelName $fullDirPath
# Set to slash now but in future will point to a newtwork path
		set fullDirPath "/media"
		if {[file exist $fullDirPath]} {
# cd to the directory
			set r [cd $fullDirPath]
# Unable to get the unique property working.  This code
# prevents duplicates
			set duplicateTrigger 0
			foreach tmpvar $upLevelComboBoxListVar {
	                        	if {$fullDirPath == $tmpvar} {
					set duplicateTrigger 1
					break
				}
			}
			if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
				set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
				ComboBoxUpLevelFileDialog clear
				foreach tmpvar $upLevelComboBoxListVar {
					ComboBoxUpLevelFileDialog insert list end $tmpvar
				}
			}
# Replace the current with the new selected path
			ComboBoxUpLevelFileDialog delete entry 0 end
			ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# This one clears the listbox for the new directory
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
				if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		} else {
			set fullDirPath $backLevelName
		}
	} -foreground black -height 56 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics nfs_mount_kde.gif]] -width 56 
	vTcl:DefineAlias "$site_8_0.mediaDirButton" "ButtonMediaDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_8_0.mediaDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
	balloon $site_8_0.mediaDirButton "Media Directory"

#	button $site_8_0.networkDirButton -activebackground #f9f9f9 -activeforeground black \
#        -borderwidth 0 -relief flat -highlightthickness 0 \
#        -command {
#		set backLevelName $fullDirPath
## Set to slash now but in future will point to a newtwork path
#		set fullDirPath "/mnt"
#		if {[file exist $fullDirPath]} {
## cd to the directory
#			set r [cd $fullDirPath]
## Unable to get the unique property working.  This code
## prevents duplicates
#			set duplicateTrigger 0
#			foreach tmpvar $upLevelComboBoxListVar {
#	                        	if {$fullDirPath == $tmpvar} {
#					set duplicateTrigger 1
#					break
#				}
#			}
#			if {$duplicateTrigger == 0} {
## If not a duplicate then add the path to the combobox and sort it.
## Then clear the combobox and refresh it.
#				set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
#				ComboBoxUpLevelFileDialog clear
#				foreach tmpvar $upLevelComboBoxListVar {
#					ComboBoxUpLevelFileDialog insert list end $tmpvar
#				}
#			}
## Replace the current with the new selected path
#			ComboBoxUpLevelFileDialog delete entry 0 end
#			ComboBoxUpLevelFileDialog insert entry end $fullDirPath
## This one clears the listbox for the new directory
#			redoFileDialogListBox
#			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
#				if {![winfo exist .fileDialogProperties]} {
##Need to put show in twice if the window was previously destroyed
#					Window show .fileDialogProperties
#					Window show .fileDialogProperties
#					initFileDialogProperties
#				}
#				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
#				redoFileDialogProperties
#				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
#			}
#		} else {
#			set fullDirPath $backLevelName
#		}
#	} -foreground black -height 56 -highlightcolor black \
#        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics nfs_mount.gif]] -width 56 
#	vTcl:DefineAlias "$site_8_0.networkDirButton" "ButtonNetworkDirFileDialog" vTcl:WidgetProc "Toplevel1" 1
#	pack $site_8_0.networkDirButton -in $site_8_0 -anchor center -expand 1 -fill none -side top
#	balloon $site_8_0.networkDirButton "Network"


	pack $site_3_0.frameLeft -in $site_3_0 -anchor nw -expand 1 -fill y -side left

# End Left Side Frame Buttons
##########################################################################################    

	frame $site_3_0.frameFileView -height 205 -highlightcolor black -relief groove -width 413  -border 0
	vTcl:DefineAlias "$site_3_0.frameFileView" "FrameFileViewFileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_4_0 $site_3_0.frameFileView

#################################################################
# Start List Box
	::iwidgets::scrolledlistbox $site_4_0.fileViewListBox -selectmode extended -dblclickcommand {
		set selectionIndexList [ScrolledListBoxFileViewFileDialog curselection]
		set dirpath [ScrolledListBoxFileViewFileDialog get $selectionIndexList] 
# If file display type is details the strip of the beginning and ending curly brace if present
		if {$fileDisplayType=="Details" || $fileDisplayType=="Properties"} {
			if {[string index $dirpath 0] == "\{"} {
				set dirpath [string trim [string range $dirpath 1 54]]
			} else {
				set dirpath [string trim [string range $dirpath 0 53]]
			}
		}
		if {[file isdirectory $dirpath]} {
			set backLevelName $fullDirPath
#################################
# This next "if" statement is a hack work around for a problem of somehow getting double slashes
# in the path.  this strips and trims them out.
			if {[string last "//" $fullDirPath] >0} {set fullDirPath [string range $fullDirPath 0 [expr [string last "//" $fullDirPath]] -1]}
			if {[string length $fullDirPath] > 1} {
				append fullDirPath {/}
			}
#################################
# This next "if" statement is a hack work around for a problem of somehow getting double slashes
# in the path.  this strips and trims them out.
			if {[string last "//" $fullDirPath] >0} {set fullDirPath [string range $fullDirPath 0 [string last "//" $fullDirPath]]}
			append fullDirPath $dirpath
			set r [cd $fullDirPath]
# Add the directory to the list
# Unable to get the unique property working.  This code
# prevents duplicates
			set duplicateTrigger 0
			foreach tmpvar $upLevelComboBoxListVar {
                         	if {$fullDirPath == $tmpvar} {
					set duplicateTrigger 1
					break
				}
			}
			if {$duplicateTrigger == 0} {
# If not a duplicate then add the path to the combobox and sort it.
# Then clear the combobox and refresh it.
				set upLevelComboBoxListVar [lsort [lappend upLevelComboBoxListVar $fullDirPath]]
				ComboBoxUpLevelFileDialog clear
				foreach tmpvar $upLevelComboBoxListVar {ComboBoxUpLevelFileDialog insert list end $tmpvar}
			}
# Replace the current with the new selected path
			ComboBoxUpLevelFileDialog delete entry 0 end
			ComboBoxUpLevelFileDialog insert entry end $fullDirPath

# This one clears the listbox for the new directory
			redoFileDialogListBox
			if {$fileDisplayType=="Properties" && $fileNameList !=""} {
		       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
					Window show .fileDialogProperties
					Window show .fileDialogProperties
					initFileDialogProperties
				}
				set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
			}
		}
# Doouble Click on a file. This selects that file and closes the file dialog.
		if {[file isfile "$dirpath"]} {
			set returnFileName [EntryFileNameFileDialog get]
			set returnFilePath [ComboBoxUpLevelFileDialog get]
#			set returnPath [ComboBoxUpLevelFileDialog get]
			set returnFullPath $returnFilePath
			append returnFullPath "/" $returnFileName
			set fileDialogOk "Ok"
			destroy window .fileDialog

		}
	} -height 215 -hscrollmode dynamic -selectioncommand {
# Place clicked (selected)  file in entry box 
		set dirpath [ScrolledListBoxFileViewFileDialog getcurselection]
		if {$fileDisplayType=="Details"} {
			if {[string index $dirpath 0] == "\{"} {
				set dirpath [string trim [string range $dirpath 1 54]]
			} else {
				set dirpath [string trim [string range $dirpath 0 53]]
			}
		}
# The extra condition of checking for a null dirpath is needed to prevent an error when double clicked
		if {[file isfile $dirpath]} {
# Delete what is in there now
			EntryFileNameFileDialog delete 0 end
# Replace with the clicked (selected) file
			EntryFileNameFileDialog insert end [string range $dirpath [expr [string last  "/" $dirpath ] +1] end]
#			EntryFileNameFileDialog insert end $dirpath
		}
		if {$fileDisplayType=="Properties"} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set dirpathProperty $dirpath
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			foreach reFocusSelectionTmp $reFocusSelection {
				redoFileDialogProperties
				ScrolledListBoxFileViewFileDialog selection set [lindex $reFocusSelection 0] $reFocusSelectionTmp
			}
		}
	} -textbackground #fefefe -vscrollmode dynamic -width 530 
	vTcl:DefineAlias "$site_4_0.fileViewListBox" "ScrolledListBoxFileViewFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_4_0.fileViewListBox -in $site_4_0 -anchor nw -expand 1 -fill both -side bottom 

	pack $site_3_0.frameFileView -in $site_3_0 -anchor nw -expand 1 -fill both -side top

# End List Box
#################################################################

	frame $site_3_0.frameBottomMaster -height 24 -highlightcolor black -relief groove -width 430  -border 0
	vTcl:DefineAlias "$site_3_0.frameBottomMaster" "FrameBottomMasterFileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_4_0 $site_3_0.frameBottomMaster

	frame $site_4_0.frameBottomSub2 -height 40 -highlightcolor black -relief groove -width 430  -border 0
	vTcl:DefineAlias "$site_4_0.frameBottomSub2" "FrameBottomSub2FileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_5_0 $site_4_0.frameBottomSub2

	label $site_5_0.fileTypeLabel -activebackground #f9f9f9 -activeforeground black -foreground black -highlightcolor black -text "File Type:"
	vTcl:DefineAlias "$site_5_0.fileTypeLabel" "LabelFileTypeFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.fileTypeLabel -in $site_5_0 -anchor nw -expand 1 -fill none -side left

	button $site_5_0.cancelButton -activebackground #f9f9f9 -activeforeground black \
        -command {
# Window destroy .fileDialog
		set returnFileName ""
		set returnFilePath ""
		set returnFullPath ""
		set fileDialogOk "Cancel"
		if {[winfo exist .fileDialogProperties]} {destroy .fileDialogProperties}
		if {[winfo exist .newDirNameReq]} {destroy .newDirNameReq}
		if {[winfo exist .fileRename]} {destroy .fileRename}
		destroy window .fileDialog
	} -foreground black -highlightcolor black -text Cancel -width 10 
	vTcl:DefineAlias "$site_5_0.cancelButton" "ButtonCancelFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.cancelButton -in $site_5_0 -anchor nw -expand 1 -fill none -side right
	balloon $site_5_0.cancelButton "Cancel"

	::iwidgets::combobox $site_5_0.fileTypeComboBox \
        -command {namespace inscope ::iwidgets::Combobox {::.fileDialog.frameTopMaster.frameBottomMaster.frameBottomSub2.fileTypeComboBox _addToList}} \
        -selectioncommand {
########################################################################################
# File type filter selection	
		set fileSelectType [.fileDialog.frameTopMaster.frameBottomMaster.frameBottomSub2.fileTypeComboBox get]
		if {[string last "*" $fileSelectType] == [expr [string length $fileSelectType] -1]} {
			set selectFileType {*}
		} else {
			set selectFileType [string range $fileSelectType [expr [string length $fileSelectType] - 4] [expr [string length $fileSelectType] - 1]]
		}
		redoFileDialogListBox
	} -textbackground #fefefe -width 217
	vTcl:DefineAlias "$site_5_0.fileTypeComboBox" "ComboBoxFileTypeFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.fileTypeComboBox -in $site_5_0 -anchor nw -expand 1 -fill none -side left

	frame $site_4_0.frameBottomSub1 -height 40 -highlightcolor black -relief groove -width 430  -border 0
	vTcl:DefineAlias "$site_4_0.frameBottomSub1" "FrameBottomSub1FileDialog" vTcl:WidgetProc "Toplevel1" 1

	set site_5_0 $site_4_0.frameBottomSub1

	label $site_5_0.fileNameLabel -activebackground #f9f9f9 -activeforeground black -foreground black -highlightcolor black -text "File Name:"
	vTcl:DefineAlias "$site_5_0.fileNameLabel" "LabelFileNameFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.fileNameLabel -in $site_5_0 -anchor nw -expand 1 -fill none -side left
###############################################################
# Start Open Button
# This would need customized for a return of the filename to the calling procedure    
	button $site_5_0.openButton -activebackground #f9f9f9 -activeforeground black \
        -command {
		global returnFileName returnFilePath
		if {[EntryFileNameFileDialog get] != ""} {
			
			set returnFileName [EntryFileNameFileDialog get]
			set returnFilePath [ComboBoxUpLevelFileDialog get]
#			set returnPath [ComboBoxUpLevelFileDialog get]
			set returnFullPath $returnFilePath
			append returnFullPath "/" $returnFileName
			set fileDialogOk "Ok"
			destroy window .fileDialog
		}
	} -foreground black -height 26 -highlightcolor black \
        -image [vTcl:image:get_image [file join / usr local  OpenBlend Pics open.gif]] -width 92
	vTcl:DefineAlias "$site_5_0.openButton" "ButtonOpenFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.openButton -in $site_5_0 -anchor nw -expand 1 -fill none -side right
	balloon $site_5_0.openButton $ToolTip
# End Open Button
###############################################################
###############################################################
# Start File Name Entry
	entry $site_5_0.fileNameEntry -background white -foreground black -highlightcolor black \
        -insertbackground black -selectbackground #c4c4c4 -selectforeground black -textvariable "$top\::filenameentry" \
        -width 233 
	vTcl:DefineAlias "$site_5_0.fileNameEntry" "EntryFileNameFileDialog" vTcl:WidgetProc "Toplevel1" 1
	pack $site_5_0.fileNameEntry -in $site_5_0 -anchor nw -expand 1 -fill none -side left
	balloon $site_5_0.fileNameEntry "File Entry Box"

	bind $site_5_0.fileNameEntry <Key-Return> {
		if {[EntryFileNameFileDialog get] != ""} {
			set returnFileName [EntryFileNameFileDialog get]
			set returnFilePath [ComboBoxUpLevelFileDialog get]
			set returnFullPath $returnFilePath
			append returnFullPath "/" $returnFileName
			set fileDialogOk "Ok"
			destroy window .fileDialog
		}
	}
	bind $site_5_0.fileNameEntry <Key-KP_Enter> {
		if {[EntryFileNameFileDialog get] != ""} {
			set returnFileName [EntryFileNameFileDialog get]
			set returnFilePath [ComboBoxUpLevelFileDialog get]
#			set returnPath [ComboBoxUpLevelFileDialog get]
			set returnFullPath $returnFilePath
			append returnFullPath "/" $returnFileName
			set fileDialogOk "Ok"
			destroy window .fileDialog
		}
	}

	pack $site_4_0.frameBottomSub2 -in $site_4_0 -anchor nw -expand 0 -fill both -side top
	pack $site_4_0.frameBottomSub1 -in $site_4_0 -anchor nw -expand 0 -fill both -side top
	pack $site_3_0.frameBottomMaster -in $site_3_0 -anchor nw -expand 0 -fill y -side top


# End File Name Entry Box
###############################################################

#################################################################
# Start Pop Up Menu
#
# This code is also above and in the future maybe consolidated in a single proc for
# each command

	menu $top.fileDialogPopUp -activebackground #f9f9f9 -activeforeground black -background #d9d9d9 \
        -borderwidth 2 -cursor arrow -disabledforeground #a3a3a3 -foreground black -relief raised -selectcolor #b03060 -tearoff 0
	$top.fileDialogPopUp add command -command {
		set backLevelNameTmp $fullDirPath
		set fullDirPath $backLevelName
		set backLevelName $backLevelNameTmp
###################
# Run system cd command to go up a level
		set r [cd $fullDirPath]
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
###################################
# Redo the file list box
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -label "Back"
	$top.fileDialogPopUp add command -command {
		set backLevelName $fullDirPath
		if {[expr [string last "/" $fullDirPath]] > 0} {
			set fullDirPath [string range $fullDirPath 0 [expr [string last "/" $fullDirPath] -1]]
		} else {
			set fullDirPath {/}
		}
# Replace the current with the new selected path
		ComboBoxUpLevelFileDialog delete entry 0 end
		ComboBoxUpLevelFileDialog insert entry end $fullDirPath
###################
# Run system cd command to go up a level
		set r [cd $fullDirPath]
###################################
# Redo the file list box
		redoFileDialogListBox
		if {$fileDisplayType=="Properties" && $fileNameList !=""} {
	       		if {![winfo exist .fileDialogProperties]} {
#Need to put show in twice if the window was previously destroyed
				Window show .fileDialogProperties
				initFileDialogProperties
			}
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -label "Up Level"
	$top.fileDialogPopUp add command -command {
		global PPref
		global newDirNameName
		set newDirNameName {}
		Window show .newDirNameReq
		Window show .newDirNameReq
		widgetUpdate
		focus .newDirNameReq.entryNewDirName.lwchildsite.entry
	} -label "New Directory"
	$top.fileDialogPopUp add command -command {
		ButtonPasteFileDialog configure -state normal
		MenuPopUpFileDialog entryconfigure 5 -state  normal
		copyFileDialog
	} -label Copy
	$top.fileDialogPopUp add command -command {
		ButtonPasteFileDialog configure -state normal
		MenuPopUpFileDialog entryconfigure 5 -state  normal
		cutFileDialog
	} -label "Cut"
	$top.fileDialogPopUp add command -command {pasteFileDialog} -label "Paste"
	$top.fileDialogPopUp add command -command {renameFileDialog} -label "Rename"
	$top.fileDialogPopUp add command -command {deleteFileDialog} -label "Delete"
	$top.fileDialogPopUp add command -command {
		set fileDisplayType {Properties}
       		if {![winfo exist .fileDialogProperties]} {
			Window show .fileDialogProperties
			Window show .fileDialogProperties
			initFileDialogProperties
		}
		redoFileDialogListBox
		if {$fileNameList !=""} {
		    	set dirpathProperty [ScrolledListBoxFileViewFileDialog get [ScrolledListBoxFileViewFileDialog curselection] [ScrolledListBoxFileViewFileDialog curselection]]
			set reFocusSelection [ScrolledListBoxFileViewFileDialog curselection]
			redoFileDialogProperties
			ScrolledListBoxFileViewFileDialog selection set $reFocusSelection $reFocusSelection
		}
	} -label "Properties"
	vTcl:DefineAlias "$top.fileDialogPopUp" "MenuPopUpFileDialog" vTcl:WidgetProc "Toplevel1" 1
# End Pop Up Menu
#################################################################


    pack $top.frameTopMaster -in $top -anchor nw -expand 1 -fill both -side top

    vTcl:FireEvent $base <<Ready>>
}

##########################################################################################
# Start Bookmark Dialog Box

proc vTclWindow.fileDialogBookmarkTitle {base} {
    if {$base == ""} {set base .fileDialogBookmarkTitle}
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm focusmodel $top passive
    wm geometry $top 387x101+481+416; update
    wm maxsize $top 1265 994
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 0 0
    wm deiconify $top
    wm title $top "Edit Bookmark..."
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"
    bind $top <Escape> {destroy window .fileDialogBookmarkTitle}

    ::iwidgets::entryfield $top.fileDialogBookmarkTitleEntry -command {saveBookmark} -labeltext "Bookmark Title" -textbackground #fefefe
    vTcl:DefineAlias "$top.fileDialogBookmarkTitleEntry" "EntryBookmarkTitleFileDialog" vTcl:WidgetProc "Toplevel1" 1

    bind $top.fileDialogBookmarkTitleEntry <Key-KP_Enter> {saveBookmark}
    bind $top.fileDialogBookmarkTitleEntry <Key-Return> {saveBookmark}

    ::iwidgets::entryfield $top.fileDialogBookmarkPathEntry -command {saveBookmark} -labeltext "Bookmark Path" -textbackground #fefefe
    vTcl:DefineAlias "$top.fileDialogBookmarkPathEntry" "EntryBookmarkPathFileDialog" vTcl:WidgetProc "Toplevel1" 1

    bind $top.fileDialogBookmarkPathEntry <Key-KP_Enter> {saveBookmark}
    bind $top.fileDialogBookmarkPathEntry <Key-Return> {saveBookmark}

    ::iwidgets::buttonbox $top.fileDialogBookmarkButtonBox -padx 0 -pady 0
    vTcl:DefineAlias "$top.fileDialogBookmarkButtonBox" "ButtonBoxBookmarksFileDialog" vTcl:WidgetProc "Toplevel1" 1

    $top.fileDialogBookmarkButtonBox add but0 -command {saveBookmark} -text Save

    $top.fileDialogBookmarkButtonBox add but1 -command {destroy window .fileDialogBookmarkTitle} -text Cancel
    $top.fileDialogBookmarkButtonBox add but2 -command {} -text Help

    place $top.fileDialogBookmarkTitleEntry -x 15 -y 5 -width 365 -height 22 -anchor nw -bordermode ignore
    place $top.fileDialogBookmarkPathEntry -x 15 -y 30 -width 358 -height 22 -anchor nw -bordermode ignore
    place $top.fileDialogBookmarkButtonBox -x 5 -y 55 -width 378 -height 38 -anchor nw -bordermode ignore

    vTcl:FireEvent $base <<Ready>>
}
# End Bookmark Dialog Box
##########################################################################################
##########################################################################################
##########################################################################################
## Start Procedure:  initFileDialog

proc ::initFileDialog {} {
# This code initializes the file dialog box.  There are variables for adjust the background,
# foreground, textbackground, textforeground directory name and file name.  Setting the cut and copy
# triggers to 0 prohibit a past action unless there are selected files and cut or copy has been
# selected.

####################
# Declare globals
	global env
	global fullDirPath fileSelectType  FileSelectTypeList
	global fileCopyTrigger fileCutTrigger fileDisplayType itemFileName item fileCopy fileCut
	global filePaste confirmDeleteVar newDirNameName newFileName selectFileType
	global PPref
	global WindowName buttonImagePathFileDialog ToolTip upLevelComboBoxListVar dirpath
	global dirpathProperty directoryCount backLevelName
	global noChangesPermissions noChangesOwnerGroup fileLinkPath
	global bookmarkBrowserName bookmarkBrowserPath
	global caseSensitiveFind exactMatchFind recursiveFind
	global screenx screeny
	global PPref passconfig
	global ViewTypeButton
#####################
# Initalize Defaults
	set fileCopy ""
	set fileCut ""
	set filePaste ""
	set fileDisplayType "List"
	set fileCutTrigger 0
	set fileCopyTrigger 0
	set backLevelName $fullDirPath
	set selectFileType "*"
	set dirpath ""
	set ViewTypeButton 1

####################################################################
# This is not a mistake !!!  There is a problem somewhere in this code or TCL/TK
# causes an error during widget reconfigure on the file dialog when it is
# revisited after the window has been previously "x" out of.  Also there is
# a focus problem that this also clears up.  Repeated openings/closings resulted
# in the window not allways getting the focus.  This increases that.
#
#####################################################################


###################
# Configure widgets to user preferences
	set passconfig "FileDialog"
	widgetUpdate
	
######
# Try to make it smart enough to disable the menu option if not supported
# on the computer.
# Checking for Konqueror
	set konquerorbookmark "$env(HOME)/.kde/share/apps/konqueror/bookmarks.xml"
	if {![file exist $konquerorbookmark]} {
		MenuButtonMenu2ToolFileDialog entryconfigure 0 -state  disable
	}
# Checking for Mozilla
	set mozillabookmarkdefault "$env(HOME)/.mozilla/default/"
	append mozillabookmarkdefault  [file tail [glob -nocomplain -directory $mozillabookmarkdefault *.slt]] "bookmarks.html"

	set mozillabookmarkuser "$env(HOME)/.mozilla/"
	append mozillabookmarkuser [string range $env(HOME) [expr [string last {/} $env(HOME)] +1] end] "/"
	append mozillabookmarkuser [file tail [glob -nocomplain -directory $mozillabookmarkuser *.slt]] "/bookmarks.html"
	if {![file exist $mozillabookmarkdefault] && ![file exist $mozillabookmarkuser]} {
		MenuButtonMenu2ToolFileDialog entryconfigure 2 -state  disable
	}


###########
# Disable Nautilus for now.  Not able to keep bookmarks
# Nautilus unable to read its own saved bookmarks on program restart
#
# Checking for Nautilus
#	set nautilusbookmark $env(HOME)
#	append nautilusbookmark {/.nautilus/bookmarks.xml}
#	if {![file exist $nautilusbookmark]} {
 		MenuButtonMenu2ToolFileDialog entryconfigure 3 -state  disable
#	}
#############
# Checking for Galeon
	set galeonbookmark $env(HOME)
	append galeonbookmark {/.galeon/bookmarks.xbel}
	if {![file exist $galeonbookmark]} {MenuButtonMenu2ToolFileDialog entryconfigure 4 -state  disable}

#############
# Checking for Netscape
	set netscapebookmark $env(HOME)
	append netscapebookmark {/.netscape/bookmarks.html}
	if {![file exist $netscapebookmark]} {MenuButtonMenu2ToolFileDialog entryconfigure 1 -state  disable}

#############
# Checking for Opera
	set operabookmark $env(HOME)
	append operabookmark {/.opera/opera6.adr}
	if {![file exist $netscapebookmark]} {MenuButtonMenu2ToolFileDialog entryconfigure 5 -state  disable}



# Checking for Firefox  Disabled for now.  Firefox bookmarks file is automically generated and states
# do not edit !!!!
#	set firefoxbookmarkdefault "$env(HOME)/.mozilla/firefox/"
#	append firefoxbookmarkdefault  [file tail [glob -nocomplain -directory $firefoxbookmarkdefault *.default]] "/bookmarks.html"
#	if {![file exist $firefoxbookmarkdefault]} {
		MenuButtonMenu2ToolFileDialog entryconfigure 6 -state  disable
#	}

#############################
# Attempting to redo the tool tip to fit the type of dialog action, open, save, import or export.
# it seems once it is set it won't change.  Also code in the before the call the this
# routine.  The code there is commented out. The ToolTip variable is set there for each action.
	balloon .fileDialog.frameTopMaster.frameBottomMaster.frameBottomSub1.openButton  $ToolTip
	ButtonCancelFileDialog configure -foreground $PPref(color,window,fore) -background $PPref(color,window,back) -font $PPref(fonts,label)  -activeforeground $PPref(color,active,fore) -activebackground $PPref(color,active,back) 
	wm title .fileDialog $WindowName

# cd to the directory
	set r [cd $fullDirPath]
# Clear the file type combobox	
	ComboBoxFileTypeFileDialog clear
# Populate the file type combobox
	set x 0
	foreach selectTypeList $FileSelectTypeList {
		set selectTypeList2 [lindex $selectTypeList 0]
		append selectTypeList2 " " [lindex $selectTypeList 1]
		if {$x==0} {		
			ComboBoxFileTypeFileDialog delete entry 0 end
			ComboBoxFileTypeFileDialog insert entry end $selectTypeList2
		}
		set selectTypeList $selectTypeList2
		ComboBoxFileTypeFileDialog  insert list end $selectTypeList
		incr x
	}
	set fileSelectType [ComboBoxFileTypeFileDialog get]
#  Add all files to the end of the list
	ComboBoxFileTypeFileDialog insert list end "All files *"
# Check for number of items in combobox list
	set NumberOfComboBoxItems [ComboBoxFileTypeFileDialog size]
# If less than 6 then reduce the list height of the pull down
	if {$NumberOfComboBoxItems<6} {ComboBoxFileTypeFileDialog configure -listheight [expr $NumberOfComboBoxItems * 20]}
# Set select file type to all if and * appears.  Otherwise filter to only the file type.
	if {[string last "*" $fileSelectType] == [expr [string length $fileSelectType] -1]} {
		set selectFileType {*}
	} else {
		set selectFileType [string range $fileSelectType [expr [string length $fileSelectType] - 4] [expr [string length $fileSelectType] - 1]]
	}
# Here is where we load up the top combobox with the initial paths
	set upLevelComboBoxListVar {}
	lappend upLevelComboBoxListVar {/} {/home} $env(HOME) $fullDirPath {/mnt}
	ComboBoxUpLevelFileDialog clear
	 foreach tmpvar $upLevelComboBoxListVar {ComboBoxUpLevelFileDialog insert list end $tmpvar}
	ComboBoxUpLevelFileDialog delete entry 0 end
	ComboBoxUpLevelFileDialog insert entry end $fullDirPath
# Disable paste function until something is selected to paste
	ButtonPasteFileDialog configure -state disable
	MenuPopUpFileDialog entryconfigure 5 -state disable

#######################################################################################
# Display the dialog
# The following code doesn't seem to work.  No errors but it doesn't seem to always
# receive focus.
	redoFileDialogListBox
 	focus .fileDialog.frameTopMaster.frameBottomMaster.frameBottomSub1.fileNameEntry
	if {$PPref(SelectAllText) == "Yes"} {EntryFileNameFileDialog select range 0 end}
	EntryFileNameFileDialog icursor end
}
## End Procedure:  initFileDialog
########################################################################################
#############################################################################
## Procedure:  redoFileDialogListBox

proc ::redoFileDialogListBox {} {
#This clears and refills the listbox for all actions
	global PPref
	global fullDirPath fileDisplayType selectFileType PPref(color,directory) PPref(color,file) directoryCount
	global upLevelComboBoxListVar itemFileName dirpathProperty fileNameList
	global noChangesPermissions noChangesOwnerGroup fileLinkPath
	set directoryNameList {}
	set fileNameList {}
# Get everything once and filter in the loop	Previous method looped twice once for the dirs and then
# the files.  Had to do this for the filter of file types.  You always want to display the dirs and only
# filter the files.  The filter in "glob" also eliminated dirs without .ext in the name matching the filter.
# Trading a few extra cpu cycles for disk access time which I believe speeds things up.  What we are doing
# is looping through a glob list and running the file command with different options on the dir or file name.
	foreach item [lsort [glob -nocomplain *]] {
		if {$selectFileType == "*" || [file extension $item] == $selectFileType || [file isdirectory $item]} {
			if {$fileDisplayType == "Details"} {
				set fileSize [string trim [file size $item]]
				set itemFileName $item
				set fileSizeLength [string length $fileSize]
				set x [expr $fileSizeLength-1]
				set fileLinkPath {}
##########################################
# Start section - Insert the "," in as a thousand separator in file size
				if {$fileSizeLength>3} {
					set outstring {,}
					set loopCount 0
				} else {
					set outstring $fileSize
				}
				while {$x>2}  {
					set outstring1 [string range $fileSize [expr $x-2] $x]
					if {$loopCount == 0} {
						set loopCount 1
						append outstring $outstring1
					} else {
						set outstring2 {,}
						append  outstring2 $outstring1 $outstring
						set outstring $outstring2
					}
					incr x -3
				}
				if {$fileSizeLength>3} {
					set outstring1 [string range $fileSize 0 $x]
					append outstring1 $outstring
					set fileSize $outstring1
				} else {
					set fileSize $outstring
				}
# End section - Insert the "," in as a thousand separator in file size
#######################################################
#######################################################
# Start permissions conversion from number to letters
# Most of the variable name should be self explanatory
				if {[file type $item] == "link"} {
					set filePermissions [string replace $filePermissions 0 0 "l"]
					set fileLinkPath [file readlink $item]
				}
				set filePermissionsNumber [file attributes  $item -permissions]
 				set preFileAttributes [string range $filePermissionsNumber 0 [expr [string length $filePermissionsNumber] -4] ]
 				set filePermissions {-}
				if {$preFileAttributes == "040"} {
					set filePermissions [string replace $filePermissions 0 0 "d"]
				}
				set filePermissionsNumber [string range $filePermissionsNumber [expr [string length $filePermissionsNumber] -3]  end]
				foreach filePermissionsNumber2 [split $filePermissionsNumber {}] {
					switch $filePermissionsNumber2 {
						7 {append filePermissions {rwx}}
						6 {append filePermissions {rw-}}
						5 {append filePermissions {r-x}}
						4 {append filePermissions {r--}}
						3 {append filePermissions {-wx}}
						2 {append filePermissions {-w-}}
						1 {append filePermissions {--x}}
						0 {append filePermissions {---}}
					}
				}
# Check for Suid
				if {$preFileAttributes == "04"} {set filePermissions [string replace $filePermissions 3 3 "S"]}
# Check For Guid				
				if {$preFileAttributes == "02"} {set filePermissions [string replace $filePermissions 6 6 "S"]}
# Check For Sticky
				if {$preFileAttributes == "01"} {set filePermissions [string replace $filePermissions 9 9 "T"]}

# End permissions conversion from number to letters
#######################################################
				set fileTimeModified [clock format [file mtime $item]]
				set fileGroup [file attributes $item -group]
				set fileOwner [file attributes $item -owner]
############################################################################
# Start assembling the line to display in the listbox for details type list

				set itemFileName [format "%-55s %s   %s   %s     %s%s%s   %s" $itemFileName $fileSize $filePermissions $fileTimeModified $fileGroup ":"  $fileOwner $fileLinkPath]
# End assembling the line to display in the listbox for details type lis
#############################################################################
			}
###########################################
###########################################
# Display in list format
			if {$fileDisplayType == "List" || $fileDisplayType=="Properties" || $fileDisplayType=="Preview"} {set itemFileName $item}
			if {[file isdirectory $item]} {
				lappend directoryNameList $itemFileName
			} else {
				lappend fileNameList $itemFileName
			}
		}
	}
	ScrolledListBoxFileViewFileDialog clear
# Count the directories and use that number for the first file selection in the listbox.  Since
# the listbox uses zero offset for elements The number of directories will point to the first
# file in the file list
	set directoryCount 0
#	ScrolledListBoxFileViewFileDialog configure -foreground $PPref(color,directory)
	foreach itemFileName $directoryNameList {
#Put the display item in the correct list variable - directory or file
# Fill the list box with directories first
		ScrolledListBoxFileViewFileDialog insert end $itemFileName
		incr directoryCount
	}
#####################################
# Fill the list box with files next
	foreach itemFileName $fileNameList {
		ScrolledListBoxFileViewFileDialog insert end $itemFileName
	}
# This condition statement provides automatic selection of the first file in a directory on display	
	if {$fileNameList !=""} {
		ScrolledListBoxFileViewFileDialog selection set $directoryCount $directoryCount
# Delete what is in there now			
		EntryFileNameFileDialog delete 0 end
# Replace with the clicked (selected) file			
		set displayFile [ScrolledListBoxFileViewFileDialog get $directoryCount $directoryCount]
		if {$fileDisplayType=="Details" || $fileDisplayType=="Properties"} {
			if {[string index $displayFile 0] == "\{"} {
				set displayFile [string trim [string range $displayFile 1 54]]
			} else {
				set displayFile [string trim [string range $displayFile 0 53]]
			}
		}
		
			EntryFileNameFileDialog insert end [string range $displayFile [expr [string last  "/" $displayFile ] +1] end]
#		EntryFileNameFileDialog insert end $displayFile
		if {$fileDisplayType=="Properties"} {
		    set dirpathProperty [ScrolledListBoxFileViewFileDialog get $directoryCount $directoryCount]
		}
	}
# Set color for files in the listbox.
	ScrolledListBoxFileViewFileDialog configure -foreground $PPref(color,file)
# Change the color to blue for direcories
	if {$directoryCount > 0} {
		for {set x 0} {$x < $directoryCount} {incr x} {
			ScrolledListBoxFileViewFileDialog itemconfigure $x -foreground $PPref(color,directory)
		}
	}
}
## End redoFileDialogListBox
#############################################################################
#############################################################################
## Procedure:  redoFileDialogProperties

proc ::redoFileDialogProperties {} {
# This allows editing of directory or file permissions, file owner and group.  The
# apply button is ghosted until something is changed.
	global itemFileName fullDirPath dirpathProperty dirpathPropertyTmp
	global noChangesOwnerGroup noChangesPermissions


	foreach dirpathPropertyTmp $dirpathProperty {
# if there are any list separators left in the name strip them out
		if {[string first "\{" $dirpathPropertyTmp] == 0 && [string first "\}" $dirpathPropertyTmp] == -1  } {set dirpathPropertyTmp [string range $dirpathPropertyTmp 1 end]}
# Get file size
		set fileSize [string trim [file size $dirpathPropertyTmp]]
		set fileSizeLength [string length $fileSize]
		set x [expr $fileSizeLength-1]
##########################################
# Start section - Insert the "," in as a thousand separator in file size
		if {$fileSizeLength>3} {
			set outstring {,}
			set loopCount 0
		} else {
			set outstring $fileSize
		}
		while {$x>2}  {
			set outstring1 [string range $fileSize [expr $x-2] $x]
			if {$loopCount == 0} {
				set loopCount 1
				append outstring $outstring1
			} else {
				set outstring2 {,}
				append  outstring2 $outstring1 $outstring
				set outstring $outstring2
			}
			incr x -3
		}
		if {$fileSizeLength>3} {
			set outstring1 [string range $fileSize 0 $x]
			append outstring1 $outstring
			set fileSize $outstring1
		} else {
			set fileSize $outstring
		}
# End section - Insert the "," in as a thousand separator in file size
#######################################################
#######################################################
# Start permissions conversion from number to letters
# Most of the variable name should be self explanatory
		set fileTypeProperty [file type $dirpathPropertyTmp]
		set fileTimeModified [clock format [file mtime $dirpathPropertyTmp]]
		set fileTimeAccessed [clock format [file atime $dirpathPropertyTmp]]
		set fileGroup [file attributes $dirpathPropertyTmp -group]
		set fileOwner [file attributes $dirpathPropertyTmp -owner]
		set filePathType [file pathtype $dirpathPropertyTmp]
		if {$fileTypeProperty == "link"} {append fileTypeProperty " to: " [file readlink $dirpathPropertyTmp]}
		append filePathType { to: } $fullDirPath
		set fileNativeName [file nativename $dirpathPropertyTmp]
		set fullFilePath $fullDirPath
		if {$fullDirPath == "/"} {
			append fullFilePath $dirpathPropertyTmp
		} else {
			append fullFilePath {/} $dirpathPropertyTmp
		}
		set filePermissionsNumber {}
		set filePermissions {}
		set noChangesPermissions 0
		set noChangesOwnerGroup 0
		.fileDialogProperties.filePropertyButtonBox buttonconfigure 0 -state disable
		set fileAttributes [file attributes  $dirpathPropertyTmp -permissions]
		set preFileAttributes [string range $fileAttributes 0 [expr [string length $fileAttributes] -4] ]
# Check for Suid
		if {$preFileAttributes == "04"} {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertySuidCheckButton select
		} else {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertySuidCheckButton deselect
		}
# Check For Guid
		if {$preFileAttributes == "02"} {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGuidCheckButton select
		} else {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGuidCheckButton deselect
		}
# Check For Sticky
		if {$preFileAttributes == "01"} {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyStickyCheckButton select
		} else {
			.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyStickyCheckButton deselect
		}
		set fileAttributes [string range $fileAttributes [expr [string length $fileAttributes] -3]  end]
		set ownerPermissions [string range $fileAttributes  0 0]
		set groupPermissions [string range $fileAttributes  1 1]
		set otherPermissions [string range $fileAttributes  2 2]
		lappend filePermissionsNumber $ownerPermissions $groupPermissions $otherPermissions
		set whichPermissions 0
		foreach filePermissionsNumber2 $filePermissionsNumber {
# This code sets the buttons
			switch $whichPermissions {
				2 {
					switch $filePermissionsNumber2 {
						7 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton select
						}
						6 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton deselect
						}
						5 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton select
						}
						4 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton deselect
						}
						3 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton select
						}
						2 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton deselect
						}
						1 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton select
						}
						0 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOtherExecuteCheckButton deselect
						}
        				}
				}
				1 {
					switch $filePermissionsNumber2 {
				
						7 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton select
						}
						6 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton deselect
						}
						5 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton select
						}
						4 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton deselect
				
						}
						3 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton select
						}
						2 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton deselect
						}
						1 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton select
						}
						0 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupExecuteCheckButton deselect
						}
					}
				}
				0 {
					switch $filePermissionsNumber2 {
						7 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton select
						}
						6 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton deselect
						}
						5 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton select
						}
						4 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton deselect
						}
						3 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton select
						}
						2 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton select
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton deselect
						}
						1 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton select
						}
						0 {
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerReadCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerWriteCheckButton deselect
							.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerExecuteCheckButton deselect
						}

					}
				}
			}
			incr whichPermissions
		}
# End permissions
#######################################################
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFilePath delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyPathType delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileSize delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileType delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastAccessed delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastModified delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerComboBox delete entry  0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupComboBox delete entry 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyNativeFileName delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFilePath insert 0 $fullFilePath
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyPathType insert 0 $filePathType
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileSize insert 0 $fileSize
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileType insert 0 $fileTypeProperty
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastAccessed insert 0 $fileTimeModified
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastModified insert 0 $fileTimeAccessed
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyNativeFileName insert 0 $fileNativeName
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerComboBox insert entry  0 $fileOwner
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupComboBox insert entry  0 $fileGroup
	}

}
## End redoFileDialogProperties
########################################################################################
########################################################################################
## Start Procedure:  initFileDialogProperties

proc ::initFileDialogProperties {} {
# This initializes the dialog box for file properties
# Declare globals
		global fullDirPath
		global fileSelectType
		global FileSelectTypeList
		global fileDisplayType
		global itemFileName
		global item
		global selectFileType
		global PPref
		global ToolTip
		global dirpath
		global dirpathProperty
		global directoryCount
		global passconfig
		set passconfig ""
		widgetUpdate

# Clear out values
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFilePath delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyPathType delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileSize delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyFileType delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastAccessed delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameTop.fileDialogPropertyLastModified delete 0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerComboBox delete entry  0 end
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupComboBox delete entry 0 end

# load the comboboxes with the owner and group names from /etc/passwd and group.
		set ownerid [open "/etc/passwd" r]
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerComboBox delete list 0 end
    		while {![eof $ownerid]} {
			gets $ownerid ownerName
			set ownerName [string range $ownerName 0 [expr [string first ":" $ownerName] -1]]

		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyOwnerComboBox insert list end $ownerName
		}
		close $ownerid
		set groupid [open "/etc/group" r]
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupComboBox delete list 0 end
    		while {![eof $groupid]} {
			gets $groupid groupName
			set groupName [string range $groupName 0 [expr [string first ":" $groupName] -1]]
		.fileDialogProperties.filePropertyFrame.fileDialogPropertyFrameBottom.fileDialogPropertyGroupComboBox insert list end $groupName
		}
		close $groupid
	}
## End initFileDialogProperties
#############################################################################
#############################################################################
## Procedure:  initBookmarksTitle

proc ::initBookmarksTitle {} {
# This initializes the bookmarks title
# Declare globals
	global bookmarkTitle bookmarkBrowserPath bookmarkBrowserName tmppath
	global PPref passconfig
	Window show .fileDialogBookmarkTitle
	Window show .fileDialogBookmarkTitle
	set passconfig "FileDialog"
	widgetUpdate
	EntryBookmarkTitleFileDialog  delete 0 end
	EntryBookmarkPathFileDialog  delete 0 end
	EntryBookmarkPathFileDialog insert 0 [ComboBoxUpLevelFileDialog getcurselection]
	EntryBookmarkTitleFileDialog insert 0 [ComboBoxUpLevelFileDialog getcurselection]
#	EntryBookmarkTitleFileDialog configure -selectbackground $PPref(color,selection,back)
#	EntryBookmarkTitleFileDialog selection range 0 end
#	EntryBookmarkTitleFileDialog icursor end
	focus .fileDialogBookmarkTitle.fileDialogBookmarkTitleEntry.lwchildsite.entry
	if {$PPref(SelectAllText) == "Yes"} {.fileDialogBookmarkTitle.fileDialogBookmarkTitleEntry.lwchildsite.entry select range 0 end}
	.fileDialogBookmarkTitle.fileDialogBookmarkTitleEntry.lwchildsite.entry icursor end

}
## End initBookmarksTitle
#############################################################################
#############################################################################
## Procedure:  pasteFileDialog
proc ::pasteFileDialog {} {
	global fullDirPath fileCopyTrigger fileCutTrigger fileCopyCutDir fileCopyCutList fileDisplayType  newFileRename
	global PPref fileRename fileCopyCutName PasteOverwriteFileName fileOverwriteConfirm
	set newFileRename ""
	set fileOverwriteConfirm 3
	foreach  fileCopyCutName $fileCopyCutList {
		if {$fileCopyTrigger == 1 || $fileCutTrigger == 1} {
			set fileSource $fileCopyCutDir
			append fileSource {/} $fileCopyCutName
			if {$fileCopyTrigger == 1 } {
				set filePaste $fullDirPath
				append filePaste  {/} $fileCopyCutName
				if {[file exist $filePaste] && $fileOverwriteConfirm != 1} {
					set PasteOverwriteFileName "The file or directory "
					append PasteOverwriteFileName $fileCopyCutName " already exists !"
					execPasteFileExistDialog
					if {$fileOverwriteConfirm == 0 || $fileOverwriteConfirm == 1} {
						set r [file copy -force $fileSource $filePaste]
						if {$fileOverwriteConfirm == 0} {set fileOverwriteConfirm 3}
					}
					if {$fileOverwriteConfirm == 2} {
						set fileRename $filePaste
						execFileRename
						if {$newFileRename !=""} {
							if {[file exist $newFileRename]} {
								Window show .renameFileExistError
								Window show .renameFileExistError
								widgetUpdate
								tkwait visibility .renameFileExistError
								tkwait window .renameFileExistError
								execFileRename
							} else {
								set filePaste $newFileRename
								set r [file copy -force $fileSource $filePaste]
							}
						}
					}
					if {$fileOverwriteConfirm == 4} {
						break
					}
				} else {
					set r [file copy -force $fileSource $filePaste]
				}
			} else {
				if {$fileCutTrigger == 1 } {
					set fileSource $fileCopyCutDir
					append fileSource {/} $fileCopyCutName
					set filePaste $fullDirPath
					append filePaste  {/} $fileCopyCutName
					if {[file exist $filePaste] && $fileOverwriteConfirm != 1} {
						set PasteOverwriteFileName "The file or directory "
						append PasteOverwriteFileName $fileCopyCutName " already exists !"
						execPasteFileExistDialog
						if {$fileOverwriteConfirm == 0} {
							set r [file copy -force $fileSource $filePaste]
							set r [file delete -force $fileSource]
						}
						if {$fileOverwriteConfirm == 2} {
							set fileRename $filePaste
							execFileRename
							if {$newFileRename !=""} {
								if {[file exist $newFileRename]} {
								Window show .renameFileExistError
								widgetUpdate
								tkwait visibility .renameFileExistError
								tkwait window .renameFileExistError
									execFileRename
								} else {
									set filePaste $newFileRename
									set r [file copy -force $fileSource $filePaste]
								}
							}
						}
						if {$fileOverwriteConfirm == 4} {break}
					} else {
						set r [file copy -force $fileSource $filePaste]
						set r [file delete -force $fileSource]
					}
# Disable past function until something is selected to paste
					ButtonPasteFileDialog configure -state disable
					MenuPopUpFileDialog entryconfigure 5 -state disable
				}
			}
		}
	}
	if {$fileCutTrigger == 1 } {
		set fileCutTrigger 0
		set fileCopyCutList {}
	}
	EntryFileNameFileDialog delete 0 end
	redoFileDialogListBox
}

## End pasteFileDialog
#############################################################################

#############################################################################
## Procedure:  copyFileDialog

proc ::copyFileDialog {} {
	global fullDirPath fileCopyTrigger fileCutTrigger fileCopyCutDir fileCopyCutList fileDisplayType fileRename
	set fileCopyTrigger 1
	set fileCutTrigger 0
	set fileCopyCutDir $fullDirPath
	set fileCopyCutList {}
	set selectionIndexList [ScrolledListBoxFileViewFileDialog curselection]
	foreach  selectionIndex [split $selectionIndexList { }]  {
		set fileCopyCutName [ScrolledListBoxFileViewFileDialog get $selectionIndex]
		if {$fileDisplayType=="Details"} {
			if {[string index $fileCopyCutName 0] == "\{"} {
				set fileCopyCutName [string trim [string range $fileCopyCutName 1 53]]
			} else {
				set fileCopyCutName [string trim [string range $fileCopyCutName 0 54]]
			}
		}
		lappend fileCopyCutList $fileCopyCutName
	}
}
## End copyFileDialog
#############################################################################

#############################################################################
## Procedure:  cutFileDialog

proc ::cutFileDialog {} {
	global fullDirPath fileCopyTrigger fileCutTrigger fileCopyCutDir fileCopyCutList fileDisplayType
	set fileCutTrigger 1
	set fileCopyTrigger 0
	set fileCopyCutDir $fullDirPath
	set fileCopyCutList {}
	set selectionIndexList [ScrolledListBoxFileViewFileDialog curselection]
	foreach  selectionIndex [split $selectionIndexList { }]  {
		set fileCopyCutName [ScrolledListBoxFileViewFileDialog get $selectionIndex]
		if {$fileDisplayType=="Details"} {
			if {[string index $fileCopyCutName 0] == "\{"} {
				set fileCopyCutName [string trim [string range $fileCopyCutName 1 53]]
			} else {
				set fileCopyCutName [string trim [string range $fileCopyCutName 0 54]]
			}
		}
		lappend fileCopyCutList $fileCopyCutName
	}
}
## End cutFileDialog
#############################################################################

#############################################################################
## Procedure:  renameFileDialog

proc ::renameFileDialog {} {
	global fileDisplayType newFileRename fileRename
	global fullDirPath fileCopyTrigger fileCutTrigger fileCopyCutDir fileCopyCutList fileDisplayType  
	global PPref

	set selectionIndexList [ScrolledListBoxFileViewFileDialog curselection]
	foreach  selectionIndex [split $selectionIndexList { }]  {
		set fileRename [ScrolledListBoxFileViewFileDialog get $selectionIndex]
		if {$fileDisplayType=="Details"} {
			if {[string index $fileRename 0] == "\{"} {
				set fileRename [string trim [string range $fileRename 1 53]]
			} else {
				set fileRename [string trim [string range $fileRename 0 54]]
			}
		}
		execFileRename
# A double check to make sure the filename you typed in doesn't already exist.  If so
# run the rename dialog again.
		if {$newFileRename !=""} {
			if {[file exist $newFileRename]} {
				Window show .renameFileExistError
				widgetUpdate
				tkwait window .renameFileExistError
				execFileRename
			} else {
				set r [file rename $fileRename $newFileRename]
			}
		}
	}
	redoFileDialogListBox
}
## End renameFileDialog
#############################################################################
#############################################################################
## Procedure:  deleteFileDialog

proc ::deleteFileDialog {} {

	global fileDisplayType DeleteConfirmFileName fileDeleteConfirm DeleteConfirmFileName
	global PPref
	set selectionIndexList [ScrolledListBoxFileViewFileDialog curselection]
#######################
#
# Check Pregram Pref for Delete confirmations.  If Yes then run the confirm dialog box.
# If set to No then set the var to 1 to automatically delete.
	if {$PPref(ConfirmFileDeletions) == "Yes"} {
		set fileDeleteConfirm 2
	} else {
		set fileDeleteConfirm 1
	}
	foreach  selectionIndex [split $selectionIndexList { }]  {
		set fileDelete [ScrolledListBoxFileViewFileDialog get $selectionIndex]
		set DeleteConfirmFileName "Delete file or directory "
		append DeleteConfirmFileName " " $fileDelete " ?"
# If view type is details then we must strip out the file name only.
		if {$fileDisplayType=="Details"} {
# If any list separators still remain in the filename then stip them out
			if {[string index $fileDelete 0] == "\{"} {
				set fileDelete [string trim [string range $fileDelete 1 53]]
			} else {
				set fileDelete [string trim [string range $fileDelete 0 54]]
			}
		}
# This is when delete all is selected
		if {$fileDeleteConfirm == 1} {
			set r [file delete -force "$fileDelete"]
		} else {
#Here is where we confirm the delete
         		Window show .deleteFileConfirm
			Window show .deleteFileConfirm
			widgetUpdate
			tkwait window .deleteFileConfirm
			if {$fileDeleteConfirm == 0 || $fileDeleteConfirm == 1} {set r [file delete -force "$fileDelete"]}
# This is where we cancel
			if {$fileDeleteConfirm == 3} {break}
		}
	}
	EntryFileNameFileDialog delete 0 end
	redoFileDialogListBox
}
## End deleteFileDialog
#############################################################################
#############################################################################
## Procedure:  saveBookmark

proc ::saveBookmark {} {
################################
# If we make it here then there is a bookmark file for the browser.  That has already
# been check. The file is opened for read write and the file must be existing.  The data
# is put together first then the file pointer is moved just proir to the last line which contains
# the closing code for the browser bookmark file.  The beginning of this line is start of the
# writting for the new bookmark.  After the new bookmark is written the last line is written back
# and the file closed.
	global bookmarkTitle bookmarkBrowserPath bookmarkBrowserName tmppath
	set bookmarkTitle {}
	set bookmarkTitle [EntryBookmarkTitleFileDialog get]
	if {$bookmarkTitle == ""} {
		tk_messageBox -message {Don't leave title blank !}
	} else {
		set bookmarkPath [EntryBookmarkPathFileDialog get]
		set firstbookmarkline ""
		set secondbookmarkline ""
		set thirdbookmarkline ""
		set fourthbookmarkline ""
		set fifthbookmarkline ""
		set sixthbookmarkline ""
		set bookmarkid [open $bookmarkBrowserPath r+]
		if {$bookmarkBrowserName == "Konqueror"} {
			append firstbookmarkline {<bookmark icon="html" href="file:} $bookmarkPath {" >}
			append secondbookmarkline {<title>} $bookmarkTitle {</title>}
			set thirdbookmarkline {</bookmark>}
			seek $bookmarkid  -8 end
			puts $bookmarkid $firstbookmarkline
			puts $bookmarkid $secondbookmarkline
			puts $bookmarkid $thirdbookmarkline
			puts $bookmarkid {</xbel>}
			close $bookmarkid
		}
		if {$bookmarkBrowserName == "Mozilla"} {
			append firstbookmarkline {  <DT><A HREF="file://} $bookmarkPath {" ADD_DATE="} [clock seconds] {" LAST_CHARSET="UTF-8">} $bookmarkTitle {</A>}
			seek $bookmarkid  -9 end
			puts $bookmarkid $firstbookmarkline
			puts $bookmarkid {</DL><p>}
			close $bookmarkid
		}
		if {$bookmarkBrowserName == "Nautilus"} {
			append firstbookmarkline {<bookmarks><bookmark name="} $bookmarkTitle {" uri="file://} $bookmarkPath {" icon_name="gnome-fs-bookmark"/></bookmarks>}
			seek $bookmarkid  -1 end
			puts -nonewline $bookmarkid $firstbookmarkline
			close $bookmarkid
		}
		if {$bookmarkBrowserName == "Galeon"} {
			append firstbookmarkline {<bookmark icon="html" href="file:} $bookmarkPath {" >}
			append secondbookmarkline {<title>} $bookmarkTitle {</title>}
			set thirdbookmarkline {</bookmark>}
			seek $bookmarkid  -8 end
			puts $bookmarkid $firstbookmarkline
			puts $bookmarkid $secondbookmarkline
			puts $bookmarkid $thirdbookmarkline
			puts $bookmarkid {</xbel>}
			close $bookmarkid
		}
		if {$bookmarkBrowserName == "Netscape"} {
			append firstbookmarkline {  <DT><A HREF="file://} $bookmarkPath {" ADD_DATE="} [clock seconds] {" LAST_VISIT="} [clock seconds] {" LAST_MODIFIED="} [clock seconds] {">} $bookmarkTitle {</A>}
			seek $bookmarkid  -9 end
			puts $bookmarkid $firstbookmarkline
			puts $bookmarkid {</DL><p>}
			close $bookmarkid
		}
		if {$bookmarkBrowserName == "Opera"} {
# This is for Opera 6.  The order does not need set.  This puts the link in root for the
# bookmarks.  The next time the user is in Opera and clicks on the bookmark Opera will
# rewritten it's bookmark file with the correct order.
			set firstbookmarkline {#URL}
			append secondbookmarkline {NAME=} $bookmarkTitle
			append thirdbookmarkline {URL=file:/} $bookmarkPath
			append fourthbookmarkline {CREATED=} [clock seconds]
			set fifthbookmarkline {ORDER=}
			set tmppath {}
			append  tmppath [string range $bookmarkBrowserPath 0 [string last {/} $bookmarkBrowserPath]] "FileDialogTmpFile"
			set bookmarkidtmp [open $tmppath w+]
			gets $bookmarkid operaLine
			puts $bookmarkidtmp $operaLine
			gets $bookmarkid operaLine
			puts $bookmarkidtmp $operaLine
			puts $bookmarkidtmp {}
			puts $bookmarkidtmp {}
			puts $bookmarkidtmp $firstbookmarkline
			puts $bookmarkidtmp $secondbookmarkline
			puts $bookmarkidtmp $thirdbookmarkline
			puts $bookmarkidtmp $fourthbookmarkline
			puts $bookmarkidtmp $fifthbookmarkline
			while {![eof $bookmarkid]} {
				gets $bookmarkid operaLine
				puts $bookmarkidtmp $operaLine
			}
			close $bookmarkidtmp
			close $bookmarkid
			set r [file delete -force $bookmarkBrowserPath]
			set r [file rename $tmppath $bookmarkBrowserPath]
		}
		destroy window .fileDialogBookmarkTitle
	}
}

## End saveBookmark
#############################################################################

#############################################################################
# Procedure execFileRename
proc ::execFileRename {} {
	global PPref fileRename RenameDisplay screenx screeny
	set RenameDisplay $fileRename
# If window doesn't exist then show it.  If it does exist just raist it.
	if {![winfo exist .fileRename]} {	
############################################################################
############################################################################
#
# This allows the window to expand to show long path names
#
# This positions the window on the screen.  It uses the screen size information to determine
# placement.
	set strlength [string length $fileRename]
	if {$strlength>30} {
		set newXvalue [expr 300+(($strlength-30)*6)]
	} else {
		set newXvalue 300
	}
	set xCord [expr int(($screenx-$newXvalue)/2)]
	set yCord [expr int(($screeny-75)/2)]
	Window show .fileRename
	Window show .fileRename
	set NewGeom $newXvalue
	append NewGeom "x75+" $xCord "+" $yCord
	wm geometry .fileRename $NewGeom
############################################################################
	widgetUpdate
	} else {
	        raise .fileRename
	}
	EntryNewNameFileRename delete 0 end
	EntryNewNameFileRename insert end $fileRename
	focus .fileRename.entryNewFileNameFileRename.lwchildsite.entry
    	if {$PPref(SelectAllText) == "Yes"} {.fileRename.entryNewFileNameFileRename.lwchildsite.entry select range 0 end}
	.fileRename.entryNewFileNameFileRename.lwchildsite.entry icursor end
	tkwait window .fileRename
}
# End Procedure execFileRename
#############################################################################

#############################################################################
# Procedure execPasteFileExistDialog
proc ::execPasteFileExistDialog {} {
	global PPref fileRename RenameDisplay screenx screeny PasteOverwriteFileName
############################################################################
#
# This allows the window to expand to show long path names
#
# This positions the window on the screen.  It uses the screen size information to determine
# placement.
	set strlength [string length $PasteOverwriteFileName]
	if {$strlength>30} {
		set newXvalue [expr 300+(($strlength-30)*6)]
	} else {
		set newXvalue 300
	}
	set xCord [expr int(($screenx-$newXvalue)/2)]
	set yCord [expr int(($screeny-60)/2)]
	Window show .pasteFileExistDialog
	Window show .pasteFileExistDialog
#	tkwait visibility .pasteFileExistDialog	
	set NewGeom $newXvalue
	append NewGeom "x60+" $xCord "+" $yCord
	wm geometry .pasteFileExistDialog $NewGeom
	widgetUpdate
	tkwait window .pasteFileExistDialog
}

# End Procedure execPasteFileExistDialog
#############################################################################
#############################################################################
## Procedure:  findFileDialogResursiveSearch

proc ::findFileDialogResursiveSearch {} {
	global caseSensitiveFind exactMatchFind recursiveFind
	global searchPattern searchDirectory  recursiveSearchPath
	global recursiveStructure recursiveCount
	
	set findList [lsort [glob -nocomplain -directory $recursiveSearchPath $searchPattern]]
	if {$findList != ""} {foreach findListItem $findList {ScrolledListBoxFileViewFileDialog insert end $findListItem}}
	foreach item [lsort [glob -nocomplain -directory $recursiveSearchPath *]] {
		if {[file isdirectory $item]} {
			set recursiveSearchPath $item
			findFileDialogResursiveSearch
		}
	}
}
## End findFileDialogResursiveSearch
#############################################################################

