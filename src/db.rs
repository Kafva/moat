use crate::Muted;
use sqlx::SqliteConnection;

#[derive(Debug,Default,sqlx::FromRow,serde::Serialize)]
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

/// Each attribute corresponds to a column in the `rss_item` table.
#[derive(Debug,Default,sqlx::FromRow,serde::Serialize)]
pub struct RssItem {
    /// Internal database ID
    id: u32,
    title: String,
    /// Corresponds to a `rss_feed.title` in a `RssFeed` object.
    author: String,
    url: String,
    pubdate: u32,
    unread: bool,
}


//============================================================================//

pub async fn feeds(conn: &mut SqliteConnection,
                   muted: &Muted) -> Result<Vec<RssFeed>, sqlx::Error> {
    let muted_entries = muted.as_quoted_csv();

    // .bind() is not supported for IN (...)
    // https://github.com/launchbadge/sqlx/blob/main/FAQ.md#how-can-i-do-a-select--where-foo-in--query
    sqlx::query_as::<_,RssFeed>(&format!("
        SELECT
            feedurl,
            rss_feed.url AS url,
            author AS title,
            SUM(unread) AS unread_count,
            COUNT(*) AS total_count,
            (feedurl IN ({})) AS muted

        FROM rss_item JOIN rss_feed ON
            rss_feed.rssurl = feedurl
        GROUP BY feedurl
        ORDER BY rss_feed.rssurl IN ({}), unread_count DESC;
        ",
        muted_entries, muted_entries))
    .fetch_all(conn).await
}

pub async fn items(conn: &mut SqliteConnection,
                   rssurl: String) -> Result<Vec<RssItem>, sqlx::Error> {
    sqlx::query_as::<_,RssItem>("
            SELECT id,
                title, author, url,
                pubDate AS pubdate,
                unread
            FROM rss_item
            WHERE feedurl = ?
            ORDER BY pubDate DESC;
        ")
    .bind(rssurl)
    .fetch_all(conn).await
}

