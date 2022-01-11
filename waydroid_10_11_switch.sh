#!/usr/bin/env bash

# purpose: initiate proper configs for Waydroid 10 or 11
# Will set the following depending on what is detected:
#		waydroid.active_apps=Waydroid
#		
# Then it will ask if you are using Waydroid 10 or 11 and
# make the proper anbox.conf changes for you
#
# author: Jon West [electrikjesus@gmail.com]

# Verify session type: 
# We want to use something different than just $XDG_SESSION_TYPE env variable
# So instead, we will use loginctl:
# loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
# Expected Result: Type=wayland

# Detect Compositor:

# Mutter: grep -sl mutter /proc/*/maps
isMutter=$(grep -sl mutter /proc/*/maps)
multi_windows=""
wd_active=""
#~ echo "$isMutter"

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "purpose: "
  echo "This will override configs for Waydroid (10/11) by editing"
  echo "the waydroid_base.prop found in /var/lib/waydroid/"
  echo ""
  echo "This will set the following depending on what is selected:"
  echo "	waydroid.active_apps=Waydroid"
  echo ""
  echo "Then it will ask if you are using Waydroid 10 or 11 and"
  echo "make the proper anbox.conf changes for you"
  echo ""
  echo "usage:"
  echo "Run the script, answer a few questions, done."
  echo ""
  echo "author: Jon West [electrikjesus@gmail.com]"
  echo ""
  
  exit 0
fi

FILENAME='/var/lib/waydroid/waydroid_base.prop'
I=0
for LN in $(cat $FILENAME)
do
	if [ "$LN" == "waydroid.active_apps=Waydroid" ]; then
		echo "waydroid active detected :)"
		wd_active="true"
	fi
done

if [ "$wd_active" ]; then
	read -p "active mode found. Do you want to disable it (y/n)?" choice
	case "$choice" in 
	  y|Y ) echo "yes" && sed -i '/waydroid.active_apps=Waydroid/d' /var/lib/waydroid/waydroid_base.prop;;
	  n|N ) echo "no";;
	  * ) echo "invalid";;
	esac
else
	read -p "Active mode not found. Do you want to enable 'waydroid active' mode (y/n)?" choice
	case "$choice" in 
	  y|Y ) echo "yes" && echo "waydroid.active_apps=Waydroid" >> /var/lib/waydroid/waydroid_base.prop;;
	  n|N ) echo "no";;
	  * ) echo "invalid";;
	esac
fi


read -p "Is this an Android 10 or Android 11 image (10/11)?" choice
case "$choice" in 
  10 ) echo "10" && sudo sed -i 's/aidl3/aidl2/' /etc/gbinder.d/anbox.conf && sudo sed -i 's/30/29/' /etc/gbinder.d/anbox.conf;;
  11 ) echo "11" && sudo sed -i 's/aidl2/aidl3/' /etc/gbinder.d/anbox.conf && sudo sed -i 's/29/30/' /etc/gbinder.d/anbox.conf;;
  * ) echo "invalid";;
esac

echo "All Set. Thanks for using!"
