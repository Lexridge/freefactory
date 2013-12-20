#!/bin/bash
#  Script Name: InotifyStartup.sh
#  MJPEG-Conversion startup for Free Factory by Jim Hines modified by Karl Swisher
#  This script starts inotifywait. This script is what should be run
#  either from the command line, rc.local or as a service.

#  ToDo:
#  Make so multiple directory parents can be monitored. Done either by makeing the
#  monitored directory parameter a variable and running additional instances of this
#  script or by modifying this file to add additional instances of inotifywait here.

inotifywait -rme close_write /opt/FreeFactory/NotifyVideo | /opt/FreeFactory/bin/FreeFactoryNotify.sh 
exit

