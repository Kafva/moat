//use sqlx::SqlitePool;
use sqlx::SqliteConnection;

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

pub async fn feeds(conn: &mut SqliteConnection) -> Result<Vec<RssFeed>, sqlx::Error> {
    //let _conn = pool.acquire().await?;
    let rows = sqlx::query("
        SELECT feedurl, rss_feed.url, author, SUM(unread)
        AS unread_count, COUNT(*)
        FROM rss_item JOIN rss_feed ON rss_feed.rssurl = feedurl
        GROUP BY feedurl;
        "
    ).fetch_all(conn).await?;

    log::info!("OUT {:#?}", rows.len());
    log::info!("DONE");
    let mut feed = RssFeed::default();
    feed.title = "XD".to_string();
    return Ok(vec![ feed ]);

}

