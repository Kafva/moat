#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) -f [cache.db] <feed name>"
helpStr='Removes all rows in `rss_item` and `rss_feed` releated to the feed with the provided name'

cache_path=~/.newsboat/cache.db

while getopts ":hf:" opt
do
	case $opt in
		h) exitErr "$usage\n$helpStr" ;;
		f) cache_path=$OPTARG ;;
		*) exitErr "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

[ -z "$1" ] && exitErr "$usage"

#----------------------------#
feedurl=$(echo "SELECT rssurl FROM rss_feed WHERE title = '$1' COLLATE NOCASE;" | sqlite3 $cache_path)

if [ -n "$feedurl" ]; then
	echo "DELETE FROM rss_item WHERE feedurl = '$feedurl';" | sqlite3 $cache_path
	echo "DELETE FROM rss_feed WHERE rssurl = '$feedurl';" | sqlite3 $cache_path
else
	echo "No feed matching '$1' found"
fi

