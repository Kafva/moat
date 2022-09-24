use rocket::serde::Serialize;

#[derive(Serialize, Debug)]
pub struct RssFeed {
    /// RSS url, can be used to fetch video thumbnails
    rssurl: String,
    /// URL to actual page
    url: String,    
    /// Title of feed
    title: String,

    // COMPUTED ATTRIBUTES, (not present in cache.db)

    /// Number of unread entries
    unread_count: u32, 
    /// Total number of entries in feed
    total_count: u32, 
    /// Muted attribute, determined from the ~/.newsboat/urls
    muted: bool
}

/// Largely uses the same attributes defined in the schema for cache.db
#[derive(Serialize,Debug)]
pub struct RssItem {
    id: u32,            // Used when updating the 'unread' status 
    title: String,      // Item title 
    author: String,     // Same as the `rss_feed.title` for the source feed
    url: String,        // URL to the item
    pubdate: u32,       // UNIX epoch  
    unread: bool 
}

pub struct Config {
    pub cache_path: String,
    pub newsboat_path: String,
    pub muted_list: Vec<String>
}

//============================================================================//

impl RssFeed {
    // There is an attribute named 'lastmodified' in cache.db but it seems
    // to always be set to zero
    pub fn new(rssurl: String, url: String, title: String, unread_count: 
               u32, total_count: u32, muted: bool) -> RssFeed {
        RssFeed {
            rssurl,
            url,
            title,
            unread_count,
            total_count,
            muted
        }
    }
}

impl RssItem {
    pub fn new(id: u32, title: String, author: String, url: String, 
               pubdate: u32, unread: bool) -> RssItem {
        RssItem {
            id,
            title,
            author,
            url,
            pubdate,
            unread
        }
    }
}

