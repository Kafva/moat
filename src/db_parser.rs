extern crate base64;
use super::models::{RssItem, RssFeed};

// For YT, video thumbnails can be determined from the entries in the rssurl,
// if these are to be included we will perform this fetch client side (XML
// parsing is probably easier from there)

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

/// Returns the number of changed rows on success
pub fn toggle_read_status(cache_path: &str, rssurl: Option<String>, id: Option<u32>, unread: bool) -> Result<usize,rusqlite::Error> {

    let conn = rusqlite::Connection::open(cache_path)?;
    
    match id {
        Some(id) => 
            conn.execute("
                UPDATE rss_item
                    SET unread = ?1
                WHERE id = ?2 ;", rusqlite::params![ unread, id ]
        ),
        None => match rssurl {
            // If a rssurl is provided we ignore any potential `unread` value and
            // always set the unread field in the db to false
            Some(rssurl) =>
                conn.execute("
                    UPDATE rss_item
                        SET unread = ?1
                    WHERE feedurl = ?2 ;", rusqlite::params![ false, rssurl ]
                ),
            None => Ok(0)
        }
    }
}

pub fn get_feed_list(cache_path: &str, muted_list: Vec<String>) -> Result<Vec<RssFeed>,rusqlite::Error> {
    
    let conn = rusqlite::Connection::open(cache_path)?;
    
    let sql_muted_list = get_muted_as_sql_stmt(&muted_list);
    
    let mut stmt = 
        // The rss_item and rss_feed tables share several common fields, in this
        // statement we use the rssurl/feedurl as a unique identifer to determine
        // how many unread articles each feed has
        conn.prepare(&format!("
        SELECT feedurl, rss_feed.url, author, SUM(unread) AS unread_count, COUNT(*) 
        FROM rss_item JOIN rss_feed ON rss_feed.rssurl = feedurl GROUP BY feedurl
        ORDER BY {} unread_count DESC;", sql_muted_list)
        
    )?;
    
    // Use a lambda statement on each row to create an iterator
    // over all feed objects from the query
    let feeds_iter = stmt.query_map([], |row| {
        
        let rssurl = row.get(0)?;
        let muted = muted_list.contains(&rssurl); 

        Ok(RssFeed::new(
            rssurl, 
            row.get(1)?, // url
            row.get(2)?, // author
            row.get(3)?, // unread_count
            row.get(4)?, // total_count
            muted // muted flag
        ))
    })?;

    // Collect all the items into a vector
    feeds_iter.collect()
}

fn get_muted_as_sql_stmt(muted_list: &Vec<String>) -> String {
    
    if muted_list.len() == 0 {
        return String::from("")
    }
    
    let mut sql_list = String::from("(");

    for rssurl in muted_list.into_iter() {
        sql_list.push('\'');
        sql_list.push_str(rssurl.as_str());
        sql_list.push('\'');
        sql_list.push(',');
    }
    
    // Remove trailing ','
    sql_list.truncate(sql_list.len() - 1);
    sql_list.push(')');

    // Meant to be used within
    //      ORDER BY <...> unread_count DESC;
    format!("rss_feed.rssurl IN {},", sql_list)
}

pub fn get_items_from_feed(cache_path: &str, rssurl: &str) -> Result<Vec<RssItem>, rusqlite::Error> {
    
    let conn = rusqlite::Connection::open(cache_path)?;
    let mut stmt = 
        conn.prepare( &format!("
            SELECT id, title, author, url, pubdate, unread FROM rss_item
            WHERE feedurl = '{}'
            ORDER BY pubdate DESC;", rssurl 
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
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_get_feeds() {
        
        let feeds = get_feed_list(
            &format!("{}/.newsboat/cache.db", 
                std::env::var("HOME").unwrap()
            ).as_str(),
            Vec::new()
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

        assert!( items.into_iter().count() > 0 );
    }

}
