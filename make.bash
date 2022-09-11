#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) [-n <device name>] <build|usb-install|test>"
helpStr=""
PROJECT=Swive
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

   # The difference between build|install is unclear
    # Remove unused function warnings since all the sqlite callbacks are listed as unused
    # [-allowProvisioningUpdates] is essential for a new provisioning profile to be created once the
    # one has expired (after 7 days)
    #   xcodebuild -showBuildSettings
    xcodebuild build -destination "id=$iphoneId" -allowProvisioningUpdates && 
    ideviceinstaller -i build/Release-iphoneos/${PROJECT}.app
}

#----------------------------#
# The easiest method for debugging is to start the app manually and then
# find the process and attach to it via Xcode (or just simply run it with the 'play' button
# in Xcode)

if [ "$1" = build ]; then

	xcodebuild build -destination "id=$deviceId" \
			-allowProvisioningUpdates

elif [ "$1" = usb ]; then
	usb-install

elif [ "$1" = test ]; then
	# The ios-deploy solution currently throws an error
	#	https://developer.apple.com/forums/thread/658376
	# The [-m] flag avoids reinstalling the app and starts debugging immediatelly
	# install &&
	# ios-deploy -m -b build/Release-iphoneos/${PROJECT}.app 
	
	# Using the `test` command is the quickest way of re-installing the
	# application (and can be done over pure WiFi),
	# one can have a scheme with stub tests which exits immediatelly to install using this method
	xcodebuild test \
		GCC_PREPROCESSOR_DEFINITIONS="DEBUG=1" \
		-scheme $SCHEME \
		-allowProvisioningUpdates \
		-configuration "Debug" \
		-destination "platform=iOS,id=$deviceId"
else
	echo "$usage"
fi
