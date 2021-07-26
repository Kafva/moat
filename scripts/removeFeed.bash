#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) -f [cache.db] [-l] <feed name>"
helpStr='Removes all rows in `rss_item` and `rss_feed` releated to the feed with the provided name. The [-l] option lists all existing feed names'

cache_path=~/.newsboat/cache.db

while getopts ":hf:l" opt
do
	case $opt in
		h) exitErr "$usage\n$helpStr" ;;
		l) list_titles=1 ;;
		f) cache_path=$OPTARG ;;
		*) exitErr "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

#----------------------------#

if [ -n "$list_titles" ]; then
	echo "SELECT DISTINCT rss_feed.title FROM rss_feed JOIN rss_item ON feedurl=rss_feed.rssurl;" | sqlite3 $cache_path	

elif [ -n "$1" ]; then
	feedurl=$(echo "SELECT rssurl FROM rss_feed WHERE title = '$1' COLLATE NOCASE;" | sqlite3 $cache_path)

	if [ -n "$feedurl" ]; then
		echo "DELETE FROM rss_item WHERE feedurl = '$feedurl';" | sqlite3 $cache_path
		echo "DELETE FROM rss_feed WHERE rssurl = '$feedurl';" | sqlite3 $cache_path
	else
		echo "No feed matching '$1' found"
	fi
else
	echo "$usage"
fi


