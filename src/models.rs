use rocket::serde::{Serialize};

#[derive(Serialize, Debug)]
pub struct RssFeed {
    rssurl: String, // Can be utilised to fetch video thumbnails
    url: String,    // URL to actual page
    title: String,
    unread_count: u32 // Computed attribute, not present in cache.db
}

impl RssFeed {
    // There is an attribute named 'lastmodified' in cache.db but it seems
    // to always be set to zero
    pub fn new(rssurl: String, url: String, title: String, unread_count: u32) -> RssFeed {
        RssFeed {
            rssurl,
            url,
            title,
            unread_count,
            //total_count TODO
        }
    }
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
    //feedurl: String,  // Same as the `rss_feed.rssurl` from the source feed
    //content VARCHAR(65535) NOT NULL
    //deleted INTEGER(1) NOT NULL DEFAULT 0
    //base VARCHAR(128) NOT NULL DEFAULT ""
    //content_mime_type VARCHAR(255) NOT NULL DEFAULT ""   
}

impl RssItem {
    pub fn new(id: u32, title: String, author: String, url: String, pubdate: u32, unread: bool) -> RssItem {
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

fn default_cache_path() -> String {
    format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap())
}

pub struct Config {
    pub cache_path: String,
    pub newsboat_path: String,
    pub verbose: bool
}

impl Config {
    pub fn new() -> Config {
        Config {
            cache_path: default_cache_path(),
            verbose: false,

            #[cfg(target_os = "macos")]
            newsboat_path: "/usr/local/bin/newsboat".to_string(),
            #[cfg(target_os = "linux")]
            newsboat_path: "/usr/bin/newsboat".to_string()
        } 
    }
}