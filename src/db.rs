use super::*;
use crate::Muted;
use sqlx::SqliteConnection;

#[allow(unused)]
#[derive(Debug,Default,sqlx::FromRow)]
pub struct RssFeed {
    /// First column in urls file
    feedurl: String,
    /// Second column in urls file
    url: String,
    /// Set based on the title for an article on a remote RSS instance,
    /// does not haft to reflect the fourth column in the urls file.
    title: String,
    /// Number of unread entries
    unread_count: u32,
    /// Total number of entries in feed
    total_count: u32,
    /// Is the feed muted (prefixed with '!' in the urls file)
    muted: bool
}


//============================================================================//

pub async fn feeds(conn: &mut SqliteConnection, muted: &Muted) -> Result<Vec<RssFeed>, sqlx::Error> {
    let muted_entries = muted.as_quoted_csv();
    moat_debug!("Muted: {:#?}", muted_entries);

    sqlx::query_as::<_,RssFeed>("
        SELECT 
            feedurl, 
            rss_feed.url AS url, 
            author AS title, 
            SUM(unread) AS unread_count, 
            COUNT(*) AS total_count,
            (feedurl IN (?)) AS muted

        FROM rss_item JOIN rss_feed ON 
            rss_feed.rssurl = feedurl
        GROUP BY feedurl
        ORDER BY rss_feed.rssurl IN (?), unread_count DESC;
        "

    )
    .bind(muted_entries.clone())
    .bind(muted_entries)
    .fetch_all(conn).await

}


