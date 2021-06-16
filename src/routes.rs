use rocket::{State};
use rocket::serde::{json::Json};
use super::global::{Config, RssItem, RssFeed, ReadToggleData};
use super::db_parser::{get_feed_list, get_items_from_feed, toggle_read_status};

// The client will need an API to:
//  1. Fetch a list of all feeds
//  2. Fetch all items from a feed
//  3. Update the 'unread' status of a perticular item or all items in a feed

/// curl -X POST http://localhost:8000/read -d "id=5384&read=0" 
/// If the <id> parameter does not conform to the u32 type rocket
/// will try other potentially matching routes (based on `rank`) until
/// no matching alternatives remain, at which point 404 is given
#[post("/read", data = "<data>")]
pub fn read(config: &State<Config>, data: ReadToggleData ) -> &'static str {

    let success = toggle_read_status(
        &config.cache_path.as_str(), 
        data.id, 
        data.read
    ).unwrap(); 
    
    if success > 0 { 
        "{ \"success\": true }"
    }
    else { 
        "{ \"success\": false }"
    } 
}

/// '/feeds' and '/' give the same response
#[get("/feeds")]
pub fn feeds(config: &State<Config>) -> Json<Vec<RssFeed>> {
    Json( 
        get_feed_list( config.cache_path.as_str() )
            .unwrap() 
    )
}

#[get("/")]
pub fn index(config: &State<Config>) -> Json<Vec<RssFeed>> {
    Json( 
        get_feed_list( config.cache_path.as_str() )
            .unwrap() 
    )
}

// We would like an API akin to 'GET /items/<feed-id>' but Newsboat
// only has the rssurl as a unique identifer
// By always sorting the feeds on a specific key we could derive
// our own feed-id but this would produce issues if the
// `.newsboat/urls` file changes and the client has an old value
// for which feed corresponds to which ID.
// The API was therefore constructed to use 'GET /items/< rssurl | base64url >' instead
//      curl -X GET http://localhost:8000/items/$(printf 'https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA'|base64 )
#[get("/items/<b64_rssurl>")] 
pub fn items(config: &State<Config>, b64_rssurl: &str) -> Json<Vec<RssItem>> {

    // Decode the rssurl from base64
    let rssurl = String::from_utf8(
        base64::decode(b64_rssurl).unwrap()    
    ).unwrap();

    Json(
        get_items_from_feed(
            config.cache_path.as_str(), 
            rssurl.as_str()
        )
        .unwrap()
    )
}



