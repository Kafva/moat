use crate::Muted;
use sqlx::SqliteConnection;

#[allow(unused)]
#[derive(Debug,Default,sqlx::FromRow)]
pub struct RssFeed {
    /// First column in urls file
    feedurl: String,
    /// Second column in urls file
    url: String,
    /// Fourth column in the urls file, prefixed with either '~' or '!' (muted).
    title: String,
    /// Number of unread entries
    unread_count: u32,
    /// Total number of entries in feed
    total_count: u32,
}

impl RssFeed {
    pub fn muted(&self) -> bool {
        self.title.starts_with("!")
    }
}

//============================================================================//

pub async fn feeds(conn: &mut SqliteConnection, muted: &Muted) -> Result<Vec<RssFeed>, sqlx::Error> {
    sqlx::query_as::<_,RssFeed>("
        SELECT 
            feedurl, 
            rss_feed.url AS url, 
            author AS title, 
            SUM(unread) AS unread_count, 
            COUNT(*) AS total_count
        FROM rss_item JOIN rss_feed ON 
            rss_feed.rssurl = feedurl
        GROUP BY feedurl
        ORDER BY rss_feed.rssurl IN (?), unread_count DESC;
        "

    )
    .bind(muted.entries.join(","))
    .fetch_all(conn).await
}


