use rocket::State;
use rocket::serde::{Serialize, json::Json};
use super::global::{Config, RssItem, RssFeed};
use super::db_parser::get_feed_list;

// The client will need an API to:
//  1. Fetch a list of all feeds
//  2. Fetch all items from a feed
//  3. Update the 'unread' status of a perticular item or all items in a feed


/// curl -X POST http://localhost:8000/read/1 -d "read=true" 
/// If the <id> parameter does not conform to the u32 type rocket
/// will try other potentially matching routes (based on `rank`) until
/// no matching alternatives remain, at which point 404 is given
#[post("/read/<id>", data = "<read>")]
pub fn read(id: u32, read: &str) -> String {
    format!("{} {}", id, read)
}

#[get("/feeds")]
pub fn feeds(config: &State<Config>) -> Json<Vec<RssFeed>> {
    
    Json( 
        get_feed_list( config.cache_path.as_str() )
            .unwrap() 
    )
}

#[get("/")]
pub fn index() -> &'static str {
    "" // TODO invoke same function as in /feeds
}

// We would like an API akin to 'GET /items/<feed-id>' but Newsboat
// only has the rss_url as a unique identifer
// By always sorting the feeds on a specific key we could derive
// our own feed-id but this would produce issues if the
// `.newsboat/urls` file changes and the client has an old value
// for which feed corresponds to which ID.
// The API was therefore constructed to use 'GET /items/< rss_url | base64url >' instead
#[get("/items/<b64_rss_url>")] // Uses the feedId
pub fn items(b64_rss_url: &str) -> String {
    format!("This {}", b64_rss_url )
}



