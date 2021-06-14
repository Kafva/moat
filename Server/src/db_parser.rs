use chrono::{DateTime, Utc};

#[derive(Debug)]
struct RssFeed {
    rss_url: String,
    url: String,
    title: String,
    lastmodified: DateTime::<Utc>
}

/// Uses the same sizes for attributes as defined in the schema for cache.db
#[derive(Debug)]
struct RssItem {
    id: u32, 
    //guid: String // str[64] 
    title: String, // str[128] 
    author: String, // str[1024]
    url: String, // str[1024]
    feedurl: String // str[1024]
    //pubdate: DateTime 
    ////content VARCHAR(65535) NOT NULL
    //unread: bool 
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

//fn get_feed_list() -> Result<(),rusqlite::Error> {
//    
//}

#[test]
fn test_feed() -> Result<(),rusqlite::Error> {
    let cache_path = format!("{}/.newsboat/cache.db", std::env::var("HOME").unwrap());
    
    let conn = rusqlite::Connection::open(cache_path)?;
    let mut stmt = 
        conn.prepare("SELECT 
            title, author, url, feedurl 
        
        FROM rss_item WHERE author = \"VICE News\" ORDER BY pubdate ASC;")?;
    let title_iter = stmt.query_map([], |row| {
        Ok(RssItem {
            id: 0,
            // Retrieves the given column from the SELECT statement
            title: row.get(0)?,
            author: row.get(1)?,
            url: row.get(2)?,
            feedurl: row.get(3)?,
        })
    })?;

    for title in title_iter {
        println!("Found {:#?}", title.unwrap());
    }
    Ok(())
}
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
