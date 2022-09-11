#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) [-n <device name>] <build|usb-install|test>"
helpStr=""
PROJECT=moat
DEVICENAME=sheep
SCHEME=Install

while getopts ":h:d:" opt
do
	case $opt in
		h) exitErr "$usage\n$helpStr" ;;
		n) DEVICENAME=$OPTARG ;; 
		*) exitErr "$usage" ;;
	esac
done


[ -z "$1" ] && exitErr "$usage"

deviceId=$(xcrun xctrace list devices | awk "/^$DEVICENAME/{print \$3}" | tr -d '[()]')

[ -z "$deviceId" ] && exitErr "No device found"

function usb-install() {
    iphoneId=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')
    [ -z "$iphoneId" ] && exitErr "No iOS device connected via USB"

    xcodebuild build -destination "id=$iphoneId" -allowProvisioningUpdates && 
    ideviceinstaller -i build/Release-iphoneos/${PROJECT}.app
}

#----------------------------#
# The easiest method for debugging is to start the app manually and then
# find the process and attach to it via Xcode (or to run it with CMD+R in Xcode)

if [ "$1" = build ]; then

	xcodebuild build -destination "id=$deviceId" \
			-allowProvisioningUpdates

elif [ "$1" = usb ]; then
	usb-install

elif [ "$1" = test ]; then
	# The ios-deploy solution currently throws an error
	#	https://developer.apple.com/forums/thread/658376
	# The [-m] flag avoids reinstalling the app and starts debugging immediatelly
	# usb-install &&
	# ios-deploy -m -b build/Release-iphoneos/${PROJECT}.app 
	
	# Using the `test` command is the quickest way of re-installing the
	# application (and can be done over pure WiFi),
	# one can have a scheme with stub tests which exits immediatelly to install using this method
	xcodebuild test \
		-scheme $SCHEME \
		-allowProvisioningUpdates \
		-configuration "Debug" \
		-destination "platform=iOS,id=$deviceId"
else
	echo "$usage"
fi
