use rocket::State;
use rocket::serde::json::Json;
use super::models::{Config, RssItem, RssFeed};
use super::dataguards::{ReadToggleData, Creds};
use super::db_parser::{get_feed_list, get_items_from_feed, toggle_read_status};

/// curl -X POST -H "x-creds: test" https://moat:7654/unread -d "id=5384&unread=0" 
/// curl -X POST -H "x-creds: test" https://moat:7654/unread/ -d "rssurl=$(printf 'https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA'|base64 )"
/// If the <id> parameter does not conform to the u32 type rocket
/// will try other potentially matching routes (based on `rank`) until
/// no matching alternatives remain, at which point 404 is returned
#[post("/unread", data = "<data>")]
pub fn unread(_key: Creds<'_>,  config: &State<Config>, 
              data: ReadToggleData) -> &'static str {

    let success = toggle_read_status(
        &config.cache_path.as_str(), 
        data.rssurl, 
        data.id,
        data.unread
    ).unwrap(); 
    
    if success > 0 { 
        "{ \"success\": true }"
    }
    else { 
        "{ \"success\": false }"
    } 
}

/// curl -H "x-creds: test" -X GET https://moat:7654/reload 
#[get("/reload")]
pub fn reload(_key: Creds<'_>, config: &State<Config>) -> &'static str {
    // Newsboat has a built-in command to reload all feeds in the background
    //      `newsboat -x reload`
    let output = std::process::Command::new(config.newsboat_path.as_str())
    // The arguments need to be passed seperatly, otherwise we effectivly run
    // `newsboat "-x reload"`
    .arg("-x")
    .arg("reload")
    .output()
    .expect("Failed to update cache.db"); // (panic!)
    
    if output.stderr.len() == 0 && 
        output.stdout.len() == 0 {
        "{ \"success\": true }"
    }
    else {
        "{ \"success\": false }"
    }
}

// curl -X GET -H "x-creds: test" https://moat:7654/feeds
#[get("/feeds")]
pub fn feeds(_key: Creds<'_>, config: &State<Config>) -> Json<Vec<RssFeed>> {
    
    match &config.muted_list {
        Some(m) => {
            Json( 
                get_feed_list(config.cache_path.as_str(), m.to_vec()).unwrap() 
            )
        }
        None => {
            Json( 
                get_feed_list(config.cache_path.as_str(), Vec::new()).unwrap() 
            )
        }
    }
}

// We would like an API akin to 'GET /items/<feed-id>' but Newsboat
// only has the rssurl as a unique identifer
// By always sorting the feeds on a specific key we could derive
// our own feed-id but this would produce issues if the
// `.newsboat/urls` file changes and the client has an old value
// for which feed corresponds to which ID.
// The API was therefore constructed to use 'GET /items/< rssurl | base64url >' instead
//      curl -X GET -H "x-creds: test" https://moat:7654/items/$(printf 'https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA'|base64 )
#[get("/items/<b64_rssurl>")] 
pub fn items(_key: Creds<'_>, config: &State<Config>, b64_rssurl: &str) -> Json<Vec<RssItem>> {

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
