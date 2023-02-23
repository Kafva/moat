// Endpoints will not return 415 when the wrong method is provided
//  https://github.com/actix/actix-web/issues/2735
//
// The /update and /reload endpoints both write to the db, however, `/reload`
// interacts indirectly with it via the newsboat executable, not the connection
// pool of the app. To avoid having to lock the database, we therefore use a
// a dedicated actor. Every endpoint defers its operations to the
// `NewsboatActor`.
//
//============================================================================//
use actix_web::{
        patch, get, post, web, HttpRequest,
        FromRequest
};
use crate::newsboat_actor::ItemsMessage;
use crate::{
    util::get_env_key,
    newsboat_actor::{NewsboatActor,ReloadMessage,FeedsMessage,UpdateMessage},
    err::MoatError,
    db::{RssItem,RssFeed}
};
use std::future::{ready, Ready};
use base64::{Engine as _, engine::general_purpose};

//============================================================================//

pub struct Creds;

impl FromRequest for Creds {
    type Error = MoatError;
    type Future = Ready<Result<Creds,MoatError>>;

    /// Verify the `x-creds` header of an incoming request, ran for every
    /// endpoint that takes `Creds` as an argument.
    fn from_request(req: &HttpRequest, _: &mut actix_web::dev::Payload) ->
       <Self as FromRequest>::Future {

        let key = get_env_key();

        if let Some(creds) = req.headers().get("x-creds") {
            if creds.to_str().unwrap_or("") == key {
                return ready(Ok(Creds))
            }
        }
        ready(Err(MoatError::AuthError))
    }
}

#[derive(Debug,serde::Serialize)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct MoatResponse {
    pub success: bool,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub message: Option<String>,
}

//============================================================================//

/// Update the `unread` field of one or more `RssItem` objects in the database.
/// A single entry can be targeted using the `id` parameter and all items
/// for a feed can be targeted using the (base64 encoded) `feedurl` parameter.
///
/// The `success` key will only be `true` in the response if the update query
/// affected at least one row.
#[post("/update")]
pub async fn update(_: Creds, actor_addr:
                    web::Data<actix::Addr<NewsboatActor>>,
                    form: web::Form<UpdateMessage>)
 -> Result<web::Json<MoatResponse>, MoatError> {
    let message = form.into_inner();
    let success = actor_addr.send(message).await?;
    let success = success.unwrap_or(false);

    Ok(web::Json(MoatResponse { success, message: None }))
}

/// Reload all feeds.
#[patch("/reload")]
pub async fn reload(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>)
    -> Result<web::Json<MoatResponse>, MoatError> {
    let _ = actor_addr.send(ReloadMessage).await?;

    Ok(web::Json(MoatResponse { success: true, message: None }))
}

/// Fetch a list of all `RssFeed` objects.
#[get("/feeds")]
pub async fn feeds(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>)
    -> Result<web::Json<Vec<RssFeed>>, MoatError> {

    let rss_feeds = actor_addr.send(FeedsMessage).await?;
    Ok(web::Json(rss_feeds.unwrap()))
}

/// Fetch all `RssItem` objects for a given rssurl.
#[get("/items/{b64_rssurl}")]
pub async fn items(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>,
                   path: web::Path<(String,)>)
                -> Result<web::Json<Vec<RssItem>>, MoatError> {
    let rssurl = path.into_inner().0;
    let rssurl = general_purpose::STANDARD.decode(rssurl)?;
    let rssurl = String::from_utf8(rssurl)?;
    let res = actor_addr.send(ItemsMessage { rssurl }).await?;

    Ok(web::Json(res.unwrap()))
}

//============================================================================//

#[cfg(test)]
mod tests {
    use actix::prelude::*;
    use sqlx::{SqliteConnection,Connection};
    use crate::{
        util::run_setup_script,
        config::{Config, MOAT_KEY_ENV},
        muted::Muted,
        db::{RssFeed,RssItem},
        newsboat_actor::NewsboatActor,
        routes::MoatResponse,
        routes
    };
    use actix_web::{test, App, web};
    use base64::{Engine as _, engine::general_purpose};

    async fn setup() -> Addr<NewsboatActor> {
        run_setup_script();
        std::env::set_var(MOAT_KEY_ENV, "1");

        let config = Config {
            cache_db: "/tmp/moat/cache.db".to_string(),
            urls: "/tmp/moat/urls".to_string(),
            newsboat_config: "/tmp/moat/config".to_string(),
            newsboat_bin: "newsboat".to_string(),
        };

        let muted = Muted::from_urls_file(&config.urls).unwrap();

        let conn = SqliteConnection::connect(&config.cache_db).await
                .expect("Could not open database");

        NewsboatActor { config, muted, conn }.start()
    }

    #[actix_web::test]
    async fn test_feeds_not_empty() {
        let actor_addr = setup().await;

        let app = test::init_service(App::new()
                .app_data(web::Data::new(actor_addr))
                .service(routes::feeds)).await;

        let req = test::TestRequest::get().uri("/feeds")
                    .insert_header(("x-creds", "1")).to_request();

        let res: Vec<RssFeed> = test::call_and_read_body_json(&app, req).await;

        assert_ne!(res.len(), 0);
    }

    #[actix_web::test]
    async fn test_items_not_empty() {
        let actor_addr = setup().await;

        let app = test::init_service(App::new()
                .app_data(web::Data::new(actor_addr))
                .service(routes::items)).await;

        let b64_rssurl = general_purpose::STANDARD.encode(
            "https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA");

        let req = test::TestRequest::get().uri(&format!("/items/{}", b64_rssurl))
                    .insert_header(("x-creds", "1")).to_request();

        let res: Vec<RssItem> = test::call_and_read_body_json(&app, req).await;

        assert_ne!(res.len(), 0);
    }

    // TODO
    #[actix_web::test]
    async fn test_can_update() {
        let actor_addr = setup().await;

        let app = test::init_service(App::new()
                .app_data(web::Data::new(actor_addr))
                .service(routes::update)).await;

        let b64_rssurl = general_purpose::STANDARD.encode(
            "https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA");

        let req = test::TestRequest::get().uri("/update")
                    .insert_header(("x-creds", "1"))
                    .set_form(&format!("unread=true&feedurl={}", b64_rssurl))
                    .to_request();

        let res: MoatResponse = test::call_and_read_body_json(&app, req).await;

        assert!(res.success);
    }

}
