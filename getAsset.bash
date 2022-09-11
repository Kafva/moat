#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) [-l] [-a <Path to Assets.xcassets>] <image>"
helpStr="\nThe scripts accepts an arbitrary image and produces an imageset (under Assets.xcassets) for Xcode.\nIf [-l] is passed a launch screen is produced"
PROJECT=$(basename $PWD)
assetDir=./$PROJECT/Assets.xcassets

while getopts ":hla:" opt
do
	case $opt in
		h) exitErr "$usage\n$helpStr" ;;
		l) launchScreen=1 ;;
		a) [ -d $OPTARG ] && assetDir=$OPTARG || exitErr "Directory not found -- $OPTARG" ;;
		*) exitErr "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

[ -f "$1" ] || exitErr "$usage"
[ -d "$assetDir" ] || exitErr "Missing folder -- $assetDir"
grep -iq "\.gif$" <(printf $1) && exitErr "GIF images are not accepted\n$usage"

image=$1

#----------------------------#
# For AppIcon imagesets use: https://appicon.co/#app-icon
# The scripts accepts an arbitrary image type and produces pngs

if [ -z "$launchScreen" ]; then
	# PLAIN IMAGE SET
	# Create directory for imageset
	imageSetDir="${assetDir}/$(basename $image | sed 's/\.[0-9A-z]\{1,5\}$//').imageset"


	[ -d "$imageSetDir" ] && exitErr "Folder already exists -- $imageSetDir" 
	mkdir $imageSetDir

	# Use magick to identify size and scale 2x and 3x
	width=$(magick identify $image | awk '{print $3}' | grep -o "^[0-9]\{1,\}")
	height=$(magick identify $image | awk '{print $3}' | grep -o "[0-9]\{1,\}$")

	convert $image -resize $(($width*2))x$(($height*2)) $imageSetDir/$(echo $(basename $image) | sed "s/\./@2x./; s/\.[0-9A-z]\{1,5\}$/.png/") 
	convert $image -resize $(($width*3))x$(($height*3)) $imageSetDir/$(echo $(basename $image) | sed "s/\./@3x./; s/\.[0-9A-z]\{1,5\}$/.png/")
	convert $image $imageSetDir/$(echo $(basename $image) | sed 's/\.[0-9A-z]\{1,5\}$/.png/')

	# Create the Contents.json file for the imageset
	echo "{
	\"images\" : [
	{
	\"filename\" : \"$(basename $image)\",
	\"idiom\" : \"universal\",
	\"scale\" : \"1x\"
	},
	{
	\"filename\" : \"$(basename ${image//.png/})@2x.png\",
	\"idiom\" : \"universal\",
	\"scale\" : \"2x\"
	},
	{
	\"filename\" : \"$(basename ${image//.png/})@3x.png\",
	\"idiom\" : \"universal\",
	\"scale\" : \"3x\"
	}
	],
	\"info\" : {
	\"author\" : \"xcode\",
	\"version\" : 1
	}
	}" > $imageSetDir/Contents.json
else
	# LAUNCH IMAGE SET
	DIR=LaunchImage.launchimage
	mkdir $imageSetDir
	convert $image -resize 1024x768 $imageSetDir/Default1024x768.png   
	convert $image -resize 1125x2436 $imageSetDir/Default1125x2436.png
	convert $image -resize 12424x2208 $imageSetDir/Default1242x2208.png
	convert $image -resize 1536x2048 $imageSetDir/Default1536x2048.png
	convert $image -resize 1920x1080 $imageSetDir/Default1920x1080.png
	convert $image -resize 2048x1536 $imageSetDir/Default2048x1536.png
	convert $image -resize 2208x1242 $imageSetDir/Default2208x1242.png
	convert $image -resize 2436x1125 $imageSetDir/Default2436x1125.png
	convert $image -resize 320x480 $imageSetDir/Default320x480.png
	convert $image -resize 3840x2160 $imageSetDir/Default3840x2160.png
	convert $image -resize 640x1136 $imageSetDir/Default640x1136.png
	convert $image -resize 640x960 $imageSetDir/Default640x960.png
	convert $image -resize 750x1334 $imageSetDir/Default750x1334.png
	convert $image -resize 768x1024 $imageSetDir/Default768x1024.png

	echo "{
	\"images\" : [
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1125x2436.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"11.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"3x\",
	\"subtype\" : \"2436h\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default2436x1125.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"11.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"3x\",
	\"subtype\" : \"2436h\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default3840x2160.png\",
	\"idiom\" : \"tv\",
	\"minimum-system-version\" : \"11.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1920x1080.png\",
	\"idiom\" : \"tv\",
	\"minimum-system-version\" : \"9.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1242x2208.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"8.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"3x\",
	\"subtype\" : \"736h\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default2208x1242.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"8.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"3x\",
	\"subtype\" : \"736h\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default750x1334.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"8.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\",
	\"subtype\" : \"667h\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default640x960.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default640x1136.png\",
	\"idiom\" : \"iphone\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\",
	\"subtype\" : \"retina4\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default768x1024.png\",
	\"idiom\" : \"ipad\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1024x768.png\",
	\"idiom\" : \"ipad\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1536x2048.png\",
	\"idiom\" : \"ipad\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default2048x1536.png\",
	\"idiom\" : \"ipad\",
	\"minimum-system-version\" : \"7.0\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default320x480.png\",
	\"idiom\" : \"iphone\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default640x960.png\",
	\"idiom\" : \"iphone\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default640x1136.png\",
	\"idiom\" : \"iphone\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\",
	\"subtype\" : \"retina4\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default768x1024.png\",
	\"idiom\" : \"ipad\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1024x768.png\",
	\"idiom\" : \"ipad\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"1x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default1536x2048.png\",
	\"idiom\" : \"ipad\",
	\"orientation\" : \"portrait\",
	\"scale\" : \"2x\"
	},
	{
	\"extent\" : \"full-screen\",
	\"filename\" : \"Default2048x1536.png\",
	\"idiom\" : \"ipad\",
	\"orientation\" : \"landscape\",
	\"scale\" : \"2x\"
	}
	],
	\"info\" : {
	\"author\" : \"xcode\",
	\"version\" : 1
	}
	}
	" > $imageSetDir/Contents.json
fi
