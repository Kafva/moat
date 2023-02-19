use super::moat_log;
use crate::Muted;
use sqlx::SqliteConnection;

#[allow(unused)]
#[derive(Debug,Default,sqlx::FromRow)]
pub struct RssFeed {
    /// RSS url, can be used to fetch video thumbnails
    rssurl: String,
    /// URL to actual page
    url: String,
    /// Title of feed
    title: String,

    // == COMPUTED ATTRIBUTES, (not present in cache.db) ==
    
    // /// Number of unread entries
    // unread_count: u32,
    // /// Total number of entries in feed
    // total_count: u32,
    // /// Muted attribute, determined from the ~/.newsboat/urls
    // muted: bool,

    // rssurl VARCHAR(1024) PRIMARY KEY NOT NULL,  url VARCHAR(1024) NOT NULL,  title VARCHAR(1024) NOT NULL , lastmodified INTEGER(11) NOT NULL DEFAULT 0, is_rtl INTEGER(1) NOT NULL DEFAULT 0, etag VARCHAR(128) NOT NULL DEFAULT ""
}

//============================================================================//

pub async fn feeds(conn: &mut SqliteConnection, muted: &Muted) -> Result<Vec<RssFeed>, sqlx::Error> {
    let rows = sqlx::query_as::<_,RssFeed>("
        SELECT feedurl, rss_feed.url, author, SUM(unread)
        AS unread_count, COUNT(*)
        FROM rss_item JOIN rss_feed ON rss_feed.rssurl = feedurl
        GROUP BY feedurl
        ORDER BY rss_feed.rssurl IN (?), unread_count DESC;
        "
    )
    .bind(muted.entries.join(","))
    .fetch_all(conn).await?;

    for row in rows.iter() {
        moat_log!("ROW {:#?}", row);
    }

    let mut feed = RssFeed::default();
    feed.title = "XD".to_string();
    return Ok(vec![ feed ]);
}


