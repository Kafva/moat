#!/usr/bin/env bash
die(){ printf "$1\n" >&2 ; exit 1; }
usage="usage: [DB=~/.newsboat/cache.db] $(basename $0) <feed name to prune>"

DB=${DB:-~/.newsboat/cache.db}

if [ -z "$1" ]; then
	sqlite3 $DB	<<< "SELECT DISTINCT rss_feed.title FROM rss_feed JOIN rss_item ON feedurl=rss_feed.rssurl;" 
else
	feedurl=$(sqlite3 $DB <<< "SELECT rssurl FROM rss_feed WHERE title = '$1' COLLATE NOCASE;")

	if [ -n "$feedurl" ]; then
		sqlite3 $DB <<< "DELETE FROM rss_item WHERE feedurl = '$feedurl';" 
		sqlite3 $DB <<< "DELETE FROM rss_feed WHERE rssurl = '$feedurl';"
	else
		echo "No feed matching '$1' found"
	fi
fi

