use sqlx::SqlitePool;
//use sqlx::SqliteConnection;

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

pub async fn feeds(pool: &SqlitePool) -> Result<Vec<RssFeed>, sqlx::Error> {
    let _conn = pool.acquire().await?;

    log::info!("DONE");
    let mut feed = RssFeed::default();
    feed.title = "XD".to_string();
    return Ok(vec![ feed ]);

}

