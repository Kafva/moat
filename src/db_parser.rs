extern crate base64;
use super::global::{RssItem, RssFeed};

// We can't have the cache.db from our laptop served constantly
// so we use a hook to automatically push it to the remoat server
// everytime newsboat is launched.
// To sync which articles have been read through the iOS client
// with the local machine we begin by always copying the cache.db 
// from the server to our main machine
// We can thus write to the cache.db through remoat and have
// changes persist 

// For YT, video thumbnails can be determined from the entries in the rssurl,
// if these are to be included we will perform this fetch client side (XML
// parsing is probably easier from there)

/// Returns the number of changed rows on success
pub fn toggle_read_status(cache_path: &str, item_id: u32, read: bool) -> Result<usize,rusqlite::Error> {
    let conn = rusqlite::Connection::open(cache_path)?;
        // The rss_item and rss_feed tables share several common fields, in this
        // statement we use the rssurl/feedurl as a unique identifer to determine
        // how many unread articles each feed has
    conn.execute("
        UPDATE rss_item
            SET unread = ?1
        WHERE id = ?2 ;", rusqlite::params![ read, item_id.to_string() ]
    )
}

pub fn get_feed_list(cache_path: &str) -> Result<Vec<RssFeed>,rusqlite::Error> {
    
    let conn = rusqlite::Connection::open(cache_path)?;
    let mut stmt = 
        // The rss_item and rss_feed tables share several common fields, in this
        // statement we use the rssurl/feedurl as a unique identifer to determine
        // how many unread articles each feed has
        conn.prepare("
        SELECT feedurl, rss_feed.url, author, SUM(unread) 
        FROM rss_item JOIN rss_feed ON rss_feed.rssurl = feedurl GROUP BY feedurl;"
    )?;
    
    // Use a lambda statement on each row to create an iterator
    // over all feed objects from the query
    let feeds_iter = stmt.query_map([], |row| {
        
        Ok(RssFeed::new(
            row.get(0)?,
            row.get(1)?,
            row.get(2)?,
            row.get(3)?,
        ))
    })?;

    // Collect all the items into a vector
    feeds_iter.collect()
}

pub fn get_items_from_feed(cache_path: &str, rssurl: &str) -> Result<Vec<RssItem>, rusqlite::Error> {
    
    let conn = rusqlite::Connection::open(cache_path)?;
    let mut stmt = 
        conn.prepare( &format!("
            SELECT id, title, author, url, pubdate, unread FROM rss_item
            WHERE feedurl = '{}';", rssurl 
        ).as_str()
    )?;
    
    // Use a lambda statement on each row to create an iterator
    // over all items returned from the query
    let items_iter = stmt.query_map([], |row| {
        
        Ok(RssItem::new(
            row.get(0)?,
            row.get(1)?,
            row.get(2)?,
            row.get(3)?,
            row.get(4)?,
            row.get(5)?,
        ))
    })?;

    
    // Collect all the items into a vector
    items_iter.collect()
}

/******* Tests **********/
// The convention is to include unit tests for functions inside a 
// `mod tests {}` block of each file and to have integration tests
// in the `tests` directory at the same level as `src`
// The cfg(test) attribute ensures that the module is only included
// when running `cargo test`
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_get_feeds() {
        
        let feeds = get_feed_list(
            &format!("{}/.newsboat/cache.db", 
                std::env::var("HOME").unwrap()
            ).as_str()
        ).unwrap();


        // NOTE that we can use the .into_iter() method instead of manually
        // defining an `impl` for next() for the class in question
        //  https://doc.rust-lang.org/rust-by-example/trait/iter.html
        assert!( feeds.into_iter().count() > 0 );
    }
    
    #[test]
    fn test_get_items() {
        
        let items = get_items_from_feed(
            &format!("{}/.newsboat/cache.db", 
                std::env::var("HOME").unwrap()
            ).as_str(),
            "https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA"
        ).unwrap();


        // NOTE that we can use the .into_iter() method instead of manually
        // defining an `impl` for next() for the class in question
        //  https://doc.rust-lang.org/rust-by-example/trait/iter.html
        assert!( items.into_iter().count() > 0 );
    }

}
















//fn test_feed() -> Result<(),rusqlite::Error> {
//    let cache_path = format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap());
//    
//    let conn = rusqlite::Connection::open(cache_path)?;
//    let mut stmt = 
//        conn.prepare("SELECT 
//            title, author, url, feedurl, unread 
//        
//        FROM rss_item WHERE author = \"VICE News\" ORDER BY pubdate ASC;")?;
//    let title_iter = stmt.query_map([], |row| {
//        Ok(RssItem {
//            id: 0,
//            // Retrieves the given column from the SELECT statement
//            title: row.get(0)?,
//            author: row.get(1)?,
//            url: row.get(2)?,
//            feedurl: row.get(3)?,
//            unread: row.get(4)?
//        })
//    })?;
//
//    for title in title_iter {
//        println!("Found {:#?}", title.unwrap());
//    }
//    Ok(())
//}

// Run `newsboat -r` and wait for it to exit to update the cache
// Unless we want to support updating a single feed we can rely entirely on running `newsboat -r`
// and parsing the cache.db

// The client will need an API to:
//  1. Fetch a list of all feeds
//  2. Fetch all items from a feed
//  Format can be really simple

//  select title from rss_item where author = "VICE News" order by pubdate asc;

// Newsboat keeps a cache.db internally with:
//  CREATE TABLE rss_feed (  
//    rssurl VARCHAR(1024) PRIMARY KEY NOT NULL
//    url VARCHAR(1024) NOT NULL
//    title VARCHAR(1024) NOT NULL , 
//    lastmodified INTEGER(11) NOT NULL DEFAULT 0,
//    is_rtl INTEGER(1) NOT NULL DEFAULT 0,
//    etag VARCHAR(128) NOT NULL DEFAULT ""
//  );
//  and...
//  CREATE TABLE rss_item (  
//      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
//      guid VARCHAR(64) NOT NULL
//      title VARCHAR(1024) NOT NULL
//      author VARCHAR(1024) NOT NULL
//      url VARCHAR(1024) NOT NULL
//      feedurl VARCHAR(1024) NOT NULL
//      pubDate INTEGER NOT NULL
//      content VARCHAR(65535) NOT NULL
//      unread INTEGER(1) NOT NULL 
//      enclosure_url VARCHAR(1024)
//      enclosure_type VARCHAR(1024)
//      enqueued INTEGER(1) NOT NULL DEFAULT 0
//      flags VARCHAR(52)
//      deleted INTEGER(1) NOT NULL DEFAULT 0
//      base VARCHAR(128) NOT NULL DEFAULT ""
//      content_mime_type VARCHAR(255) NOT NULL DEFAULT ""
//  );