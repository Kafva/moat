#!/usr/bin/env bash
#==============================================================================#
get_where_clause() {
    awk 'NF {print $1}' $MOAT_DIR/urls | 
        sed -E "s/(.*)/$1 != \"\1\" AND /g" | 
        tr '\n' ' ' |
        sed -E 's/AND *$//'
}
readonly MOAT_DIR=/tmp/moat
#==============================================================================#
mkdir -p $MOAT_DIR

cp ~/.newsboat/cache.db $MOAT_DIR

cat << EOF > $MOAT_DIR/urls
https://news.ycombinator.com/rss "https://news.ycombinator.com/" "🔖" "~Hacker News"
https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA "https://www.youtube.com/channel/UCXU7XVK_2Wd6tAHYO8g9vAA/videos" "🤡" "~Preston Jacobs"
https://www.youtube.com/feeds/videos.xml?channel_id=UCtUbO6rBht0daVIOGML3c8w "https://www.youtube.com/channel/UCtUbO6rBht0daVIOGML3c8w/videos" "🤡" "~Summoning Salt"
EOF


sqlite3 $MOAT_DIR/cache.db  <<< "DELETE FROM rss_item WHERE $(get_where_clause feedurl);"
sqlite3 $MOAT_DIR/cache.db  <<< "DELETE FROM rss_feed WHERE $(get_where_clause rssurl);"

sqlite3 $MOAT_DIR/cache.db <<< 'select feedurl from rss_item;'

