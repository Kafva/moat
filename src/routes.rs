use crate::{
    util::get_env_key,
    db,
};
use actix_web::{patch, get, post, web, HttpResponse, HttpRequest, Responder, FromRequest};
use super::Config;
use std::process::Command;
use std::future::{ready, Ready};

//============================================================================//

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static str = "{ \"success\": true }";

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

// Endpoints will not return 415 when the wrong method is provided
//  https://github.com/actix/actix-web/issues/2735

#[post("/unread")]
pub async fn unread(_: Creds) -> impl Responder {
    // WAIT FOR LOCK ON DB
    HttpResponse::Ok().body("TODO")
}

#[patch("/reload")]
pub async fn reload(_: Creds, config: web::Data<Config>) -> impl Responder {
    // TODO LOCK database
    let status = Command::new(config.newsboat_bin.as_str())
        .arg("-C")
        .arg(config.newsboat_config.as_str())
        .arg("-c")
        .arg(config.cache_db.as_str())
        .arg("-u")
        .arg(config.urls.as_str())
        .arg("-x")
        .arg("reload")
        .status();

    if status.is_ok() {
        HttpResponse::Ok().body(OK_RESPONSE)
    } else {
        HttpResponse::InternalServerError().body(ERR_RESPONSE)
    }
}

#[get("/feeds")]
pub async fn feeds(_: Creds, pool: web::Data<sqlx::SqlitePool>) -> impl Responder {
    log::info!("Pool {:#?}", pool);

    let _ = db::feeds(&pool).await;

    HttpResponse::Ok().body("TODO")
}

#[get("/items")]
pub async fn items(_: Creds) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

