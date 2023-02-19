use sqlx::SqlitePool;

#[allow(unused)]
#[derive(Debug,Default)]
pub struct RssFeed {
    /// RSS url, can be used to fetch video thumbnails
    rssurl: String,
    /// URL to actual page
    url: String,
    /// Title of feed
    title: String,

    // == COMPUTED ATTRIBUTES, (not present in cache.db) ==
    
    /// Number of unread entries
    unread_count: u32,
    /// Total number of entries in feed
    total_count: u32,
    /// Muted attribute, determined from the ~/.newsboat/urls
    muted: bool,
}

//============================================================================//

pub async fn feed_list(pool: &SqlitePool) -> Result<Vec<RssFeed>, sqlx::Error> {
    let _conn = pool.acquire().await?;

    return Ok(vec![ RssFeed::default() ]);

}

