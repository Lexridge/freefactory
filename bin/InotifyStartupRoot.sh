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
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Script Name: InotifyStartupRoot.sh
# This script is created from the FreeFactory gui.
#
# Startup for Free Factory runtime video conversion software.  This script
# starts inotifywait. This script meant to be run as root from rc.local.  The
# individual process will run under the user contained in the command line.
#
# Usage:/opt/FreeFactory/bin/InotifyStartupRoot.sh
#
# Any manual edit changes may be overwritten by the Free Factory gui.
#
#
#############################################################################
su -c "inotifywait -rme close_write /video/dropbox | /opt/FreeFactory/bin/FreeFactoryNotify.sh 2>> /var/log/FreeFactory/InotifyStartupRoot.log" news5 &

exit
