use crate::Muted;
use sqlx::{SqliteConnection,Connection,ConnectOptions};
use sqlx::sqlite::SqliteConnectOptions;
use std::{env,
  str::FromStr,
};

#[derive(Debug,Default,sqlx::FromRow,serde::Serialize)]
#[cfg_attr(test, derive(serde::Deserialize))]
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
#[cfg_attr(test, derive(serde::Deserialize))]
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

/// A new connection is opened for each call. Keeping a single connection
/// permanently open prevents the database from being externally updated.
pub struct Db {
    cache_db: String
}

//============================================================================//

impl Db {
    pub fn new(cache_db: String) -> Self {
        Self { cache_db }
    }
    async fn open(&self) -> SqliteConnection {
        if env::var("RUST_LOG").unwrap_or("".to_string()) == "debug" {
            SqliteConnection::connect(&self.cache_db).await
        } else {
            SqliteConnectOptions::from_str(&self.cache_db).unwrap()
                    .disable_statement_logging().connect().await
        }.expect("Could not open database")
    }

    pub async fn update_feed(&self, feedurl: String, unread: bool)
     -> Result<bool, sqlx::Error> {
        let mut conn = self.open().await;
        let rows_affected = sqlx::query!("
            UPDATE rss_item
                SET unread = ?
            WHERE feedurl = ?
            ", unread, feedurl
        )
        .execute(&mut conn)
        .await?
        .rows_affected();

        Ok(rows_affected > 0)
    }

    pub async fn update_item(&self, id: u32, unread: bool)
     -> Result<bool, sqlx::Error> {
        let mut conn = self.open().await;
        let rows_affected = sqlx::query!("
            UPDATE rss_item
                SET unread = ?
            WHERE id = ?
            ", unread, id
        )
        .execute(&mut conn)
        .await?
        .rows_affected();

        Ok(rows_affected > 0)
    }

    pub async fn feeds(&self, muted: &Muted) -> Result<Vec<RssFeed>, sqlx::Error> {
        let mut conn = self.open().await;
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
        .fetch_all(&mut conn).await
    }

    pub async fn items(&self, rssurl: String) -> Result<Vec<RssItem>, sqlx::Error> {
        let mut conn = self.open().await;
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
        .fetch_all(&mut conn).await
    }
}


