use rocket::serde::{Serialize};
use regex::Regex;
use rocket::{Request, Data, data::FromData, data::Outcome, data::ByteUnit};
use rocket::tokio::io::AsyncReadExt;

fn default_cache_path() -> String {
    format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap())
}

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
            unread_count
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

/// Custom type for the data of POST requests to the /read endpoint 
pub struct ReadToggleData {
    pub id: u32,
    pub read: bool
}

#[derive(Debug)]
pub enum Err {}

/// To validate data recieved in the body of POST requests rocket relies
/// on an implementation of the `FromData` trait for the struct in question.   
///  https://api.rocket.rs/v0.5-rc/rocket/data/trait.FromData.html
#[rocket::async_trait]
impl<'r> FromData<'r> for ReadToggleData {
    type Error = Err; 
    
    async fn from_data(_req: &'r Request<'_>, data: Data<'r>) -> Outcome<'r, Self> {
        
        // Content exceeding 255 bytes isn't parsed
        let mut stream = data.open( "255".parse::<ByteUnit>().unwrap() );
        let mut buf = Vec::new();
        
        // Wait for the async read of the content of the body
        let _ = stream.read_to_end(&mut buf).await;
        
        // We expect the input to be on the format
        //  id=<u32>&read=<1|0>
        let id_regex    = Regex::new(r"id=(\d{1,15})").unwrap();
        let read_regex  = Regex::new(r"read=(0|1)").unwrap();
        
        let body_as_string = std::str::from_utf8(&buf)
            .expect("Failed to decode request body");
        
        Outcome::Success(
            ReadToggleData {
                // Pass the string-body to each regex and unwrap the
                // first capture group which holds the value for
                // each key
                id:   id_regex.captures(body_as_string).unwrap()
                    .get(1).unwrap().as_str()
                        .parse::<u32>().unwrap(),
                read: read_regex.captures(body_as_string).unwrap()
                    .get(1).unwrap().as_str()
                        .parse::<u32>().unwrap() > 0
            }
        )
    }
}