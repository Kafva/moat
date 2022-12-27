use crate::dataguards::{Creds, ReadToggleData};
use crate::db_parser::{
    get_feed_list, get_items_from_feed, toggle_read_status,
};
use crate::errors::{ERR_RESPONSE, OK_RESPONSE};
use crate::models::{Config, RssFeed, RssItem};
use rocket::serde::json::Json;
use rocket::State;

/// curl -X POST -H "x-creds: test" https://moat:7654/unread -d "id=5384&unread=0"
/// curl -X POST -H "x-creds: test" https://moat:7654/unread/ -d "rssurl=$(printf 'https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA'|base64 )"
/// If the <id> parameter does not conform to the u32 type rocket
/// will try other potentially matching routes (based on `rank`) until
/// no matching alternatives remain, at which point 404 is returned
#[post("/unread", data = "<data>")]
pub fn unread(
    _key: Creds<'_>,
    config: &State<Config>,
    data: ReadToggleData,
) -> &'static str {
    let success = toggle_read_status(
        &config.cache_path.as_str(),
        data.rssurl,
        data.id,
        data.unread,
    )
    .unwrap();

    if success > 0 {
        OK_RESPONSE
    } else {
        ERR_RESPONSE
    }
}

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

    if output.stderr.len() == 0 && output.stdout.len() == 0 {
        OK_RESPONSE
    } else {
        ERR_RESPONSE
    }
}

#[get("/feeds")]
pub fn feeds(_key: Creds<'_>, config: &State<Config>) -> Json<Vec<RssFeed>> {
    match get_feed_list(config.cache_path.as_str(), &config.muted_list) {
        Ok(a) => Json(a),
        Err(_) => Json(Vec::new()),
    }
}

/// The API uses 'GET /items/<rssurl|base64url>'
///  curl -X GET -H "x-creds: test" https://moat:7654/items/$(base64 -w <<< 'https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA')
#[get("/items/<b64_rssurl>")]
pub fn items(
    _key: Creds<'_>,
    config: &State<Config>,
    b64_rssurl: &str,
) -> Json<Vec<RssItem>> {
    // Decode the rssurl from base64
    let decoded = base64::decode(b64_rssurl).unwrap_or_default();
    let rssurl = String::from_utf8(decoded).unwrap_or_default();

    // Empty response on error
    if rssurl.is_empty() {
        Json(Vec::new())
    } else {
        match get_items_from_feed(
            config.cache_path.as_str(),
            rssurl.as_str().trim(),
        ) {
            Ok(a) => Json(a),
            Err(_) => Json(Vec::new()),
        }
    }
}
