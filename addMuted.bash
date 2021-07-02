#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) <newsboat urls file>"
helpStr="Outputs all feeds which have a title starting with '!' from a newsboat urls file"

while getopts ":h" opt
do
	case $opt in
		h) exitErr "$usage\n$helpStr" ;;
		*) exitErr "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

[ -z "$1" ] && exitErr "$usage"

sedExec=$(which sed)
if [ $(uname) = 'Darwin' ]; then
	which gsed &> /dev/null && sedExec=$(which gsed) ||
		exitErr 'Install GNU sed (`brew install gnu-sed`)'
fi

#----------------------------#
# Format is expected to be:
#	<rss url> <alt url> [tag] <name>
# and the name is expected to always start with '!' or '~'

$sedExec -nE 's/^(https?:\/\/[-._?=/a-zA-Z0-9]+)\s+.*"!(.*)"\s?$/\1/p' $1
