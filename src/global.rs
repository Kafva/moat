fn default_cache_path() -> String {
    format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap())
}

#[derive(Debug)]
pub struct RssFeed {
    // We want an API akin to 'GET /items/<feed-id>' but Newsboat
    // only has the rss_url as a unique identifer
    // By always sorting the feeds on a specific key we could derive
    // our own feed-id but this would produce issues if the
    // `.newsboat/urls` file changes and the client has an old value
    // for which feed corresponds to which ID.
    // Thereby the API is instead 'GET /items/< rss_url | base64 >'
    rssurl: String,
    url: String, // URL to actual page
    title: String,
    lastmodified: u32 // UNIX epoch time 
}

impl RssFeed {
    pub fn new(rssurl: String, url: String, title: String, lastmodified: u32) -> RssFeed {
        RssFeed {
            rssurl,
            url,
            title,
            lastmodified
        }
    }
}

/// Uses the same sizes for attributes as defined in the schema for cache.db
#[derive(Debug)]
pub struct RssItem {
    id: u32, 
    //guid: String // str[64] 
    title: String, // str[128] 
    author: String, // str[1024]
    url: String, // str[1024]
    feedurl: String, // str[1024]
    //pubdate: DateTime 
    ////content VARCHAR(65535) NOT NULL
    unread: bool 
    //enclosure_url VARCHAR(1024)
    //enclosure_type VARCHAR(1024)
    //enqueued INTEGER(1) NOT NULL DEFAULT 0
    //flags VARCHAR(52)
    //deleted INTEGER(1) NOT NULL DEFAULT 0
    //base VARCHAR(128) NOT NULL DEFAULT ""
    //content_mime_type VARCHAR(255) NOT NULL DEFAULT ""   
}

//impl RssItem {
//    fn new(id: u32, title: String) -> RssItem {
//        RssItem {
//            id,
//            title
//        }
//    }
//}

pub struct Config {
    pub cache_path: String,
    pub verbose: bool
}

impl Config {
    pub fn new() -> Config {
        Config {
            cache_path: default_cache_path(),
            verbose: false
        } 
    }
}

