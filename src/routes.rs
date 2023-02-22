// Endpoints will not return 415 when the wrong method is provided
//  https://github.com/actix/actix-web/issues/2735
//
// The /unread and /reload endpoints both write to the db, however, `/reload`
// interacts indirectly with it via the newsboat executable, not the connection
// pool of the app. To avoid having to lock the database, we therefore use a
// a dedicated actor. Every endpoint defers its operations to the
// `NewsboatActor`.
//
//============================================================================//
use actix_web::{
        patch, get, post, web, HttpResponse, HttpRequest, Responder,
        FromRequest
};
use crate::newsboat_actor::ItemsMessage;
use crate::{moat_log_prefix,moat_err,moat_debug};
use crate::{
    util::get_env_key,
    newsboat_actor::{NewsboatActor,ReloadMessage,FeedsMessage},
    config::{OK_RESPONSE,ERR_RESPONSE},
    err::MoatError,
    db::{RssItem,RssFeed}
};
use std::future::{ready, Ready};
use base64::{Engine as _, engine::general_purpose};

//============================================================================//

pub struct Creds;

impl FromRequest for Creds {
    type Error = actix_web::Error;
    type Future = Ready<Result<Creds,Self::Error>>;

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
        ready(Err(actix_web::error::ErrorUnauthorized("")))
    }
}

//============================================================================//

#[post("/unread")]
pub async fn unread(_: Creds) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

#[patch("/reload")]
pub async fn reload(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>) -> impl Responder {
    let status = actor_addr.send(ReloadMessage).await;

    if status.is_ok() {
        HttpResponse::Ok().body(OK_RESPONSE)
    } else {
        HttpResponse::InternalServerError().body(ERR_RESPONSE)
    }
}

/// Responds with an empty list on failure.
#[get("/feeds")]
pub async fn feeds(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>) -> web::Json<Vec<RssFeed>> {
    if let Ok(rss_feeds) = actor_addr.send(FeedsMessage).await {
        let rss_feeds = rss_feeds.unwrap();
        web::Json(rss_feeds)
    } else {
        moat_err!("/feeds request error");
        web::Json(vec![])
    }
}

// TODO this: https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/wrap_error.html
// instead of derive_more.

/// Fetch all `RssItem` objects for a given rssurl.
#[get("/items/{b64_rssurl}")]
pub async fn items(_: Creds, actor_addr: web::Data<actix::Addr<NewsboatActor>>,
                   path: web::Path<(String,)>)
                -> Result<web::Json<Vec<RssItem>>, MoatError> {
    let b64_rssurl = path.into_inner().0;


    let rssurl = general_purpose::STANDARD.decode(b64_rssurl)?;

    if let Ok(rssurl) = String::from_utf8(rssurl) {
        moat_debug!("rssurl: {:#?}", rssurl);

        if let Ok(rss_items) = actor_addr.send(ItemsMessage { rssurl } ).await {
            let rss_items = rss_items.unwrap();
            return Ok(web::Json(rss_items))
        }
    }

    moat_err!("/items request error");
    Ok(web::Json(vec![]))
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
}
